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
    public var Desc_tf:TextField;
    public var Btn_mc:MovieClip;

    private var yOffset = 50;
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
        _root.CurrentSkill = getCurrentSkill();
    }

    function getCurrentSkill() : Number {
        var highestScale:Number = 0,
            current:Number = 0;
        for ( var i = 0; i < 18; i++ ) {
            if ( AnimatingSkillTextInstance['SkillText' + i]._xscale > highestScale ) {
                highestScale = AnimatingSkillTextInstance['SkillText' + i]._xscale;
                current = i;
            }
        }

        return current;
    }

    function reposition() {
        var points = { x: DescriptionCardInstance._x, y: DescriptionCardInstance._y };
        /* everything in StatsMenu is off-center on the X axis, except for TopPlayerInfo! */
        var points2 = { x: Menu_mc.TopPlayerInfo._x, y: Menu_mc.TopPlayerInfo._y };
        Menu_mc.localToGlobal( points );
        Menu_mc.localToGlobal( points2 );
        _x = points2.x;
        _y = points.y - _height - yOffset;
    }

    // @api
    function setHotkey(a_keycode:String, a_label:String) {
        Btn_mc.Hotkey_mc.gotoAndStop(parseInt(a_keycode));
        Btn_mc.Label_tf.autoSize = 'left';
        Btn_mc.Label_tf._x = Btn_mc.Hotkey_mc._x + Btn_mc.Hotkey_mc._width;
        Btn_mc.Label_tf.SetText(a_label);
        Btn_mc._x -= Btn_mc._width / 2;
        reposition();
        updateSkill();
    }
}