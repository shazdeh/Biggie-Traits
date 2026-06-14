import skse;
import ShazdehUtils;
import Shared.GlobalFunc;

class MortgagePapers extends MovieClip {

    /* ref */
    public var PayBtn_mc:MovieClip;
    public var CloseBtn_mc:MovieClip;
    public var Bg_mc:MovieClip;
    public var Installment_tf:TextField;
    public var InstallmentAmount_tf:TextField;
    public var TotalDebt_tf:TextField;
    public var AmountPaid_tf:TextField;
    public var RemainingBalance_tf:TextField;

    function onLoad() {
        Shared.GlobalFunc.MaintainTextFormat();
        Key.addListener(this);
    }

    function SetPlatform(aiPlatform: Number, abPS3Switch: Boolean): Void {
    }

    function InitExtensions() {
        _root.isLoaded = true;

        if (_global.skse) {
            ShazdehUtils.setScale(this);
            ShazdehUtils.setPosition(this);
        }
    }

    function setupButtons(payKey:Number, exitKey:Number) {
        var _this = this;
        if ( payKey === 0 ) {
            PayBtn_mc._visible = false;
        } else {
            PayBtn_mc.setData(payKey, '$BIGTRAIT_HOMEOWNERPAY');
            PayBtn_mc.onRelease = function() {
                skse.SendModEvent('Traits_MortgagePapersPay');
            }
        }
        CloseBtn_mc.setData(exitKey, '$BIGTRAIT_HOMEOWNERCLOSE');
        CloseBtn_mc.onRelease = function() {
            _this.closeMenu();
        }
    }

    function onKeyDown() {
        if ( Key.getCode() === 9 ) {
            closeMenu();
        }
    }

    function closeMenu() {
        skse.SendModEvent('Traits_MortgagePapersClose');
    }

    // @api
    function setData(Installments:Number, InstallmentAmount:Number, TotalDebt:Number, AmountPaid:Number, RemainingBalance:Number, payKey:Number, exitKey:Number) {
        Installment_tf.SetText(Installments);
        InstallmentAmount_tf.SetText(InstallmentAmount);
        TotalDebt_tf.SetText(TotalDebt);
        AmountPaid_tf.SetText(AmountPaid);
        RemainingBalance_tf.SetText(RemainingBalance);
        setupButtons(payKey, exitKey);
    }
}