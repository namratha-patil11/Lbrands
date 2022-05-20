({
	init : function(component, event, helper) {        
        //execute callApexMethod() again after 5 sec each
        window.setInterval(
            $A.getCallback(function() { 
                helper.digitalLiveUsersJsHpr(component,helper);
            }), 5000
        );
    },
    showUsers : function(component, event, helper)  {
        var sectionContainer = component.find('userList');
        $A.util.toggleClass(sectionContainer, "slds-hide");
    },
    hideUsers : function(component, event, helper)  {
        var sectionContainer = component.find('userList');
        $A.util.toggleClass(sectionContainer, "slds-hide");
    },
})