({
    getKODRecord : function(component, event, helper) {
        component.set("v.showSpinner",true);
        var action = component.get("c.fetchKODDetails");
        action.setParams({
            kodId : component.get("v.kodId")[0]
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                let selectedKODs = component.get("v.selectedKODs");
                let obj = {name:response.getReturnValue(),id:component.get("v.kodId"), class:"pillColorUnsaved"};
                selectedKODs.push(obj);
                component.set("v.selectedKODs",selectedKODs);
                component.set("v.kodId",[]);
                component.set("v.disabled",false);
            }else if(state === 'ERROR'){
                component.set("v.kodId",[]);
                this.showToast(component, event, helper,response.getError()[0].message, "error");
            }
            component.set("v.showSpinner",false);
        });
        $A.enqueueAction(action);
	},
    
    getPlacementKODs : function(component, event, helper) {
        component.set("v.showSpinner",true);
        var action = component.get("c.fetchPlacementKODs");
        action.setParams({
            contentId : component.get("v.contentId")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var selectedKODs = response.getReturnValue();
                
                if(selectedKODs.length > 0){
                    for(var index in selectedKODs){
                        selectedKODs[index].class = "pillColorSaved";
                    }
                    component.set("v.disabled",false);
                    component.set("v.new",false);
                }
                component.set("v.selectedKODs",selectedKODs);
                
            }else if(state === 'ERROR'){
                this.showToast(component, event, helper,response.getError()[0].message, "error");
            }
            component.set("v.showSpinner",false);
        });
        $A.enqueueAction(action);
        
    },
    
    validateSelectedKOD : function(component, event, helper) {
        let selectedKODs = component.get("v.selectedKODs");
        let kodId = component.get("v.kodId")[0];
        let isValid = true;
        
        if(selectedKODs.length > 0){
            for(var index in selectedKODs){
                if(selectedKODs[index].id == kodId){
                    isValid = false;
                    this.showToast(component, event, helper,"KOD has already been added", "warning");
                    break;
                }
            }
        }
        
        return isValid;
    },
    
    savePlacementKODs : function(component, event, helper) {
        component.set("v.showSpinner",true);
        let selectedKODs = component.get("v.selectedKODs");
        let kodIds = [];
        
        for(var index in selectedKODs){
            kodIds.push(selectedKODs[index].id);
        }
            
        var action = component.get("c.linkPlacementKODs");
        action.setParams({
            contentId : component.get("v.contentId"),
            kodIds : kodIds,
            removedKODs : component.get("v.removedKODs")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                let selectedKODs = component.get("v.selectedKODs");
                let kodStatus = 'removed';
                 if(selectedKODs.length > 0){
                    for(var index in selectedKODs){
                        selectedKODs[index].class = "pillColorSaved";
                    }
                     kodStatus = 'linked';
                     component.set("v.new",false);
                }
                component.set("v.selectedKODs",selectedKODs);
                this.showToast(component, event, helper,"KODs "+kodStatus+" successfully.", "success");
            }else if(state === 'ERROR'){
                this.showToast(component, event, helper,response.getError()[0].message, "error");
            }
            component.set("v.showSpinner",false);
        });
        $A.enqueueAction(action);
        
    },
    
    showToast : function(component, event, helper,msg,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "message": msg,
            "type" : type
        });
        toastEvent.fire();
    },
})