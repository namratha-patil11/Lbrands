({
   
    initHpr : function(component, event) {
        // GET logged in user brand 
        var action = component.get("c.getUserBrandHpr");
        action.setCallback(this,function(result){
            var state = result.getState();
            if(state === 'SUCCESS')
            {                 
               if(result.getReturnValue() != null && result.getReturnValue() != '' && result.getReturnValue() != undefined)
               component.set("v.selectedBrand",result.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        component.set("v.spinner",true);
        var action = component.get("c.setUpValues");
        action.setCallback(this,function(result){
            if(result.getState() === 'SUCCESS')
            {
                var res = result.getReturnValue();
                component.set("v.pageTypes",res.PageType);
                component.set("v.brand",res.Brands);
                component.set("v.spinner",false);
            }
            else
            {
                component.set("v.spinner",false);
                this.showToast(component,'dismissible','Failed',result.getError()[0].message,'error');
            }
        });
        $A.enqueueAction(action);
    },
    
    getUserPreference: function(component, event) {
        component.set("v.spinner",true);
        var action = component.get("c.getUserPreferenceSettings");
        action.setParams({
            'brand': component.get("v.selectedBrand")
        });
        action.setCallback(this,function(result){
            if(result.getState() === 'SUCCESS'){
                let preference = JSON.parse(result.getReturnValue());
                let options = preference.options || [];
                //console.log(JSON.stringify(options));
                 this.getLockedDetailFields(component).forEach(element => {
                    options.push(element);
                });
                preference.options = options;
                component.set("v.userPreferences",preference);
               // console.log(JSON.stringify(component.get("v.userPreferences")));
                component.set("v.selectedValues",preference.selectedOptions);
                component.set("v.hasAccessManagement",true);
            }else{
                component.set("v.hasAccessManagement",false);
                this.showToast(component,'dismissible','Failed',result.getError()[0].message,'error');
            }
            component.set("v.spinner",false);
        });
        $A.enqueueAction(action);
    },
    
    fetchLayoutRecHpr : function(component, event, layoutId) {
        component.set("v.spinner",true);
        var action = component.get("c.fetchLayoutData");
        action.setParams({
            'layoutId': layoutId
        });
        action.setCallback(this,function(result){
            if(result.getState() === 'SUCCESS')
            {
                if(result.getReturnValue() != undefined)
                {
                    var record = result.getReturnValue();
                    console.log("record---",record);
                    component.set("v.layoutRec",result.getReturnValue());
                    component.set("v.spinner",false);
                    this.navigateToLayout(component, event,record);
                }
            }else{
                component.set("v.spinner",false);
            }
        });
        $A.enqueueAction(action);
    },
    navigateToLayout : function(component, event, layoutRec) {
        if(layoutRec.Brands__c != '' && layoutRec.Page_Types__c != '' && layoutRec.Floorset_Plan__c != null){
            var pageReference = {
                //type: 'standard__component',
                type: 'standard__navItemPage',
                attributes: {
                    //componentName: 'c__DGTL_MainCmpNew',
                    apiName: 'Layouts',
                },
                state: {
                    "c__layout": layoutRec,
                    "c__ispageReference" : "true",
                    "c__Brands" : layoutRec.Brands__c,
                    "c__Page_Types" : layoutRec.Page_Types__c,
                    "c__Floorset_Plan" : layoutRec.Floorset_Plan__c,
                    "c__layoutId" : layoutRec.Id,
                    "c__DeviceType" : component.get("v.deviceType")
                }
            };
            component.set("v.pageReference", pageReference);
            
            console.log('navigating to Layout');
            var navService = component.find("navService");
            var pageReference = component.get("v.pageReference");
            event.preventDefault();
            //navService.navigate(pageReference);
            
            //--- getting URL from the pagerefrence to navigate to it in new Tab.
            navService.generateUrl(pageReference).then($A.getCallback(function(url) {
                console.log('url --- in get callback--',url);
                component.set("v.url", url ? url : "#");
                //---- open url in new tab
                window.open(
                    'https:'+url,
                    '_blank' // <- This is what makes it open in a new window.
                );
            }), $A.getCallback(function(error) {
                console.log('url --- in get error--',url);
                component.set("v.url", "#");
            }));
        }
        else{
            this.showToast(component,'dismissible','Failed','Layout does not have all the required fields..!!','error');
        }
    },
    
    fetchLayoutsHpr : function(component, event) {
        var allValid = component.find('field').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        
        let editorialName = component.get("v.editorialName");
        allValid = component.get("v.selectedPageType") == 'Editorials' && 
            (editorialName == null || editorialName == '' || editorialName == undefined) ? false : allValid;
        
        if(allValid)
        {
            component.set("v.spinner",true);
            let userPref = component.get("v.userPreferences");
            let lockedDetailFields = component.get("v.lockedDetailFields");
            userPref.selectedOptions = userPref.selectedOptions.filter( ( el ) => !lockedDetailFields.includes( el ) );
            console.log('userPref----'+JSON.stringify(userPref));
            var action = component.get("c.fetchData");
            action.setParams({
                'brand':component.get("v.selectedBrand"),
                'pageType':component.get("v.selectedPageType"),
                'startDate':component.get("v.startDateVal"),
                'endDate':component.get("v.endDateVal"),
                'deviceType':component.get("v.deviceType"),
                'editorialName':component.get("v.editorialName"),
                'userPreferenceJSON' : JSON.stringify(userPref) 
            });
            action.setCallback(this,function(result){
                if(result.getState() === 'SUCCESS')
                {
                    if(result.getReturnValue() != undefined)
                    {
                        component.set("v.finalData",result.getReturnValue());
                        //console.log("finalData----"+JSON.stringify(result.getReturnValue()));
                        component.set("v.spinner",false);
                    }
                    else
                    {
                        component.set("v.spinner",false);
                        this.showToast(component,'dismissible','Failed',result.getError()[0].message,'error');
                    }
                }
                else
                {
                    component.set("v.spinner",false);     
                    this.showToast(component,'dismissible','Failed',result.getError()[0].message,'error');
                }
            });
            $A.enqueueAction(action);
        }
        else
        {
            component.set("v.spinner",false);  
            this.showToast(component,'dismissible','Failed','Fill all required fields..!!','error');
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
    
    getEditorialOption :function(component,event,helper,isInit){
        let getEditorialNames = component.get("c.getEditorialNames");
        getEditorialNames.setParams({
            isInit : isInit,
            searchString : component.get("v.editorialTypeahead"),
            brand : component.get('v.selectedBrand')
        });
        getEditorialNames.setCallback(this, function(response) {
            let responseData = response.getReturnValue() || {};
            if (response.getState() === "SUCCESS" && responseData.isSuccess) {
                let editorialNameOption = JSON.parse(responseData.response);
                component.set("v.editorialNameOption", editorialNameOption);
            } else {
                this.showToast(component,'dismissible','Failed','Unknown Error','error');
            }
        });
        
        $A.enqueueAction(getEditorialNames);
    },
    
    saveCompareSetup :function(component,event){
        component.set("v.spinner",true);
        let userPref = component.get("v.userPreferences");
        let lockedDetailFields = component.get("v.lockedDetailFields");
        userPref.selectedOptions = userPref.selectedOptions.filter( ( el ) => !lockedDetailFields.includes( el ) );
        let action = component.get("c.saveUserPreference");
        action.setParams({
            preferenceJSON : JSON.stringify(userPref)
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                let preference = JSON.parse(response.getReturnValue());
                let options = preference.options || [];
                this.getLockedDetailFields(component).forEach(element => {
                    options.push(element);
                });
                preference.options = options;
                component.set("v.userPreferences",preference);
                component.set("v.selectedValues",preference.selectedOptions);
                this.showToast(component,'dismissible','Success!','Your preferences has been updated successfully!','success');
            } else {
                this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
            }
            component.set("v.spinner",false);
        });
        
        $A.enqueueAction(action);
    },
    
    setAcknowledgement:function(component,event,layout,layoutIndex){
        component.set("v.spinner",true);
        let action = component.get("c.saveAcknowledgeRecord");
        action.setParams({
            layoutId : layout[layoutIndex].plcLayout.Id
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                layout[layoutIndex].showChanges = false;
                for(var index in  layout[layoutIndex].list_plcContentWpr){
                        layout[layoutIndex].list_plcContentWpr[index].showChanges = false;
                }
                component.set("v.finalData.list_pLayoutWpr",layout);
                this.showToast(component,'dismissible','Success!','Acknowledged successfully!','success');
            } else {
                this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
            }
            component.set("v.spinner",false);
        });
        
        $A.enqueueAction(action);
    },
    
    getContentHistory:function(component,event,idCombo){
        component.set("v.spinner",true);
        let ids = idCombo.split('-');
        let action = component.get("c.getHistory");
        action.setParams({
            layoutId : ids[0],
            contentId : ids[1],
            brand : component.get("v.selectedBrand")
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                let records = response.getReturnValue();
                if(records['All'] && records['All'].length > 0){
                    let historyRec = [];
                    for(var index in records['All']){
                         records['All'][index].LastModifiedByName = records['All'][index].LastModifiedBy.Name;
                        historyRec.push( records['All'][index]);
                    }
                    component.set("v.historyRecords",historyRec);
                    //console.log(JSON.stringify(component.get("v.historyRecords")));
                    component.set("v.viewHistory",true);
                }else{
                    this.showToast(component,'dismissible','','No Records Found!!','success');
                }
            } else {
                this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
            }
            component.set("v.spinner",false);
        });
        
        $A.enqueueAction(action);
    },
    
    getContentWithHistory:function(component,layoutIndex){
        component.set("v.spinner",true);
        let layout = component.get("v.finalData.list_pLayoutWpr");
        let action = component.get("c.getContentHasHistory");
        action.setParams({
            layoutId : layout[layoutIndex].plcLayout.Id,
            brand : component.get("v.selectedBrand")
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                let contentIdsHasHistory = JSON.parse(response.getReturnValue());
                if(contentIdsHasHistory && contentIdsHasHistory.length > 0){
                    layout[layoutIndex].showChanges = true;
                   	for(var index in  layout[layoutIndex].list_plcContentWpr){
                        if(contentIdsHasHistory.includes(layout[layoutIndex].list_plcContentWpr[index].plcContent.Id)){
                            layout[layoutIndex].list_plcContentWpr[index].showChanges = true;
                        }
                    }
                    component.set("v.finalData.list_pLayoutWpr",layout);
                }else{
                    this.showToast(component,'dismissible','','No History Records Found!!','error');
                }
            } else {
                this.showToast(component,'dismissible','Failed',response.getError()[0].message,'error');
            }
            component.set("v.spinner",false);
        });
        
        $A.enqueueAction(action);
    },
    
    getLockedDetailFields:function(component){
        let lockedDetailFields = [
            {value:'ContentDetails',label:'Content Details',additionalParameter:null}
        ];
        return lockedDetailFields;
    }
    
})