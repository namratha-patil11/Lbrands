({
    showToast : function(component, event, helper,msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "message": msg,
            "type" : "error"
        });
        toastEvent.fire();
    },
    
    fetchTaskId : function(component, event, helper) {
        component.set("v.showSpinner",true);
        component.set("v.recordId",'');
        var action = component.get("c.getTaskId");
        var layout = component.get("v.placementLayout");
        action.setParams({
            floorsetPlanId : component.get("v.floorsetId")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.recordId",response.getReturnValue());
            }else if(state === 'ERROR'){
                this.showToast(component, event, helper,response.getError()[0].message);
            }
            component.set("v.showSpinner",false);
        });
        $A.enqueueAction(action);
    }
})