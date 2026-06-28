using namespace RE;
using namespace SKSE;
#include "ClibUtil/editorID.hpp"

static std::vector<TESObjectBOOK*> skillBooks;

void ClearBookSkillTeachFlag(RE::TESObjectBOOK* book) {
    if (!book) {
        return;
    }

    auto& data = book->data;

    using Flag = RE::OBJ_BOOK::Flag;
    using Under = std::underlying_type_t<Flag>;  // usually uint8_t for OBJ_BOOK

    // 1. get raw flag bits:
    Under flags = data.flags.underlying();

    // 2. compute the bit to clear:
    Under bitToClear = static_cast<Under>(Flag::kAdvancesActorValue);

    // 3. clear it:
    flags &= ~bitToClear;

    // 4. assign back:
    data.flags = static_cast<Flag>(flags);
}

void StripSkillTeachingFromAllBooks(RE::StaticFunctionTag*) {
    auto* dataHandler = RE::TESDataHandler::GetSingleton();
    if (!dataHandler) {
        return;
    }

    for (auto* form : dataHandler->GetFormArray<RE::TESObjectBOOK>()) {
        if (!form) {
            continue;
        }
        if (form->TeachesSkill()) {
            ClearBookSkillTeachFlag(form);
            skillBooks.push_back(form);
        }
    }
}

void RevertStripSkillTeaching(RE::StaticFunctionTag*) {
    for (auto* book : skillBooks) {
        if (!book) continue;

        auto& data = book->data;

        using Flag = RE::OBJ_BOOK::Flag;
        using Under = std::underlying_type_t<Flag>;
        Under flags = data.flags.underlying();
        Under bit = static_cast<Under>(Flag::kAdvancesActorValue);

        // Restore the bit
        flags |= bit;
        data.flags = static_cast<Flag>(flags);
    }

    skillBooks.clear();
}

std::vector<SpellItem*> GetSortedListItems(BGSListForm* a_list) {
    std::vector<SpellItem*> result;
    result.reserve(a_list->forms.size() + a_list->scriptAddedFormCount);

    a_list->ForEachForm([&](TESForm* form) {
        if (!form->Is(FormType::Spell)) return BSContainer::ForEachResult::kContinue;
        SpellItem* spell = form->As<SpellItem>();
        result.push_back(spell);
        return BSContainer::ForEachResult::kContinue;
    });

    std::sort(result.begin(), result.end(), [](SpellItem* a, SpellItem* b) {
        auto an = a && a->GetName() ? a->GetName() : "";
        auto bn = b && b->GetName() ? b->GetName() : "";
        return std::strcmp(an, bn) < 0;
    });

    return result;
}

std::string FormatDescription(const std::string_view input) {
    std::string result;

    for (char c : input) {
        switch (c) {
            case '<':
                result += "<b>";
                break;
            case '>':
                result += "</b>";
                break;
            default:
                result += c;
                break;
        }
    }

    return result;
}

void PopulateTraitsList(StaticFunctionTag*, BGSListForm* a_list) {
    if (!a_list) return;
    auto ui = RE::UI::GetSingleton();
    auto menu = ui->GetMenu("CustomMenu");
    if (!menu) return;
    auto view = menu->uiMovie;
    if (!view) return;

    auto result = GetSortedListItems(a_list);
    for (auto spell : result) {
        if (!spell) continue;
        RE::GFxValue args[3];
        args[0].SetString(spell->GetName());
        BSString description;
        spell->GetDescription(description, spell);
        args[1].SetString(FormatDescription(description).c_str());
        args[2].SetString("TraitPics/" + clib_util::editorID::get_editorID(spell) + ".dds");
        view->Invoke("_root.Traits_mc.addItem", nullptr, args, 3);
    }
}

// dealing with old jank!
// the b612_TraitsMenu.Show() returns an string[] of indexes
std::vector<SpellItem*> GetTraitsAtIndexes(StaticFunctionTag*, BGSListForm* a_list, std::vector<std::string> indexes) {
    std::vector<SpellItem*> result;
    auto sorted = GetSortedListItems(a_list);
    for (auto s_index : indexes) {
        int index = std::stoi(s_index);
        if (sorted[index]) {
            result.push_back(sorted[index]);
        }
    }

    return result;
}

void InjectMasterofOne(StaticFunctionTag*, int a_hotkey) {
    const auto ui = RE::UI::GetSingleton();
    if (!ui) return;
    const auto menu = ui->GetMenu(StatsMenu::MENU_NAME);
    if (!menu) return;
    const auto movie = menu->uiMovie;
    if (!movie) return;

    RE::GFxValue _root;
    movie->GetVariable(&_root, "_root");

    _root.SetMember("Traits_Hotkey", GFxValue(a_hotkey));

    RE::GFxValue args[2];
    args[0] = RE::GFxValue("MasterofOne");
    args[1] = RE::GFxValue(4501);
    _root.Invoke("createEmptyMovieClip", nullptr, args, 2);
    if (movie->GetVariable(&_root, "_root.MasterofOne")) {
        RE::GFxValue args2[1];
        args2[0] = RE::GFxValue("masterofone_inject.swf");
        _root.Invoke("loadMovie", nullptr, args2, 1);
    }
}

