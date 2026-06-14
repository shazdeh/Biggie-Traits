import skse;
import Selection;
import Shared.GlobalFunc;
import ShazdehUtils;

class Homeowner extends MovieClip {

    /* ref */
    public var Background_mc:MovieClip;
    public var Title_tf:TextField;
    public var Price_tf:TextField;
    public var PerWeek_tf:TextField;
    public var TotalWeeks_tf:TextField;
    public var DetailsPanel_mc:MovieClip;
    public var Desc_tf:TextField;
    public var VisitBtn_mc:MovieClip;
    public var PurchaseBtn_mc:MovieClip;

    /* data */
    private var items:Array;
    private var activeItemIndex:Number = 1;

    /* config */

    function onLoad() {
        Selection["alwaysEnableArrowKeys"] = false;
        Selection["disableFocusKeys"] = true;
        _focusrect = false;
        Shared.GlobalFunc.MaintainTextFormat();
        Shared.GlobalFunc.SetLockFunction();
        _visible = false;
        items = [ '', this['item1'], this['item2'], this['item3'], this['item4'] ];
        Desc_tf = DetailsPanel_mc.Desc_tf;
        Key.addListener(this);
    }

    function SetPlatform(aiPlatform: Number, abPS3Switch: Boolean): Void {
    }

    function InitExtensions() {
        _root.isLoaded = true;
    }

    function onKeyDown() {
        if ( Key.getCode() === 9 ) {
        } else if ( Key.getCode() === 38 ) { // up
            if ( activeItemIndex > 1 ) {
                Selection.setFocus(getClipIndex(activeItemIndex - 1));
            }
        } else if ( Key.getCode() === 40 ) { // down
            if ( activeItemIndex + 1 < items.length ) {
                Selection.setFocus(getClipIndex(activeItemIndex + 1));
            }
        }
    }

    function getActiveItem() {
        if ( activeItemIndex !== 0 ) {
            return items[activeItemIndex];
        }
    }

    function getClipIndex(index:Number) {
        return items[index];
    }

    function setTitle(title:String) {
        Title_tf.SetText(title);
    }

    function setupButtons(visitKey:Number, purchaseKey:Number) {
        var _this = this;
        PurchaseBtn_mc.setData(purchaseKey, '$BIGTRAIT_HOMEOWNERPurchase');
        PurchaseBtn_mc.onRelease = function() {
            skse.SendModEvent('Traits_PurchaseHouse', _this.activeItemIndex.toString());
        }
        VisitBtn_mc.setData(visitKey, '$BIGTRAIT_HOMEOWNERVISIT');
        VisitBtn_mc.onRelease = function() {
            skse.SendModEvent('Traits_VisitHouse', _this.activeItemIndex.toString());
        }
    }

    // @api
    function setData(a_data:String) {
        if (_global.skse) {
            ShazdehUtils.setScale(this);
            ShazdehUtils.setPosition(this);
        }

        var data:Array = a_data.split('|');
        for ( var i = 1; i !== data.length; i++ ) {
            var prices = data[i].split(',');
            items[i].setData( i, '$BIGTRAIT_HOME' + i, '$BIGTRAIT_HOME' + i + '_DESC', parseInt(prices[0]), parseInt(prices[1]), this );
        }

        Selection.setFocus(items[1]);
        _visible = true;
    }

    function expand(index:Number) {
        this['Marker' + activeItemIndex]._xscale = 120;
        this['Marker' + activeItemIndex]._yscale = 120;
        activeItemIndex = index;
        this['Marker' + activeItemIndex]._xscale = 150;
        this['Marker' + activeItemIndex]._yscale = 150;
        Price_tf.SetText(getClipIndex(index).price);
        PerWeek_tf.SetText(getClipIndex(index).perWeek);
        Desc_tf.SetText(getClipIndex(index).description);
    }
}