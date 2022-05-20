({
    doInit : function(component, event, helper) {
        console.log(component.get("v.objId"));
        helper.initHelper(component, event);
    },
    handleClose : function(component, event, helper) {
        component.getEvent("closePrompt").setParams({
            'close' : false
        }).fire();
    },
    ShowDetail : function(component, event, helper) {
        console.log('....view detail');
         var target = event.target;
        var index = target.getAttribute("data-selected-Index");
        console.log('index....',index);
        
        var ctarget = event.currentTarget;
        var cur_RecId = ctarget.dataset.value; 
        console.log('cur_Rec--',cur_RecId);
        
        var map_Records = component.get("v.historyRecords");
        var curView = map_Records[cur_RecId];
	    console.log('map obj ----'+JSON.stringify(curView));
        
        component.set("v.viewRecord",curView);
        component.set("v.history",false);
        component.set("v.viewId",cur_RecId);
        
        var apiString = component.get("v.changedValues")[index];
        var apiList = apiString.split(",");
        component.set("v.valueFieldApi",apiList);
        
        console.log('value apis...',component.get("v.valueFieldApi"));
        
    },
    closeView : function(component, event, helper) {
        component.set("v.history",true);
    },
    handleReplaceValues : function(component, event, helper) {
        console.log('replace....');
        /*
        var recordId = component.get("v.viewId");
        var valueList = component.get("v.valueFieldApi");
        
        console.log('recordId....',recordId);
        console.log('valueList....',valueList);
        
        var map_Records = component.get("v.historyRecords");
        var curView = map_Records[recordId];
        console.log('map obj ----'+JSON.stringify(curView));
        console.log('curView.Asset_Path__c...',curView.Asset_Path__c);
        
        var parentRecord = component.get("v.replaceRecordValue");
        
        var action = component.get("c.replaceValues");
        action.setParams({
            'parentId' : component.get("v.objId"),
            'SourceRec' : curView,
            'valuesToReplace' : valueList
        });
        action.setCallback(this,function(response){
             var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.spinner",false);
                console.log('SUCCESS');  
                var result = response.getReturnValue();
                component.set("v.replaceRecordValue",result);
                
                component.getEvent("closePrompt").setParams({
                    'close' : false,
                    'replacedContentDetail' : result,
                    'index' : component.get("v.recordIndex")
                }).fire();
                
                
                
            }else if(state === 'ERROR'){
                component.set("v.spinner",false);
                console.log('ERROR');  
            }
            
        });
        $A.enqueueAction(action); */
        
    },
})