({
	checkFeedEnabled : function(component, event, helper) {
        component.set("v.showSpinner",true);
        var action = component.get("c.isFeedEnabled");
        action.setParams({
            objName : component.get("v.objApiName"),
            recId : component.get("v.recId")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                let result = response.getReturnValue();
                let cmpTarget = component.find("followbtn");
                component.set("v.isFeedEnabled",result['isFeedEnabled']);
                component.set("v.buttonstate",result['isFollowed']);
                if(component.get("v.buttonstate")){
                    component.set("v.color","#7dcf64");
                    component.set("v.nextAction",'UnFollow');
                    component.set("v.iconName","action:following");
                }else{
                     component.set("v.color","#31b9f8");
                }
            }else if(state === 'ERROR'){
                this.showToast(component, event, helper,response.getError()[0].message, "error");
            }
            component.set("v.showSpinner",false);
        });
        $A.enqueueAction(action);
	}, 
    
    followUnfollow : function(component, event, helper) {
        component.set("v.showSpinner",true);
        var buttonstate = component.get('v.buttonstate');
        var action = component.get("c.setSubscription");
        action.setParams({
            recId : component.get("v.recId"),
            follow : !buttonstate
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set('v.buttonstate', !buttonstate);
                if(component.get("v.buttonstate")){
                    component.set("v.color","#7dcf64");
                }else{
                    component.set("v.color","#31b9f8");
                }
                let nextAction = component.get("v.buttonstate") ? 'UnFollow' : 'Follow';
                let iconName = component.get("v.buttonstate") ? 'action:following' : 'action:follow';
                component.set("v.nextAction",nextAction);
                component.set("v.iconName",iconName);
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