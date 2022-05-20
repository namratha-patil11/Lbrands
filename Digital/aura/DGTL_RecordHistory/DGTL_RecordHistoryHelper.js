({
	initHelper : function(component, event) {
        component.set("v.spinner",true);
        console.log('record id---',component.get("v.objId"));
		var action = component.get("c.getHistoryRecords");
        action.setParams({
            'objectId' : component.get("v.objId")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.spinner",false);
                console.log('SUCCESS');  
                var result = response.getReturnValue();
                console.log('result---',result);
                
                var changedFields = result.list_HistoryRecords;
                var map_changedRec = result.Map_ChangedRecords;
                var list_changedValues = result.list_ChangedValue;
                var map_changedContRec =result.Map_ChangedContentRecords;
                
                console.log('list_changedValues...',list_changedValues);
                console.log('map_changedRec.....',map_changedRec);
                
                if(map_changedContRec != null || map_changedContRec != undefined)
                component.set("v.contentHistoryRecords",map_changedContRec);
                
                if(map_changedRec != null || map_changedRec != undefined)
                component.set("v.historyRecords",map_changedRec);
                
                component.set("v.changedFields",changedFields);
                component.set("v.changedValues",list_changedValues);
                component.set("v.objectName",result.objectName);
                
            }else if(state === 'ERROR'){
                component.set("v.spinner",false);
                console.log('ERROR');  
            }
            
        });
        $A.enqueueAction(action);
	}
})