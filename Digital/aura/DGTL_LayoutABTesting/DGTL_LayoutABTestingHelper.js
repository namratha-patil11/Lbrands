({
	initHpr : function(component,event,helper) { 
        component.set("v.contColumns", [{label: 'Name', fieldName: 'Name', type: 'text'}]);
        component.set("v.selectedConts",component.get("v.cloneConts"));
        //Fetch the existing Test layout for the selected combination
        var action = component.get("c.fetchABTestLayouts");
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
                    var testlst = []; 
                    var ABTests = returnVal;
                    var TestId = component.get('v.selectedTest');  
                    for ( var key in ABTests ) {
                        if(TestId == key)
                            testlst.push({value:ABTests[key], key:key, selected : true});
                        else testlst.push({value:ABTests[key], key:key});
                    }
                    component.set('v.TestingList', testlst);
                    if(component.get("v.selectedTest") !=  '' && component.get("v.selectedTest") !=  'None' ){
                        component.set("v.recordId",component.get("v.selectedTest"));
                    }                    
                }
            }
        });
        $A.enqueueAction(action);
    },
     //Create new Testing Layout
    updateTestLayJsHpr : function(component,event,helper) {
        // check for null values 
        if(component.get('v.selectedTest') == '' && component.get('v.TestingName') == '' )
        {
            this.showToast(component,'dismissible','Failed','Test Name is Mandatory..!!','error');
        }else{
            if(component.get('v.selectedTest') == '' ){
                component.set("v.isNewLayout",true); 
            }
            var ABTesting = component.get('v.TestingList');
            for(var key in ABTesting)
            {
                if(ABTesting[key].key==component.get('v.selectedTest')){
                    component.set("v.TestingName",ABTesting[key].value); 
                }
            }
            var action = component.get("c.createTestLayout");
            action.setParams(
                {'selectedBrand'	: component.get('v.selectedBrand'),
                 'pageType'			: component.get('v.selectedPageType'),
                 'floorsetId'		: component.get('v.selectedFloorset'),
                 'deviceType'		: component.get('v.selectedDeviceType'),
                 'pageName'			: component.get('v.TestingNameUpdate'),
                 'selectedTest'		: component.get('v.selectedTest'),
                 'list_Content'		: component.get('v.cloneConts')}
            );
            action.setCallback(this,function(result){
                var state = result.getState();
                if(state === 'SUCCESS')
                {
                    var returnVal = result.getReturnValue();
                    if(returnVal !== undefined)
                    {
                        if(returnVal.includes('Error')){
                            this.showToast(component,'dismissible','Failed',returnVal,'error');
                        }else{
                            component.set('v.selectedTest', returnVal);
                            var TestPageName ;
                            if(component.get("v.TestingNameUpdate") != ''){
                                TestPageName = component.get("v.TestingNameUpdate");
                            }else{
                               TestPageName = component.get("v.TestingName");
                            }
                            var cmpEvent = component.getEvent("ABTestingId");
                            cmpEvent.setParams( { "openModal" : false,
                                                 "ABTestingId" : returnVal,
                                                 "isNewLayout" : component.get("v.isNewLayout"),
                                                 "ABTestingName"  : TestPageName} 
                                              );
                            cmpEvent.fire();                            
                        }
                        
                    }
                }
            });
            $A.enqueueAction(action);
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
})