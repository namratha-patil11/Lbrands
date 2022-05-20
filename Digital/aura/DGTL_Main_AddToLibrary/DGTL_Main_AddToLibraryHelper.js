({
	initHpr : function(component,event) {
		var action = component.get("c.fetchlibFields");
        action.setCallback(this,function(result){
            var state = result.getState();            
            if(state === 'SUCCESS')
            {
                var returnVal = result.getReturnValue();
                if(returnVal != undefined)
                {                                       
                   component.set("v.libFieldSet",returnVal);
                }
            }
        });
        $A.enqueueAction(action);
    },
    addLibraryHpr : function(component,event,helper) {
        component.set("v.spinner1",true);
        var params = event.getParams();
		var action = component.get("c.createLibAndContent");
        action.setParams({'placLibrId':params.response.id,'pLayoutId':component.get("v.pLayoutId")});
        action.setCallback(this,function(result){
            var state = result.getState();            
            if(state === 'SUCCESS')
            {
                var returnVal = result.getReturnValue();
                if(returnVal != undefined)
                {
                    component.set("v.spinner1",false);
                    var cmpEvent = component.getEvent("AddLibrary");
                    cmpEvent.setParams( { "AddLibrary" : returnVal,"openModal" : false } );
                    cmpEvent.fire();
                    //component.destroy(); 
                }
            }
        });
        $A.enqueueAction(action);
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
