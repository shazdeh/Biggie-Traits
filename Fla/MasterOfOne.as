import skse;
import Selection;
import Shared.GlobalFunc;
import ShazdehUtils;

class MasterOfOne extends MovieClip {

    public static var instance;

    /* ref */
	public var Menu_mc:MovieClip;
    public var DescriptionCardInstance:MovieClip;
    public var AnimatingSkillTextInstance:MovieClip;
    public var Background_mc:MovieClip;
    public var Btn_mc:MovieClip;

    private var timer;

    function MasterOfOne() {
        MasterOfOne.instance = this;
        _visible = false;
    }

    function onLoad() {
        Shared.GlobalFunc.MaintainTextFormat();
		Menu_mc = _parent._parent.StatsMenuBaseInstance;
        AnimatingSkillTextInstance = Menu_mc.AnimatingSkillTextInstance;
        DescriptionCardInstance = Menu_mc.DescriptionCardInstance;

        duckPunch();
        render();
    }

    function render() {
        Btn_mc.Hotkey_mc.gotoAndStop(_root.Traits_Hotkey);
        Btn_mc.Label_tf.autoSize = 'left';
        Btn_mc.Label_tf._x = Btn_mc.Hotkey_mc._x + Btn_mc.Hotkey_mc._width;
        Btn_mc.Label_tf.SetText("$BIGTRAIT_SELECTSKILL");
        Btn_mc._x -= Btn_mc._width / 2;
        updateSkill();
    }

    function duckPunch() {
        Menu_mc.MOO_SetDescriptionCard = Menu_mc.SetDescriptionCard;
        Menu_mc.SetDescriptionCard = SetDescriptionCard;
    }

    function SetDescriptionCard(abPerkMode: Boolean, aName: String, aMeterPercent: Number, aDescription: String, aRequirements: String, aSkillLevel: String, aSkill: String): Void {
        this = MasterOfOne.instance;
        Menu_mc.MOO_SetDescriptionCard(abPerkMode, aName, aMeterPercent, aDescription, aRequirements, aSkillLevel, aSkill);
        _visible = false;
        clearTimeout(timer);
        if ( ! abPerkMode ) {
            timer = setTimeout( function() {
                MasterOfOne.instance.updateSkill();
            }, 1000 );
        }
    }

    function updateSkill() {
        _visible = true;
    }
}