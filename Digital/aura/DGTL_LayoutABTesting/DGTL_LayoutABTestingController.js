({
	init : function(component, event, helper) {
        component.set("v.spinner",true);
        helper.initHpr(component, event);
        component.set("v.spinner",false);
    },
    getTestName : function(component,event){
        var params = event.getParams();
        component.set("v.TestingName",params.value);
        component.set("v.TestingNameUpdate",params.value); 
    },
    getTesting : function(component,event){
        component.set("v.spinner",true);
        if(component.get("v.selectedTest") !=  'None'){
            component.set("v.recordId",component.get("v.selectedTest"));
        }else{
            component.set("v.recordId",'');
            component.set("v.TestingName",'');
        }
        component.set("v.spinner",false);
    },
    closeModalBox : function(component, event, helper) {
        component.set("v.toggleABModal", false);
    },
    updateTestLayJs : function(component, event, helper) {
        component.set("v.spinner",true);
        helper.updateTestLayJsHpr(component, event);
        component.set("v.spinner",false);
    },
})