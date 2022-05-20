({
    doInitHelper : function(component, event) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.getLayoutId");
        action.setParams({
            'RecordId'  : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
           var state = response.getState();
            if(state === 'SUCCESS'){
                var result = response.getReturnValue();
                this.navigate(component, event,result);
            }else if (state === 'ERROR'){
                console.log('Error---State');
            }
        });
        $A.enqueueAction(action);
    },
    navigate : function(component, event,layoutRecId){
        var pageReference = {
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'Layouts',
            },
            state: {
                "c__Brands" : '',
                "c__layoutId" : layoutRecId,
            }
        };
        component.set("v.pageReference", pageReference);
        console.log('navigating to Layout');
        var navService = component.find("navService");
        var pageReference = component.get("v.pageReference");
              
        //--- getting URL from the pagerefrence to navigate to it in new Tab.
        navService.generateUrl(pageReference).then($A.getCallback(function(url) {
            console.log('url --- in get callback--',url);
            component.set("v.url", url ? url : "#");
            //---- open url in same tab
            window.open(
                'https:'+url,
                '_self'
            );
        }), $A.getCallback(function(error) {
            component.set("v.url", "#");
        })); 
    }
})