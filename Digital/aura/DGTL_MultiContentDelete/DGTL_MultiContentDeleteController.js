({
    init : function(component, event, helper) {
        console.log('open multicontent delete');
        helper.initHpr(component,event,helper);
    },
    handleCancel :function(component, event, helper) {
        console.log('handleCancel--');
        component.set("v.openMultiContentDelete",false);
        component.destroy();
    },
    handleDetele :function(component, event, helper) {
        console.log('handleDetele');
        helper.deleteHpr(component,event);
    },
    handleSelect : function(component, event, helper) {
        var selectedRows = event.getParam('selectedRows');
        var setRows = [];
        for ( var i = 0; i < selectedRows.length; i++ ) {
            setRows.push(selectedRows[i]);
        }
        component.set("v.selectedPlacementContents", setRows);
        component.set("v.selectedCountAdd",selectedRows.length);
    },
    radioChange :function(component, event, helper) {
        console.log('radioChange--',event.getParam("value"));
        component.set("v.choosenValue",event.getParam("value"));
    },
    onFirst : function(component, event, helper) { 
        component.set("v.spinner",true);
        component.set("v.currentPageNumber", 1);
        helper.buildData(component, helper);
        component.set("v.spinner",false);
    },
    onLast : function(component, event, helper) { 
        component.set("v.spinner",true);
        component.set("v.currentPageNumber", component.get("v.totalPages"));
        helper.buildData(component, helper);
        component.set("v.spinner",false);
    },
    onNext : function(component, event, helper) {
        component.set("v.spinner",true);        
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber+1);
        helper.buildData(component, helper);
        component.set("v.spinner",false);
    },
    onPrev : function(component, event, helper) { 
        component.set("v.spinner",true);
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber-1);
        helper.buildData(component, helper);
        component.set("v.spinner",false);
    },
})