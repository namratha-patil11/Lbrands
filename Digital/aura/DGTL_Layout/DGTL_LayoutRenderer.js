({
	afterRender: function(component, helper) {
        this.superAfterRender();
        console.log(document.URL);
        var myPageRef = component.get("v.pageReference");
        component.set("v.placementLayout", myPageRef.state.c__layout);
        component.set("v.isPageRefrence", myPageRef.state.c__ispageReference);
        
        console.log('layout Id---',myPageRef.state.c__layoutId);
        if( myPageRef.state.c__Brands == ''){
            console.log('fetching layout details');
            helper.CallfetchSearchfields(component,myPageRef.state.c__layoutId);
        }
        else{
            var Layout = [];
            Layout.push({'sobjectType':'Placement_Layout__c','Brands__c': myPageRef.state.c__Brands,
                         'Page_Types__c' : myPageRef.state.c__Page_Types ,'Floorset_Plan__c' : myPageRef.state.c__Floorset_Plan,
                         'Device_Type__c' : myPageRef.state.c__DeviceType});
            
            component.set("v.placementLayout",Layout[0]);
            var isTrue = component.get("v.isPageReference");
            if(myPageRef.state.c__ispageReference){
                helper.CallfetchContentJsHpr(component,'Search',myPageRef.state.c__layout);
            }       
        }
        
    }
})