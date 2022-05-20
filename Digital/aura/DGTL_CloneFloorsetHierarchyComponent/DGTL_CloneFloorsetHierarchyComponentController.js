({
	doInit : function(component, event, helper) {
		helper.getPreviousFloorset(component,event);
	},
    
    clone :function(component, event, helper) {
        helper.getAllChilds(component,event);
    },
    
    cancelClick :function(component, event) {
        $A.get("e.force:closeQuickAction").fire();
    },
    addLayoutId : function(component, event) {
        console.log('pageTypeSelected----');
        var selectedRows = event.getParam('selectedRows');
        console.log('pageTypeSelected----',selectedRows);
        var selectedIds = [];
         for(var key in selectedRows)
         {             
             var obj = selectedRows[key];
             for(var key in obj)
             {
                 console.log('----obj[Id]---',obj['Id']);
                 selectedIds.push(obj['Id']);
                 break;
             }
         }
        component.set("v.selectedLayouts",selectedRows);
        console.log('----selectedIds---',component.get("v.selectedLayouts"));
    },
})