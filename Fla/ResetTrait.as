import skse;
import skyui.defines.Input;
import ShazdehUtils;

class ResetTrait extends MovieClip {

    public var Menu_mc:MovieClip;
    public var inventoryLists:MovieClip;
    public var categoryList:MovieClip;
    public var itemList:MovieClip;
    public var bottomBar:MovieClip;
    public var buttonPanel:MovieClip;

    private var prefix:String;

    function onLoad() {
        Menu_mc = _parent._parent.Menu_mc;
        inventoryLists = Menu_mc.inventoryLists;
        categoryList = inventoryLists.categoryList;
        itemList = inventoryLists.itemList;
        bottomBar = Menu_mc.bottomBar;
        buttonPanel = bottomBar.buttonPanel;
        prefix = ShazdehUtils.get_i18n( '$BIGTRAIT_PREFIX' );

        itemList.addEventListener("selectionChange", this, "onItemsListSelectionChange");
        onItemsListSelectionChange();
    }

    private function onItemsListSelectionChange(event: Object): Void {
        if ( categoryList.selectedIndex === 9 // Active Effects
            && itemList.selectedEntry.text.substr(0, prefix.length) === prefix ) {
            buttonPanel.addButton( {text: '$BIGTRAIT_REMOVE', controls: Input.XButton} );
            buttonPanel.updateButtons(true);
            _root.isTraitItem = true;
        } else {
            _root.isTraitItem = false;
        }
	}
}