({
    doInit : function(component, event, helper) {
        helper.getPlacementKODs(component, event, helper);
    },
    
	onKODSelect : function(component, event, helper) {
        if(component.get("v.kodId")[0] != undefined){
            var isValidated = helper.validateSelectedKOD(component, event, helper);
            if(isValidated){		
                helper.getKODRecord(component, event, helper);
            }
        }
    },
    
    handleRemove :function(component, event, helper) {
        let selectedKODs = component.get("v.selectedKODs");
        let kodIdToRemove = event.getSource().get("v.name");
        let removedKods = component.get("v.removedKODs");
        
        for(var index in selectedKODs){
            if(selectedKODs[index].id == kodIdToRemove){
                removedKods.push(selectedKODs[index].id);
                selectedKODs.splice(index,1);
                break;
            }
        }
        
        if(component.get("v.new") && !selectedKODs.length > 0){
            component.set("v.disabled",true);
        }
        component.set("v.selectedKODs",selectedKODs);
        component.set("v.removedKODs",removedKods);
    },
    
    save : function(component, event, helper){
        helper.savePlacementKODs(component, event, helper);
    },
    
    close : function(component, event, helper){
        component.set("v.kodId",'');
        component.getEvent("closeKODPopup").setParams({
            'close' : true
        }).fire();
    }
})