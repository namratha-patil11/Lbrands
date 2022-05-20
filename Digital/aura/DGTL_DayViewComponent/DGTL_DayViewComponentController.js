({
	checkFloorsetId : function(component, event, helper) {
        let floorsetId = component.get("v.floorsetId");
        let disabled = floorsetId == '' ? true : false;
        if(floorsetId == '') component.set("v.recordId",'');
        component.set("v.disabled",disabled);
	},
    
    getDayViewTaskId : function(component, event, helper) {
        helper.fetchTaskId(component, event, helper);
    }
})