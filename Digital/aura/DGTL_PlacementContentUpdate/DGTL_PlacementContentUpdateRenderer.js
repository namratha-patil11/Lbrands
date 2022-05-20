({
	afterRender: function(component, helper) {
        this.superAfterRender();
        var myPageRef = component.get("v.pageReference");
        component.set("v.parentContentId", myPageRef.state.c__ContentId);
        component.set("v.isPageRefrence", myPageRef.state.c__ispageReference);
        
        if(component.get("v.parentContentId") != null && component.get("v.parentContentId") != 'undefined'){
             console.log('parentContentId....after render...',component.get("v.parentContentId"));
            helper.initHelper(component,event,helper);
        }       
    }
})