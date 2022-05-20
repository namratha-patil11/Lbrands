({
    initHelper : function(component, event, helper) {
         console.log('parentContentId...',component.get("v.parentContentId"));
        component.set("v.spinner",true);
        var id = component.get("v.parentContentId");
        var action = component.get("c.initialize");
        console.log('parentContentId..before calling action...',id);

        action.setParams({
            'parentContentId' : id
        });
        action.setCallback(this, function(response){
           var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.spinner",false);
                console.log('SUCCESS-- state--',state);
                var result = response.getReturnValue();
                
                if(result != undefined && result != null)
                {
                    component.set("v.WraperObject",result);
                    this.setReadWriteFields(component, event, helper, result);
                    component.set("v.TaskRec",result.activeTaskRec);
                    console.log('SUCCESS-- state--PlacementContent--',result.PlacementContent);
                    console.log('SUCCESS-- state--list_PlacementContentDetail--',result.list_PlacementContentDetail);
                    console.log('SUCCESS-- state--list_DetelePlacementContentDetail--',result.list_DetelePlacementContentDetail);
                }
                
            }else if(state === 'ERROR'){
                component.set("v.spinner",false);
                console.log('Something went Wrong-- state ERROR!!');
            }else{
                component.set("v.spinner",false);
                console.log('Something went Wrong!!-- state--',state);
            }
            
        });
        $A.enqueueAction(action);
    },
    saveHelper : function(component, event, helper, fieldSet ) {
        component.set("v.spinner",true);
        console.log('fieldSet...',fieldSet);
        var wraper = component.get("v.WraperObject");
        console.log('wraper...',wraper);
        var action = component.get("c.saveChanges");
        action.setParams({
            'list_PlacementContentDetail' : wraper.list_PlacementContentDetail,
            'list_DetelePlacementContentDetail' : wraper.list_DetelePlacementContentDetail,
            'list_DetelePlacementContentDetailOld' : wraper.list_DetelePlacementContentDetailOld,
            'map_DetailWriteFields' : wraper.map_DetailWriteFields,
            'map_WriteFields' : wraper.map_WriteFields,
            'parentRecord' : wraper.parentRecord,
            'PlacementContent' : wraper.PlacementContent,
            'contentFields' : fieldSet
        });
         action.setCallback(this, function(response){
           var state = response.getState();
            if(state === 'SUCCESS'){
                console.log('SUCCESS-- state--',state);
                var result = response.getReturnValue();
                console.log('SUCCESS-- state--result--before--',JSON.stringify(result));
                if(result != undefined && result != null)
                { component.set("v.spinner",false);
                    if(result == true){
                        console.log('Save-- state--result--',state);
                        location.reload();
                    }else if(result == false){
                        console.log('Save-- state--false--');
                        this.showToast(component, 'sticky', 'Warning', 'There were no changes Made, Please Edit before Saving', 'warning');
                    }
                }
                
            }else if(state === 'ERROR'){
                component.set("v.spinner",false);
                console.log('Something went Wrong-- state ERROR!!');
            }else{
                component.set("v.spinner",false);
                console.log('Something went Wrong!!-- state--',state);
            }
            
        });
        $A.enqueueAction(action);
        
    },
    sendEmailHelper : function(component, event, helper) {
         component.set("v.spinner",true);
        var action = component.get("c.sendEscalationEmail");
        action.setParams({
            'taskObj' : component.get('v.TaskRec'),
        });
         action.setCallback(this, function(response){
           var state = response.getState();
            if(state === 'SUCCESS'){
                console.log('SUCCESS-- state--');
                component.set("v.spinner",false);
            }else if(state === 'ERROR'){
                component.set("v.spinner",false);
                console.log('Something went Wrong-- state ERROR!!');
            }else{
                component.set("v.spinner",false);
                console.log('Something went Wrong!!-- state--',state);
            }
        });
        $A.enqueueAction(action);
        
    },
    setReadWriteFields  : function(component, event, helper, result) {
        console.log('result..',result);
        // mapping read field api name and label
        var custs = [];
        var conts = result.map_ReadFields;
        for ( var key in conts ) {
            custs.push({value:conts[key], key:key});
        }  
        console.log('custs...',custs);
        component.set('v.readFieldsList',custs);
        // mapping write field api name and label
        var custs2 = [];
        var conts2 = result.map_WriteFields;
        for ( var key in conts2 ) {
            custs2.push({value:conts2[key], key:key});
        }
        console.log('custs2...',custs2);
        component.set('v.writeFieldsList',custs2);
    },
     showToast : function(component, mode, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "mode": mode,
            "title": title,
            "message": message,
            "type": type,
            "duration":'2'
        });
        toastEvent.fire();
    },
})