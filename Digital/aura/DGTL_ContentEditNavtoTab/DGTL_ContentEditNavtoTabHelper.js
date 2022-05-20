({
    cascadeAction : function(component,event,contentId) {
        var pageReference = {
            type: 'standard__navItemPage',
            attributes: {
                //componentName: 'c__Cascade_Content',
                apiName: 'ContentsEdit',
            },
            state: {
                "c__contentId": contentId,
            }
        };        
        component.set("v.pageReference", pageReference); 
        var navService = component.find("navService");
        var pageReference = component.get("v.pageReference");
        
        //--- getting URL from the pagerefrence to navigate to it in new Tab.
        navService.generateUrl(pageReference).then($A.getCallback(function(url) {
            component.set("v.url", url ? url : "#");
            $A.get("e.force:closeQuickAction").fire();            
            window.open( 'https:'+url, '_blank' );//open component in new tab
        }), $A.getCallback(function(error) {
            console.log('Error opening URL:--',url);
            component.set("v.url", "#");            
        })); 
    }
})