({
	getPreviousFloorset : function(component,event) {
         component.set('v.columns', [
            {label: 'Page Type', fieldName: 'Page_Types__c' , type: 'text'},
            {label: 'Device Type', fieldName: 'Device_Type__c' , type: 'text'}
        ]);
		component.set("v.showSpinner",true);
        var action = component.get("c.getPreviousFloorsetPlan");
        action.setParams({
            floorsetId : component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var result = response.getReturnValue();
                
                component.set("v.previousFloorset",result.obj_Floorset);
                component.set("v.pageTypes",result.pageTypes);
                
                component.set("v.data",result.list_filteredPageType);
                console.log("---result---",result);
            }else if(state === 'ERROR'){
                this.showToast(component, event, helper,response.getError()[0].message,'error');
            }
            component.set("v.showSpinner",false);
        });
        $A.enqueueAction(action);
	},
    
    // clones layouts,contents,content details and placement kods
    getAllChilds : function(component,event) { 
		component.set("v.showSpinner",true);
        var action = component.get("c.cloneFloorsetChildHierarchy");
        action.setParams({
            previousFloorsetId : component.get("v.previousFloorset").Id,
            floorsetId : component.get("v.recordId"),
            pLayoutListToSelClone : component.get("v.selectedLayouts")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                 this.showToast(component, event, helper,'Cloned Successfully!!','success');
            }else if(state === 'ERROR'){
                this.showToast(component, event, helper,response.getError()[0].message,'error');
            }
            component.set("v.showSpinner",false);
            $A.get("e.force:closeQuickAction").fire();
            $A.get('e.force:refreshView').fire();
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