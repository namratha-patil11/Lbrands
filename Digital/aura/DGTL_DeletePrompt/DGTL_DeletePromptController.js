({
    handleCancel : function(component, event, helper) {
        component.getEvent("DeleteRowEvt").setParams({
            "indexVar" : component.get("v.deleteIndex"),
            "DetailInstance" : component.get("v.record"),
            'delete' : false
        }).fire();
    },
    handleDetele : function(component, event, helper) {
        component.getEvent("DeleteRowEvt").setParams({
            "indexVar" : component.get("v.deleteIndex"),
            "DetailInstance" : component.get("v.record"),
            'delete' : true
        }).fire();
    }
})