({
	init : function(component, event, helper) {
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('MB-Back'); 
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open');
        helper.initHpr(component, event);          
    },
    addLibrary : function(component, event, helper) {
       helper.addLibraryHpr(component, event,helper);
	},
    allowClone : function(component, event, helper) {
        console.log('--getLocalId--',event.getSource().getLocalId());
        if(event.getSource().getLocalId() == 'Allow Clone'){
            component.set("v.cloneThisContent",true);
        }
    },
    closeLibraryModel : function(component, event, helper) {
        //$A.get('e.force:refreshView').fire();
         //component.destroy();
         var cmpEvent = component.getEvent("AddLibrary");
         cmpEvent.setParams( { "openModal" : false } );
         cmpEvent.fire();
    },
    validateOnSubmit : function(component, event, helper) {
        component.set("v.spinner1",true);
        setTimeout(function(){
            event.preventDefault(); // stop form submission
            var eventFields = event.getParam("fields");
            var pageType =  eventFields["Page_Types__c"];
            var editorialName =  eventFields["Editorial_Name__c"];
            if(pageType ==='Editorials' && (editorialName == null || editorialName == '' || editorialName == undefined)){
                helper.showToast(component,'dismissible','Failed!!','Please fill Editorial Name!!','error');
            }else{
                component.set("v.spinner1",true);
                component.find('myform').submit(eventFields);
                component.set("v.spinner1",false);
            }
        }, 3000);
    }
})
