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

bool PapyrusBinder(RE::BSScript::IVirtualMachine* vm) {
    std::string_view script = "Traits_Utils"sv;

    vm->RegisterFunction("StripSkillTeachingFromAllBooks", script, StripSkillTeachingFromAllBooks);
    vm->RegisterFunction("RevertStripSkillTeaching", script, RevertStripSkillTeaching);
    vm->RegisterFunction("PopulateTraitsList", script, PopulateTraitsList);
    vm->RegisterFunction("GetTraitsAtIndexes", script, GetTraitsAtIndexes);

    return false;
}

SKSEPluginLoad(const SKSE::LoadInterface *skse) {
    SKSE::Init(skse);

    SKSE::GetPapyrusInterface()->Register(PapyrusBinder);

    return true;
}