({
	digitalLiveUsersJsHpr : function (component,helper){ 
        if(component.get("v.payLayoutId") != null && component.get("v.payLayoutId") !='' && component.get("v.payLayoutId") !=undefined){
            var action = component.get("c.digitalLiveUsers");
        action.setParams({
            'layoutId': component.get("v.payLayoutId")
        });        
        action.setCallback(this, function(result) {
            var state = result.getState();
            if(state === 'SUCCESS')
            {
                component.set("v.liveUsers",result.getReturnValue());
            }
        });
        $A.enqueueAction(action); 
        }else{
            var conts = [];
            component.set("v.liveUsers",conts);
        }        
    },
})