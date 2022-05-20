({
	init : function(component, event, helper) {
        console.log('-------clone contents---',component.get("v.clonePlacementContents"));
	    component.set("v.placementLayout.Page_Types__c",component.get("v.defaultPageType"));
	   // component.set("v.placementLayout.Device_Type__c",component.get("v.defaultDevice"));
	    component.set("v.defaultDevice",[]);
	    component.set("v.placementLayout.Brands__c",component.get("v.selectedBrand"));
	    component.set("v.checkChildContsMsg",'');
        var Colorobj=[{"Id":"Desktop","Name":"Desktop","flag":false},
                      {"Id":"Mobile","Name":"Mobile","flag":false},
                     ];
        component.set("v.deviceTypeList",Colorobj);
        var removedChildContents = [];
        component.set("v.removedChildContents",removedChildContents);
	    helper.checkChildContentsHpr(component, event, helper);
		helper.getDependantPicklists(component,event);

    },
    fetchFloorsetJs : function(component, event, helper) {
        component.set("v.spinner",true);
        helper.fetchFloorsetJsHpr(component, event,helper);
        component.set("v.spinner",false);
    },
    cloneEditorial: function(component, event, helper) {
        var floorlst = [];
        component.set("v.floorsetWrapper",floorlst);
        component.set("v.PaginationList",floorlst);
        component.set("v.selectedRows",floorlst);
        component.set("v.selectedCount",0);
        component.set("v.totalRecordsCount",0);
        var params = event.getParams();
        console.log('---pageTypes---cloneEditorial--',component.get('v.pageTypes'));
        //if(params.value=='Editorials')
        let pageType = component.get('v.pageTypes');
        if(pageType && pageType.includes('Editorials')){
            /*console.log('1----'+JSON.stringify(component.get('v.pageTypes')));
            if(pageType.length == 1){
                component.set("v.isEditorialsClone",true);
            }else{
                helper.showToast(component,'dismissible','Failed','You can not Select Editorials with other Page Types','error');
                pageType.pop();
                console.log('pageType----',pageType);
                component.set("v.pageTypes",pageType);
                if(pageType.includes('Editorials')) component.set("v.isEditorialsClone",true);
            }*/
            component.set("v.isEditorialsClone",true);
        }
        else
        component.set("v.isEditorialsClone",false); 
    },
    clearValues: function(component, event, helper) {
        var controllerValueKey = component.get('v.selectedBrand'); // get selected controller field value
        var depnedentFieldMap = component.get("v.depnedentFieldMap");
        console.log('-depnedentFieldMap--',depnedentFieldMap);
        console.log('-controllerValueKey--',controllerValueKey);
        if (controllerValueKey != '' && depnedentFieldMap != null) {
            var ListOfDependentFields = depnedentFieldMap[controllerValueKey];
            
            if(ListOfDependentFields.length > 0){
                component.set("v.bDisabledDependentFld" , false);  
                helper.fetchDepValues(component, ListOfDependentFields);    
            }else{
                component.set("v.bDisabledDependentFld" , true); 
            }  
            
        } else {
            component.set("v.bDisabledDependentFld" , true);
        }
        var floorlst = [];
        component.set("v.floorsetWrapper",floorlst);
        component.set("v.PaginationList",floorlst);
        component.set("v.selectedRows",floorlst);
        component.set("v.selectedCount",0);
        component.set("v.totalRecordsCount",0);
    },
    addContents : function(component, event, helper) {
        component.set("v.spinner",true);
        var erroMessage = '';
        var allRecords = component.get("v.floorsetWrapper");
        console.log('-------allRecords----',allRecords);
        var selectedRecords = [];
        var selectedLayouts = [];
        var mapFloorsetNLays = [];
        for (var i = 0; i < allRecords.length; i++) {
            if (allRecords[i].isSelected) {
                selectedRecords.push(allRecords[i].floorsetId);
               
                //if(allRecords[i].layoutTobeAdded != '')
                //mapFloorsetNLays.push(allRecords[i].layoutTobeAdded+' - '+allRecords[i].floorsetId);
                //else  selectedLayouts.push(allRecords[i].layout);
                selectedLayouts.push(allRecords[i].layout);
            }
        }
        if(selectedRecords == '' || selectedRecords.length == 0 ){
            erroMessage += 'Select atleast one Floorset/Update';
        }
        if(component.get("v.isEditorialsClone") && component.get("v.editorialCollecName") == '')
        {
            if(erroMessage != '')
            erroMessage += ' and Editorial Name is Mandatory !!';
            else
            erroMessage += 'Editorial Name is Mandatory !!';
        }
        if(erroMessage == ''){
            helper.addContentsHpr(component, event,selectedRecords,selectedLayouts,mapFloorsetNLays);
            component.set("v.spinner",false);
        }
        else{
            component.set("v.spinner",false);            
            helper.showToast(component,'dismissible','Failed',erroMessage,'error');
        }
    },
    closeModalBox : function(component, event, helper) {
        component.set("v.checkChildContsMsg",'');
        var removedChildContents = [];
        component.set("v.removedChildContents",removedChildContents);
        var cmpEvent = component.getEvent("openModal");
        cmpEvent.setParams( { "openModal" : false } );
        cmpEvent.fire();
    },
    /* javaScript function for pagination */
    navigation: function(component, event, helper) {
        var sObjectList = component.get("v.floorsetWrapper");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var whichBtn = event.getSource().get("v.name");
        // check if whichBtn value is 'next' then call 'next' helper method
        if (whichBtn == 'next') {
            component.set("v.currentPage", component.get("v.currentPage") + 1);
            helper.next(component, event, sObjectList, end, start, pageSize);
        }
        // check if whichBtn value is 'previous' then call 'previous' helper method
        else if (whichBtn == 'previous') {
            component.set("v.currentPage", component.get("v.currentPage") - 1);
            helper.previous(component, event, sObjectList, end, start, pageSize);
        }
    },
    checkboxSelect: function(component, event, helper) {
        // on each checkbox selection update the selected record count 
        var selectedRec = event.getSource().get("v.value");
        var getSelectedNumber = component.get("v.selectedCount");
        if (selectedRec == true) {
            getSelectedNumber++;
        } else {
            getSelectedNumber--;
        }
        component.set("v.selectedCount", getSelectedNumber);
    },
    EdtName : function(component, event, helper) {
        component.set("v.placementLayout.Collection_Page_Name__c",event.getParam("value"));
    },
    CollecUrl : function(component, event, helper) {
        component.set("v.placementLayout.Collection_Page_Url__c",event.getParam("value"));
    },
})