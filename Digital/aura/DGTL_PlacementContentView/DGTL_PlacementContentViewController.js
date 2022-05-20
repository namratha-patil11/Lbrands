({
    doInit : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var url = window.location.href;
        if(url.includes('Placement_Layout__c')){
            helper.navigate(component, event,recordId);
        }else{
            helper.doInitHelper(component, event);
        }
    }
})