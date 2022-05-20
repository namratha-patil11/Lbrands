({
	init : function(component, event, helper) {
        component.set("v.spinner",true);
        //component.set('v.editorialPageName', '');//--- commented by np   
        //component.set('v.collectionPageUrl', '');//--- commented by np   
        component.set("v.isNewLayout",false);
        helper.initHpr(component, event);       
        component.set("v.spinner",false);
    },
    searchEditorial : function(component, event, helper) {
        helper.searchEditorialHpr(component, event, helper);        
    },    
    closeModalBox : function(component, event, helper) {
        var cmpEvent = component.getEvent("openModal");
        cmpEvent.setParams( { "openModal" : false } );
        cmpEvent.fire();
    },    
    getEditorial : function(component,event,helper){
        component.set("v.spinner",true);
        if(component.get("v.selectedEditorialsearch") !=  'None' && component.get("v.selectedEditorialsearch") !=  '')
        {
            helper.fetchEditorialHpr(component,event)
        }else{
            component.set('v.editorialPageName', '');
            component.set('v.collectionPageUrl', '');
        }
        component.set("v.spinner",false);
    },
})