({
    // Your renderer method overrides go here
    
    afterRender: function(component, helper) {
        this.superAfterRender();
        var myPageRef = component.get("v.pageReference");
        component.set("v.recordId", myPageRef.state.c__contentId);
        console.log('parentContentId....after render...',component.get("v.recordId"));
        
        if(component.get("v.recordId") != null ){
            console.log('parentContentId....after render...',component.get("v.recordId"));
              helper.fetchAllContentsHpr(component,event,true);
        }       
    }
})