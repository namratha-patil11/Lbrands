({
    /* fetchFloorsetJsHpr funcation to fetch all records, and set attributes value on component load */
    fetchFloorsetJsHpr : function(component,event){
        var placLayout = event.getParam("fields");   
        component.set("v.placementLayout",placLayout);
        console.log('--layout---'+placLayout.Brands__c+'--'+component.get("v.placementLayout.Brands__c")+'--'+placLayout.Page_Types__c+'--'+component.get("v.placementLayout.Page_Types__c"));
        console.log('---pageTypes--',component.get('v.pageTypes'));        console.log('---selectedDevices--',component.get('v.selectedDevices'));
        var selectedPages = [];        selectedPages = component.get('v.pageTypes');
        var selectedDevices = [];        selectedDevices = component.get('v.selectedDevices');
        if(selectedPages.includes('Editorials') && selectedPages.length >1){
            this.showToast(component,'dismissible','Failed','You can not Select Editorials with other Page Types','error');
        }else if(selectedPages.length > 0 && selectedDevices.length > 0){
            event.preventDefault();
            var action = component.get("c.fetchFloorsetWrapper");
            action.setParams({'placLayout':placLayout,
                              'startdate':component.get("v.startdate"),
                              'enddate':component.get("v.enddate"),
                              'PageTypes' :component.get('v.pageTypes'),
                              'deviceTypes' :component.get('v.selectedDevices')
                             });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS"){
                    var oRes = response.getReturnValue();
                    if(oRes.length > 0){
                        //component.set('v.listOfAllAccounts', oRes);
                        component.set('v.floorsetWrapper', oRes);
                        console.log('---oRes--',oRes);
                        var pageSize = component.get("v.pageSize");
                        var totalRecordsList = oRes;
                        var totalLength = totalRecordsList.length ;
                        component.set("v.totalRecordsCount", totalLength);
                        component.set("v.startPage",0);
                        component.set("v.endPage",pageSize-1);
                        
                        var PaginationLst = [];
                        for(var i=0; i < pageSize; i++){
                            if(component.get("v.floorsetWrapper").length > i){
                                PaginationLst.push(oRes[i]);    
                            } 
                        }
                        component.set('v.PaginationList', PaginationLst);
                        component.set("v.selectedCount" , 0);
                        //use Math.ceil() to Round a number upward to its nearest integer
                        component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));    
                    }else{
                        // if there is no records then display message
                        this.showToast(component,'dismissible','Failed','No Floorset/Update found ','error');
                        //component.set("v.bNoRecordsFound" , true);
                    } 
                }
                else{
                    alert('Error...');
                }
            });
            $A.enqueueAction(action);  
        }else{
            this.showToast(component,'dismissible','Failed','Please Select Page Types, Device Types for Search','error');
        }
        
    },
    
    getDependantPicklists : function(component,event){
        console.log('getDependantPicklists------');        
        var action = component.get("c.getDependentMap");
        action.setParams({'objDetail': component.get("v.placementLayout"),
                          'contrfieldApiName': 'Brands__c',
                          'depfieldApiName': 'Page_Types__c'
                         }); 
        action.setCallback(this,function(result){ 
            var state = result.getState();
            if(state === 'SUCCESS')
            {                    
                var returnVal = result.getReturnValue();
                if(returnVal != null && returnVal != undefined)
                {     
                    console.log('returnVal------',returnVal);
                    component.set("v.depnedentFieldMap",returnVal);
                    console.log('brand------',component.get('v.selectedBrand'));
                    if(component.get('v.selectedBrand') != '')
                    {	var brand = component.get('v.selectedBrand');
                     var list = returnVal[component.get('v.selectedBrand')];
                     component.set("v.bDisabledDependentFld" , false);  
                     this.fetchDepValues(component, list);    
                     component.set('v.selectedBrand',brand);
                    } 
                    
                }
                else
                {
                    this.showToast(component,'dismissible','Failed','Failed','error');
                }
            }else{ 
                component.set("v.spinner",true);
                var errors = result.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
        component.set("v.spinner",false);
        
    },
    fetchDepValues: function(component, ListOfDependentFields) {
        // create a empty array var for store dependent picklist values for controller field  
        var dependentFields = [];
        //dependentFields.push('--- None ---');
        for (var i = 0; i < ListOfDependentFields.length; i++) {
            var singleObj = {};
            singleObj.Id = ListOfDependentFields[i];
            singleObj.Name = ListOfDependentFields[i];
            singleObj.flag = false;
            dependentFields.push(singleObj);
        }
        // set the dependentFields variable values to store(dependent picklist field) on lightning:select
        console.log('--dependentFields--',dependentFields);
        component.set("v.listDependingValues", dependentFields);
        
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
    addContentsHpr : function(component,event,floorsetIds,selectedLayouts,mapFloorsetNLays ) {
        console.log('----selectedLayouts-----'+JSON.stringify(selectedLayouts));
        var action = component.get("c.cloneContentsToLayout");
        action.setParams({'placLayout': component.get("v.placementLayout"),
                          'list_CloneContents':component.get("v.clonePlacementContents"),
                          //'floorsetIds':floorsetIds,
                          'selectedLayouts' : selectedLayouts,
                          //'floorsetLayoutStringList' : mapFloorsetNLays
                          }); 
        action.setCallback(this,function(result){ 
            var state = result.getState();
            if(state === 'SUCCESS')
            {                    
                var returnVal = result.getReturnValue();
                if(returnVal.length > 0)
                {     
                    component.set('v.floorsetWrapper', returnVal);
                    var pageSize = component.get("v.pageSize");
                    var totalRecordsList = returnVal;
                    var totalLength = totalRecordsList.length ;
                    component.set("v.totalRecordsCount", totalLength);
                    component.set("v.startPage",0);
                    component.set("v.endPage",pageSize-1);
                    
                    var PaginationLst = [];
                    for(var i=0; i < pageSize; i++){
                        if(component.get("v.floorsetWrapper").length > i){
                            PaginationLst.push(returnVal[i]);    
                        } 
                    }
                    component.set('v.PaginationList', PaginationLst);
                    component.set("v.selectedCount" , 0);
                    //use Math.ceil() to Round a number upward to its nearest integer
                    component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));                     
                    
                }
                else
                {
                    component.set("v.spinner",false);
                    this.showToast(component,'dismissible','Failed','Failed','error');
                }
            }else{ 
                component.set("v.spinner",true);
                var errors = result.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    // navigate to next pagination record set   
    next : function(component,event,sObjectList,end,start,pageSize){
        var Paginationlist = [];
        var counter = 0;
        for(var i = end + 1; i < end + pageSize + 1; i++){
            if(sObjectList.length > i){ 
                //  if(component.find("selectAllId").get("v.value")){
                //     Paginationlist.push(sObjectList[i]);
                //  }else{
                Paginationlist.push(sObjectList[i]);  
                // }
            }
            counter ++ ;
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
    },
    // navigate to previous pagination record set   
    previous : function(component,event,sObjectList,end,start,pageSize){
        var Paginationlist = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++){
            if(i > -1){
                // if(component.find("selectAllId").get("v.value")){
                //  Paginationlist.push(sObjectList[i]);
                // }else{
                Paginationlist.push(sObjectList[i]); 
                // }
                counter ++;
            }else{
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
    },
    
    //Check for AB Test/Takedown/Contingency contents without parent content
    checkChildContentsHpr : function(component,event,helper){
        var conts = component.get("v.clonePlacementContents");
        var allConts = component.get("v.placementContents");
        var ContentsWithoutChild = [];
        var checkChildContsMsg = '';
        var parentIds = [];
        var childContsNoParent = false;
        var removedChildContents = [];
        var allChildIds = [];
        var selChildIds = [];
        var pIDs = [];
        var pConts = [];
        for(var key in conts){
            pIDs.push(conts[key].Id);
            pConts.push(conts[key]);
            if(conts[key].Parent_Content__c == undefined)
                parentIds.push(conts[key].Id);
            else
                selChildIds.push(conts[key].Id);
        }
        for(var key in allConts){
            var pContentRec = allConts[key].pContentRec;
            if(pContentRec.Parent_Content__c != undefined && !selChildIds.includes(pContentRec.Id) && parentIds.includes(pContentRec.Parent_Content__c))
                ContentsWithoutChild.push(pContentRec.Name);
            //allChildIds.push(allConts[key].Id);
        }
        component.set("v.ContentsWithoutChild",ContentsWithoutChild);
        for(var key in conts){
            if(conts[key].Parent_Content__c != undefined){
                // if(allChildIds.includes(conts[key].Id))
                if(!parentIds.includes(conts[key].Parent_Content__c)){
                    childContsNoParent = true;
                    removedChildContents.push(conts[key].Type__c+' For  '+conts[key].Name);
                    //conts.splice(conts[key],1);
                    pConts.splice(pIDs.indexOf(conts[key].Id),1);
                    pIDs.splice(conts[key].Id,1);
                }
            }
        }
        if(childContsNoParent){
            checkChildContsMsg = 'Cannot clone AB Test/Takedown/Contigency contents without selecting the original placement library';
            component.set("v.checkChildContsMsg",checkChildContsMsg);
            component.set("v.clonePlacementContents",pConts);
            component.set("v.removedChildContents",removedChildContents); 
        }else{
            component.set("v.checkChildContsMsg",'');
            var removedChildCont = [];
            component.set("v.removedChildContents",removedChildCont); 
        }
        
        
    }
})