int GetCurrentSkillInStatsMenu(StaticFunctionTag*) {
    auto menu = UI::GetSingleton()->GetMenu<StatsMenu>();
    if (!menu) return -1;
    return menu->GetRuntimeData().selectedTree;
}

template <typename T>
bool compare(T a, T b, const std::string& op) {
    if (op == "=" || op == "==") return a == b;
    if (op == "<") return a < b;
    if (op == "<=") return a <= b;
    if (op == ">") return a > b;
    if (op == ">=") return a >= b;
    if (op == "!=") return a != b;
    return false;
}

int GetSpellMinimumSkillLevel(SpellItem* a_spell) {
    if (!a_spell) return 0;
    int min = 0;
    for (auto effect : a_spell->effects) {
        auto minLevel = effect->baseEffect->GetMinimumSkillLevel();
        if (minLevel > min) {
            min = minLevel;
        }
    }

    return min;
}

std::vector<SpellItem*> GetAllSpells(StaticFunctionTag*, BSFixedString a_skill = "", int a_minSkill = 0,
                                     std::string a_minSkillComp = "=", int a_max = 0) {
    std::vector<SpellItem*> result;
    const auto& all = TESDataHandler::GetSingleton()->GetFormArray<TESObjectBOOK>();
    ActorValue av = ActorValue::kNone;
    if (a_skill == "destruction") {
        av = ActorValue::kDestruction;
    } else if (a_skill == "alteration") {
        av = ActorValue::kAlteration;
    } else if (a_skill == "conjuration") {
        av = ActorValue::kConjuration;
    } else if (a_skill == "restoration") {
        av = ActorValue::kRestoration;
    } else if (a_skill == "illusion") {
        av = ActorValue::kIllusion;
    }

    for (auto book : all) {
        if (!book->TeachesSpell()) continue;
        if (auto spell = book->GetSpell(); spell) {
            if (av != ActorValue::kNone && spell->GetAssociatedSkill() != av) continue;
            if (a_minSkill > 0 && !compare(GetSpellMinimumSkillLevel(spell), a_minSkill, a_minSkillComp))
                continue;
            result.push_back(spell);
            if (a_max > 0 && result.size() == a_max) break;
        }
    }

    return result;
}

std::vector<TESObjectBOOK*> GetAllSpellBooks(StaticFunctionTag*, BSFixedString a_skill = "", int a_minSkill = 0,
                                             std::string a_minSkillComp = "=", int a_max = 0) {
    std::vector<TESObjectBOOK*> result;
    const auto& all = TESDataHandler::GetSingleton()->GetFormArray<TESObjectBOOK>();
    ActorValue av = ActorValue::kNone;
    if (a_skill == "destruction") {
        av = ActorValue::kDestruction;
    } else if (a_skill == "alteration") {
        av = ActorValue::kAlteration;
    } else if (a_skill == "conjuration") {
        av = ActorValue::kConjuration;
    } else if (a_skill == "restoration") {
        av = ActorValue::kRestoration;
    } else if (a_skill == "illusion") {
        av = ActorValue::kIllusion;
    }

    for (auto book : all) {
        if (!book->TeachesSpell()) continue;
        if (auto spell = book->GetSpell(); spell) {
            if (av != ActorValue::kNone && spell->GetAssociatedSkill() != av) continue;
            if (a_minSkill > 0 && !compare(GetSpellMinimumSkillLevel(spell), a_minSkill, a_minSkillComp))
                continue;
            result.push_back(book);
            if (a_max > 0 && result.size() == a_max) break;
        }
    }
    return result;
}

bool PapyrusBinder(RE::BSScript::IVirtualMachine* vm) {
    std::string_view script = "Traits_Utils"sv;

    vm->RegisterFunction("StripSkillTeachingFromAllBooks", script, StripSkillTeachingFromAllBooks);
    vm->RegisterFunction("RevertStripSkillTeaching", script, RevertStripSkillTeaching);
    vm->RegisterFunction("PopulateTraitsList", script, PopulateTraitsList);
    vm->RegisterFunction("GetTraitsAtIndexes", script, GetTraitsAtIndexes);
    vm->RegisterFunction("InjectMasterofOne", script, InjectMasterofOne);
    vm->RegisterFunction("GetCurrentSkillInStatsMenu", script, GetCurrentSkillInStatsMenu);
    vm->RegisterFunction("GetAllSpellBooks", script, GetAllSpellBooks);
    vm->RegisterFunction("GetAllSpells", script, GetAllSpells);

    return false;
}

SKSEPluginLoad(const SKSE::LoadInterface *skse) {
    SKSE::Init(skse);

    SKSE::GetPapyrusInterface()->Register(PapyrusBinder);

    return true;
}