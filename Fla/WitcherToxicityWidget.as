import skyui.widgets.WidgetBase;

class WitcherToxicityWidget extends skyui.widgets.WidgetBase {

    public var bottle1:MovieClip;
    public var bottle2:MovieClip;
    public var bottle3:MovieClip;
    public var bottle4:MovieClip;

    function update(a_currentLevel:Number) {
        bottle1.gotoAndStop(a_currentLevel >= 1 ? 2 : 1);
        bottle2.gotoAndStop(a_currentLevel >= 2 ? 2 : 1);
        bottle3.gotoAndStop(a_currentLevel >= 3 ? 2 : 1);
        bottle4.gotoAndStop(a_currentLevel === 4 ? 2 : 1);
    }

    // @api
    function setScale(a_scale:Number) {
        _xscale = a_scale * 100;
        _yscale = a_scale * 100;
    }
}