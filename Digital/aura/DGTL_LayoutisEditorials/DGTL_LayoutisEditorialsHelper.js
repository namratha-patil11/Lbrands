({
    initHpr : function(component,event,helper) {       
        component.set("v.isNewLayout",false);
        //Fetch the existing Editorials for the selected combination 
        var action = component.get("c.fetchEditorialLayouts");
        action.setParams({'selectedBrand' : component.get('v.selectedBrand'),
                          'pageType'      : component.get('v.selectedPageType'),
                          'floorsetId'    : component.get('v.selectedFloorset'),
                          'deviceType'    : component.get('v.selectedDeviceType')});
        action.setCallback(this,function(result){
            var state = result.getState();
            if(state === 'SUCCESS')
            {
                var returnVal = result.getReturnValue();
                if(returnVal !== undefined)
                {
                    // mapping editorial name and id
                    var editoriallst = []; 
                    var editorials = returnVal;
                    var editorialId = component.get('v.selectedEditorialsearch');  
                    for ( var key in editorials ) {
                        if(editorialId == key)
                            editoriallst.push({value:editorials[key], key:key, selected : true});
                        else editoriallst.push({value:editorials[key], key:key});
                    }
                    component.set('v.editorialLayoutsList', editoriallst);
                    if(component.get("v.selectedEditorialsearch") !=  '' && component.get("v.selectedEditorialsearch") !=  'None'){                       
                       this.fetchEditorialHpr(component,event);
                    }/*else{
                        component.set('v.editorialPageName', '');
                    	component.set('v.collectionPageUrl', '');
                    } */ //--- commented by np                    
                }
            }
        });
        $A.enqueueAction(action);
    },
    //Search the layout
    searchEditorialHpr : function(component,event,helper) {
        // check for null values 
        var editorialId = '';
        if( (component.get('v.editorialPageName') == '' || component.get('v.collectionPageUrl') == '') && (component.get('v.selectedEditorialsearch') == '' || component.get('v.selectedEditorialsearch') == 'None') )
        {
            this.showToast(component,'dismissible','Failed','Editorial Name and  collection Page Url Mandatory..!!','error');
        }else{
            // checks for new layout or existing layout
            if(component.get('v.selectedEditorialsearch') == '' || component.get('v.selectedEditorialsearch') == 'None'){
                component.set("v.isNewLayout",true); 
            }else{
                component.set("v.isNewLayout",false);
                editorialId = component.get('v.selectedEditorialsearch');
            }
        //Passing the selected Page to Parent Layout Component
        var cmpEvent = component.getEvent("editorialId");
        cmpEvent.setParams( 
            { "openModal" : false,
             "editorialId" : editorialId,
             "isNewLayout" : component.get("v.isNewLayout"),
             "editorialPageName"  : component.get('v.editorialPageName'),
             "editorialcollectionPageUrl"  : component.get('v.collectionPageUrl')} 
        );
        cmpEvent.fire();
        }
        
    },    
    showToast : function(component, mode, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "mode": mode,
            "title": title,
            "message": message,
            "type": type,
            "duration":'2'
        });
        toastEvent.fire();
    },
    fetchEditorialHpr : function(component,event) { 
        //Fetch the existing Editorials for the selected combination
        var action = component.get("c.fetchEditorial");
        action.setParams({'selectedEditorial' : component.get('v.selectedEditorialsearch')});
        action.setCallback(this,function(result){
            var state = result.getState();
            if(state === 'SUCCESS')
            {
                var returnVal = result.getReturnValue();
                if(returnVal !== undefined)
                {
                    // mapping editorial name and collection page url                   
                    component.set('v.editorialPageName', returnVal.Collection_Page_Name__c);
                    component.set('v.collectionPageUrl', returnVal.Collection_Page_Url__c);
                                       
                }
            }
        });
        $A.enqueueAction(action);
    },
})