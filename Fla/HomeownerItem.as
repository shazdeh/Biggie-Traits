class HomeownerItem extends MovieClip {

    public var Menu_mc:MovieClip;
    public var Title_tf:TextField;

    private var index:Number;
    private var title:String;
    private var description:String;
    private var price:Number;
    private var perWeek:Number;

    function onLoad() {
        _focusrect = false;
    }

    function setData( a_index:Number, a_title:String, a_description:String, a_price:Number, a_perWeek:Number, a_Menu_mc:MovieClip ) {
        index = a_index;
        title = a_title;
        description = a_description;
        price = a_price;
        perWeek = a_perWeek;
        Menu_mc = a_Menu_mc;
        Title_tf.SetText(title);
    }

    function onRollOver() {
        Selection.setFocus(this);
    }

    function onSetFocus() {
        gotoAndStop(2);
        Menu_mc.expand(index);
    }

    function onKillFocus() {
        gotoAndStop(1);
    }

    function onRelease() {
    }
}