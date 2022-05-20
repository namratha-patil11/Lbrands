({
	doinit : function(component, event, helper) {
       
       var LibraryId = component.get("v.recordId");
       helper.cascadeAction(component, event, LibraryId);
        
	}
})