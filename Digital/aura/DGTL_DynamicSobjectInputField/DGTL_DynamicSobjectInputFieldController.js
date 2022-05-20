({
    doInit : function(component, event, helper) {
        helper.doInitHpr(component, event, helper);
        
    },
    change: function(component,event,helper){
        
        var unsavedBooleanVal = component.get("v.UnsavedChanges");
        var startUnsaved =  component.get("v.Valueset");
        //console.log('@@onChange' + unsavedBooleanVal);
        
       // if(unsavedBooleanVal == false && 
       console.log('@@INPUTCOMPChanges' +component.get("v.UnsavedChanges"));
           if(startUnsaved == false){
            //var unsaved = component.find("unsaved");
            //unsaved.setUnsavedChanges(true);
            //component.set("v.UnsavedChanges", true);
        }
        
        //console.log('^^onChange' + component.get("v.UnsavedChanges"));  
        helper.changeHpr(component, event, helper);      
    },
    saveUnsavedChanges : function(component,event,helper){
       /* var isunsaved = true;
        component.getEvent("Unsavedchanges").setParams({
            "isUnsaved" : isunsaved
        }).fire();*/
    // component.set("v.UnsavedChanges", false);   
    },
    
    
     handleDiscard: function(component, event, helper) {
        // Similar to the handleSave method, but for discarding changes
       /* var unsaved = component.find("unsaved");
        unsaved.setUnsavedChanges(false);*/
    },
})