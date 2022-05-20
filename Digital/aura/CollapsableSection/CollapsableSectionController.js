({
    doinit : function(component, event, helper) { 
       var state= component.get("v.defaultState");
        if(state == 'close'){
            var sectionContainer = component.find('collapsibleSectionContainer');
             component.find('button').set('v.state', true);
            $A.util.removeClass(sectionContainer, "slds-is-open");
        }/*else{
            var sectionContainer = component.find('collapsibleSectionContainer');
            $A.util.addClass(sectionContainer, "slds-is-open");
        }*/
    },
    handleSectionHeaderClick : function(component, event, helper) {
        event.preventDefault();
        var button = event.getSource();
        button.set('v.state', !button.get('v.state'));
        var sectionContainer = component.find('collapsibleSectionContainer');
        $A.util.toggleClass(sectionContainer, "slds-is-open");
        
        let currentState = !button.get('v.state') ? 'open' : 'close';
        component.set("v.currentState",currentState);
    },
    
    handleBehaviour : function(component,event,helper) {
        let currentState = component.get("v.currentState");
        let defaultState = component.get("v.defaultState");
        
        if(currentState != defaultState){
            var button = component.find('button');
            button.set('v.state', !button.get('v.state'));
            var sectionContainer = component.find('collapsibleSectionContainer');
            $A.util.toggleClass(sectionContainer, "slds-is-open");
            component.set("v.currentState",defaultState);
        }
    }
})