class HotkeyButton extends MovieClip {

    public var Hotkey_mc:MovieClip;
    public var Label_tf:TextField;

    function setData(keycode:Number, label:String) {
        Hotkey_mc.gotoAndStop(keycode);
        Label_tf._x = Hotkey_mc._x + Hotkey_mc._width;
        Label_tf.SetText(label);
    }

    function onRollOver() {
        gotoAndStop(2);
    }

    function onRollOut() {
        gotoAndStop(1);
    }
}