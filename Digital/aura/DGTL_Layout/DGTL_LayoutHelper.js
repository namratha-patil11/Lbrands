({
    initHpr : function(component,event) {
        component.set("v.abtestcount", 'AB Test [0]');
        component.set("v.takedowncount", 'Takedown [0]');
        component.set("v.contigencycount", 'Contingency [0]');
        component.set("v.placementLayout.Device_Type__c",'Mobile');
        component.set("v.spinner",true);
        component.set("v.cloneColumns", [
            {label: 'Name', fieldName: 'Name', type: 'text'},
            {label: 'Offer Type', fieldName: 'Offer_Type__c', type: 'text'},
            {label: 'Shot Number', fieldName: 'Shot_Number__c', type: 'text'},
            {label: 'Link', fieldName: 'Link__c', type: 'text'},
            {label: 'Main Message', fieldName: 'Main_Message__c', type: 'text '}
        ]);
        component.set("v.addColumns", [
            {label:'Placement Type', fieldName:'Placement_type__c',type: 'text'},
            //{label:'Name', fieldName:'Name',type: 'text'},
            {label:'Main Message', fieldName:'Main_Message__c',type: 'text'},
            {label:'Parent Content Name', fieldName:'Parent_Content_Name__c',type: 'text'},
             {label:'Type', fieldName:'Type__c',type: 'text'}
        ]);
        component.set("v.spinner",false);
        // GET logged in user brand 
        var action = component.get("c.getCurrentUserDetails");
        action.setCallback(this,function(result){
            var state = result.getState();
            var currentUserDetail =  result.getReturnValue();
            if(state === 'SUCCESS')
            {   
                if(currentUserDetail != null && currentUserDetail != '' && currentUserDetail != undefined)
                    component.set("v.placementLayout.Brands__c",currentUserDetail.DGTL_Brands__c);
                let digitalProfile = currentUserDetail.DGTL_Profile__c;
                let isSaveDisable = digitalProfile != null && digitalProfile != undefined && 
                    (digitalProfile == 'DGTL_Commerce_Operations' || digitalProfile == 'DGTL_Bangalore_Commerce_Services') ?
                    true : false;
                component.set("v.isSaveDisable",isSaveDisable);
            }
        });
        
        $A.enqueueAction(action);
        
        var action1 = component.get("c.getDataIssuesRecordTypeID");
        action1.setCallback(this,function(result){
            var state = result.getState();
            var recordTypeId =  result.getReturnValue();
            if(state === 'SUCCESS')
            {   
               component.set("v.recordTypeId",recordTypeId);
            }
        });
        
        $A.enqueueAction(action1);
        
    },
    CallfetchContentJsHpr : function(component,searchNextBack,Layout,helper){
        this.fetchContentJsHpr(component,event,helper,searchNextBack);
    },
    fetchContentJsHpr : function(component,event,helper,searchNextBack) {
        component.set("v.abtestcount", 'AB Test [0]');
        component.set("v.takedowncount", 'Takedown [0]');
        component.set("v.contigencycount", 'Contingency [0]');
       /* if(component.get("v.custmUnsavedChanges")){
            component.set("v.sourceName",'Search');
            component.set("v.isOpenModel", true);
        }else{*/
            // component.set("v.PrevplacementLayout",component.get("v.placementLayout"));
            component.set("v.prevBrand",component.get("v.placementLayout.Brands__c"));
            component.set("v.prevDeviceType",component.get("v.placementLayout.Device_Type__c"));
            component.set("v.prevFlrset",component.get("v.placementLayout.Floorset_Plan__c"));
            component.set("v.prevPagetype",component.get("v.placementLayout.Page_Types__c"));
            
            component.set("v.spinner",false);
            component.set("v.spinner",true);
            component.set("v.nextBtn",true);
            component.set("v.backBtn",true);
            component.set("v.layoutLocked", false);
            component.set("v.placementListSize", false);
            component.set("v.showTakedown",true);
            component.set("v.showABTest",true);
            component.set("v.showContingency",true);
            //component.set("v.moreBtns",true); 
            // console.log("..search..,");
            if(event != undefined ) {
                event.preventDefault();
                if(event.getParam("fields") != undefined)  component.set("v.placementLayout", event.getParam("fields"));
                // console.log("..search..,",component.get("v.placementLayout"));
            }
            //alert('---'+component.get("v.payLayoutId"));
            component.set("v.placementContents",[]);
            component.set("v.spinner",true);
            var action = component.get("c.fetchContents");
            var layout = component.get("v.placementLayout");
            action.setParams({'layout': component.get("v.placementLayout"),
                              'isNewLayout':component.get("v.isNewLayout"),
                              'payLayoutId':component.get("v.payLayoutId"),
                              'searchNextBack':searchNextBack});
            
            action.setCallback(this,function(result){
                var state = result.getState();
                if(state === 'SUCCESS')
                {
                    component.set("v.expandAll",false);
                    
                    var returnVal = result.getReturnValue();
                    if(returnVal !== undefined)
                    {                    
                        var finalRes = returnVal; 
                        if(finalRes.errorCode != '' && finalRes.errorCode != 'DGTL_Main_NoPlaceConts'){
                            component.set("v.spinner",false);
                          	component.set("v.placementLayout",finalRes.plaLayout);
                            this.showToast(component,'dismissible','Failed',finalRes.errorStatus,'error');
                        }
                        else {
                            component.set("v.placementListSize", true);
                            component.set("v.readFieldsDetMap",finalRes.detailReadFieldsMap);
                            component.set("v.writeFieldsDetMap",finalRes.detailWriteFieldsMap);
                            for(var key in  finalRes.ContentTypesBtns){
                                if(key == 'AB Test')
                                    component.set("v.abtestcount", 'AB Test '+'['+finalRes.ContentTypesBtns[key]+']');
                                else if(key == 'Takedown')
                                    component.set("v.takedowncount", 'Takedown '+'['+finalRes.ContentTypesBtns[key]+']');
                                    else if(key == 'Contingency')
                                        component.set("v.contigencycount", 'Contingency '+'['+finalRes.ContentTypesBtns[key]+']');
                            }
                            //alert(finalRes.ContentTypesBtns+'--'+component.get("v.ContentTypesBtns"));
                            var contdetedflds = finalRes.detailWriteFieldsMap;
                            var dethisflds = [];
                            for(var key in contdetedflds)
                            {
                                dethisflds.push(key);
                            }
                            component.set("v.contDetailEditFields",dethisflds);
                            
                            component.set("v.payLayoutId",finalRes.pLayoutId);
                            component.set("v.hasContents",finalRes.hasContents); 
                            component.set("v.placementLayout", finalRes.plaLayout);
                            component.set("v.isPreviousLayout", finalRes.isPreviousLayout);
                            if(component.get("v.placementLayout.Page_Types__c") == 'Editorials'){
                                component.set("v.editorialPageName",component.get("v.placementLayout.Collection_Page_Name__c"));
                            }
                            if(finalRes.plaLayout.Compared_Placement_Layout__c !=null && finalRes.plaLayout.Compared_Placement_Layout__c != '' && finalRes.plaLayout.Compared_Placement_Layout__c != undefined)
                            {
                                component.set("v.layoutLocked", true);
                            }  
                            //console.log('finalRes.detailReadFieldsMap..'+JSON.stringify(finalRes.detailReadFieldsMap));
                            //console.log('finalRes.detailReadFieldsMap..'+JSON.stringify(finalRes.detailWriteFieldsMap));
                            // mapping read field api name and label
                            var custs = [];
                            var contedfld = [];
                            var conts = finalRes.readFieldsMap;
                            for ( var key in conts ) {
                                custs.push({value:conts[key], key:key});
                            }                        
                            // mapping read field api name and label
                            var custs2 = [];
                            var conts2 = finalRes.editFieldsMap;
                            for ( var key in conts2 ) {
                                custs2.push({value:conts2[key], key:key});
                                contedfld.push(key);
                            }
                            var MviewRonlyFlds = [];
                            var flds = finalRes.miniViewFieldsMap;
                            
                            for(var key in flds ) {
                                MviewRonlyFlds.push({value:flds[key], key:key}); 
                            }
                            component.set("v.contEditFields",contedfld);
                            component.set("v.readFieldsList",custs);
                            component.set("v.editFieldsList",custs2);
                            component.set("v.miniViewReadFldList",MviewRonlyFlds);
                            
                            // buttons to be displayed 
                            var btn =  finalRes.buttons;
                            if(btn != undefined){
                                var btns = btn;
                                if(btns != undefined){
                                    if(btns.includes("Comment - Content")){
                                        component.set("v.commentBtn",true);
                                    }
                                    if(btns.includes("Comment - Layout")){
                                        component.set("v.commentlayoutBtn",true);
                                    }                            
                                    if(btns.includes("Delete - Content")){
                                        component.set("v.removeBtn",true);
                                    }
                                    if(btns.includes("History - Content")){
                                        component.set("v.historyBtn",true);
                                    }                            
                                    if(btns.includes("Add from Existing  Layout")){
                                        component.set("v.addToLayoutBtn",true);
                                    }
                                    if(btns.includes("Clone")){
                                        component.set("v.cloneBtn",true);
                                    }
                                    if(btns.includes("Create Library")){
                                        component.set("v.addToLibraryBtn",true);
                                    }
                                    if(btns.includes("Switch view")){
                                        component.set("v.chooseViewBtn",true);
                                    }
                                    if(btns.includes("Next")){
                                        component.set("v.nextBtn",true);
                                    }  
                                    if(btns.includes("Create Takedown")){
                                        component.set("v.TakedownBtns",true);
                                    }
                                    if(btns.includes("Create AB Test")){
                                        component.set("v.abTestBtn",true);
                                    }
                                    if(btns.includes("Delete - Layout")){
                                        component.set("v.showDeleteLayout",true);
                                    }
                                    if(btns.includes("Delete - Placements")){ 
                                        component.set("v.deletePlacements",true);
                                    }
                                    if(btns.includes("More Buttons")){
                                        component.set("v.moreBtns",true);
                                    }
                                    if(btns.includes("Update Content")){
                                        component.set("v.updateContent",true);
                                    }
                                    if(btns.includes("Cascade")){ 
                                        component.set("v.cascade",true);
                                    }
                                    if(btns.includes("Add KOD")){ 
                                        component.set("v.addKOD",true);
                                    }
                                    if(btns.includes("Content - Resequence")){ 
                                        component.set("v.resequence",true);
                                    }
                                    if(btns.includes("Show Notification")){ 
                                        component.set("v.showNotification",true);
                                    }
                                    if(btns.includes("Create - Layout")){ 
                                        component.set("v.showFinalSubmit",true);
                                    }else if(component.get("v.payLayoutId") != '' && component.get("v.payLayoutId") != null ){
                                        component.set("v.showFinalSubmit",true);   
                                    }
                                    loadDynamicGrid(component,false);
                                    if(component.get("v.showNotification")){
                                        let cmp = component.find('transaction');
                                        let body = '';
                                        cmp.set("v.body", body);
                                        if(returnVal.transactionMessageMap != undefined && returnVal.transactionMessageMap['message'] != undefined){
                                            this.createDynamicComponent(component,event,helper,'DGTL_GenericNotificationComponent',returnVal.transactionMessageMap,'transaction');
                                        }
                                    } 
                                    component.set("v.show",false);
                                    setTimeout(function(){
                                        component.set("v.show",true);
                                    }, 6000);
                                    
                                    this.showToast(component,'dismissible','Failed',finalRes.errorStatus,'error');
                                }
                            }
                            
                            component.set("v.placementContents",finalRes.list_contentWpr);
                            //console.log(JSON.stringify(finalRes.list_contentWpr));
                            component.set("v.spinner",false);
                        }
                        // }                      
                    }
                    else
                    {
                        component.set("v.spinner",false);
                        component.set("v.placementContents",[]);
                        this.showToast(component,'dismissible','Failed','Some Error.!!','error');
                    }
                }else{ 
                    component.set("v.spinner",false);
                    component.set("v.placementContents",[]);
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
                component.set("v.custmUnsavedChanges",false);
                component.set("v.spinner",false);
                
            });
            
            $A.enqueueAction(action)
       // }
        
    },
    addTakedownABHelper : function(component,event,helper,index, placementType) {
        var contentData = [];
        contentData.push(component.get("v.placementContents")[index].pContentRec);
        var messageString = placementType == 'Takedown' ?  'Takedown plan already exist for the selected placement!!!' 
        :  'AB Test version with same Test name already exist for the selected placement!!!';
        var action = component.get("c.saveSelectedContFromExistingLayout");
        action.setParams({'list_PlcContentToClone':contentData,
                          'pLayoutId': component.get("v.payLayoutId"),
                          'contentType' : placementType,
                          'testName' : component.get("v.ABTestName")});
        action.setCallback(this,function(result){
            var state = result.getState();
            if(state === 'SUCCESS')
            {
                var returnVal = result.getReturnValue();
                if(returnVal !== undefined && returnVal != null)
                {
                    if(returnVal[0].errorStatus != null && returnVal[0].errorStatus != undefined && returnVal[0].errorStatus.includes('DUPLICATE_VALUE')) {
                        this.showToast(component,'dismissible','Failed',messageString,'error');
                    }
                    else{                        
                        component.set("v.enableABTestPrompt", false);
                        component.set("v.enableTakedownPrompt", false);
                        this.fetchContentJsHpr(component,event,helper,'Search');
                        this.showToast(component,'dismissible','Success','Created successfully!!!','success');
                    }
                }else{
                    this.showToast(component,'dismissible','Failed','Some Error.!!','error');
                }
            }else{                
                var errors = result.getError();
                if (errors[0] && errors[0].message) {
                    console.log("Error message: " + errors[0].message);
                }                
            }
        });
        $A.enqueueAction(action);
    },
    cascadeAction : function(component,event,contentId) {
        //navigate to the layout tab on cancel
        var pageReference = {
            //type: 'standard__component',
            type: 'standard__navItemPage',
            attributes: {
                //componentName: 'c__Cascade_Content',
                apiName: 'Cascade_Content',
            },
            state: {
                "c__contentId": contentId,
            }
        };
        component.set("v.pageReference", pageReference);
        
        // console.log('navigating to Layout');
        var navService = component.find("navService");
        var pageReference = component.get("v.pageReference");
        event.preventDefault();
        
        //--- getting URL from the pagerefrence to navigate to it in new Tab.
        navService.generateUrl(pageReference).then($A.getCallback(function(url) {
            // console.log('url --- in get callback--',url);
            component.set("v.url", url ? url : "#");
            //---- open url in new tab
            window.open(
                'https:'+url,
                '_blank' // <- This is what makes it open in a new window.
            );
        }), $A.getCallback(function(error) {
            // console.log('url --- in get error--',url);
            component.set("v.url", "#");
        })); 
    },
    viewUpdateContentHelper : function(component,event,contentId) {
        var pageReference = {
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'Content_Update',
            },
            state: {
                "c__ContentId": contentId
            }
        };
        component.set("v.pageReference", pageReference);
        var navService = component.find("navService");
        var pageReference = component.get("v.pageReference");
        event.preventDefault();
        //--- getting URL from the pagerefrence to navigate to it in new Tab.
        navService.generateUrl(pageReference).then($A.getCallback(function(url) {
            // console.log('url --- in get callback--',url);
            component.set("v.url", url ? url : "#");
            //---- open url in new tab
            window.open(
                'https:'+url,
                '_blank' // <- This is what makes it open in a new window.
            );
        }), $A.getCallback(function(error) {
            // console.log('url --- in get error--',url);
            component.set("v.url", "#");
        }));
    },
    updateContentJsHpr : function(component,event,helper) {
        
        component.set("v.isNewLayout",false);
        
        component.set("v.placementLayout.Collection_Page_Name__c",component.get("v.editorialPageName"));
        component.set("v.placementLayout.Collection_Page_Url__c",component.get("v.editorialCollectionUrl"));
        var action = component.get("c.finalSubmitContent");
        action.setParams({'pLayout': component.get("v.placementLayout"),                          
                          'list_ContentToUpdate':component.get("v.placementContents"),                         
                          'payLayoutId':component.get("v.payLayoutId"),
                          'isPreviousLayout':component.get("v.isPreviousLayout"),                          
                          'list_RemovedContent':component.get("v.placementContentsRemoved")
                         });
        component.set("v.spinner",true);
        action.setCallback(this,function(result){
            var state = result.getState();
            if(state === 'SUCCESS')
            {
                var returnVal = result.getReturnValue();
                if(returnVal !== undefined)
                {
                    if(returnVal.includes('Success,'))
                    {     
                        component.set("v.payLayoutId",returnVal.split(',')[1]);
                        component.set("v.placementLayout.Id",returnVal.split(',')[1]);
                        //component.set("v.custmUnsavedChanges", false);
                        this.fetchContentJsHpr(component,event,helper,'Search');
                        this.showToast(component,'dismissible','Success','Updated Successfully.!!','success');
                        //component.set("v.spinner",false);
                    }
                    else {
                        
                        this.showToast(component,'dismissible','Failed',returnVal,'error');
                        component.set("v.spinner",false);
                    }
                    
                }
            }
        });
        $A.enqueueAction(action);
        
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
    cloneSelectedRecordsHpr : function(component, event) {
        
        var contentData = component.get("v.placementContents");        
        var clonedContents =[];
        
        var getAllId = component.find("boxPack");
        
        if(! Array.isArray(getAllId))
        {
            if (getAllId.get("v.value") == true) {
                // console.log('contentData===='+JSON.stringify(contentData));
                var selRec = contentData[getAllId.get("v.text")];
                if(selRec.pContentRec != undefined && selRec.pContentRec != null ){
                    clonedContents.push(selRec.pContentRec);
                }
                
            }
        }
        else
        {
            for (var i = 0; i < getAllId.length; i++) {
                if (getAllId[i].get("v.value") == true) {
                    var selRec = contentData[getAllId[i].get("v.text")];
                    if(selRec.pContentRec != undefined && selRec.pContentRec != null ){
                        clonedContents.push(selRec.pContentRec);
                    }
                    
                }
            }
        }
        component.set("v.clonePlacementContents", clonedContents);
        component.set("v.isCloneModalOpen", true);
    },
    saveCloneHpr : function(component, event) { 
        event.preventDefault();        
        var placLayout = event.getParam("fields");
        // console.log('--placLayout--'+placLayout.Collection_Page_Name__c);
        if(placLayout.Page_Types__c == 'Editorials' && placLayout.Collection_Page_Name__c == null){
            this.showToast(component,'dismissible','Failed','collection Page Name..!!','error');
        }else{
            var action = component.get("c.cloneSave");
            action.setParams({'pLayout':placLayout,
                              'list_PlcContentToClone':component.get("v.clonePlacementContents")});
            action.setCallback(this,function(result){
                var state = result.getState();
                if(state === 'SUCCESS')
                {
                    var returnVal = result.getReturnValue();
                    if(returnVal !== undefined)
                    {
                        if(returnVal === 'Success')
                        {
                            component.set("v.spinner",false);
                            this.showToast(component,'dismissible','Success','Cloned Successfully.!!','success');
                            component.set("v.isCloneModalOpen", false);
                        }
                        else
                        {
                            component.set("v.spinner",false);
                            this.showToast(component,'dismissible','Failed',returnVal,'error');
                        }
                    }
                }else{  
                    component.set("v.spinner",false);
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
        }
        
    },
    deleteLayoutHelper : function(component, event, helper) {
        component.set("v.spinner",true);
        var action = component.get("c.disablePlacementLayout"); 
        action.setParams({'layout': component.get("v.placementLayout")});
        action.setCallback(this,function(result){
            if(result.getState() === 'SUCCESS') {
                var returnVal = result.getReturnValue();
                if(returnVal !== undefined){
                    if(returnVal === 'SUCCESS')
                    {
                        component.set("v.spinner",false);
                        helper.clearAttributes(component, event, helper);
                        this.showToast(component,'dismissible','Success','Deleted Successfully!','success');                        
                    }
                    else {
                        component.set("v.spinner",false);
                        this.showToast(component,'dismissible','Failed','Something went wrong!!','error');
                    }
                }
                else {
                    this.showToast(component,'dismissible','Failed','Something went wrong!!','error');
                }
            }
            
        });
        $A.enqueueAction(action);
    },
    
     deletePlacementsHelper : function(component,event,helper){
        var contentData = component.get("v.placementContents");        
        var contentsToDelete =[];
        var contentsIdToDelete =[];
        component.set("v.spinner",true);
        var getAllId = component.find("boxPack");
        if(! Array.isArray(getAllId))
        {	
            if (getAllId.get("v.value") == true) {
                var selRec = contentData[getAllId.get("v.text")];
                if(selRec.pContentRec != undefined && selRec.pContentRec != null ){
                    contentData[getAllId.get("v.text")].pContentRec.Active__c = 'false';
                    var id_selected = selRec.pContentRec.Id;
                    if(!contentsToDelete.includes(selRec.pContentRec)) contentsToDelete.push(selRec.pContentRec);
                    if(!contentsIdToDelete.includes(selRec.pContentRec.Id)) contentsIdToDelete.push(selRec.pContentRec.Id);
                        for (var j = 0; j < contentData.length; j++) {
                        if( (contentData[j].pContentRec.Type__c == 'Takedown' || contentData[j].pContentRec.Type__c == 'AB Test' || contentData[j].pContentRec.Type__c == 'Contengency' )
                           && contentData[j].pContentRec.Parent_Content__c == id_selected){
                            contentData[j].pContentRec.Active__c = false;
                            if(!contentsToDelete.includes(contentData[j].pContentRec)) contentsToDelete.push(contentData[j].pContentRec);
                            if(!contentsIdToDelete.includes(contentData[j].pContentRec.Id)) contentsIdToDelete.push(contentData[j].pContentRec.Id);
                        }
                    }
                }
            }
        }
        else
        {	
            for (var i = 0; i < getAllId.length; i++) {
                
                if (getAllId[i].get("v.value") == true) {
                    var selRec = contentData[getAllId[i].get("v.text")];
                    
                    if(selRec.pContentRec != undefined && selRec.pContentRec != null ){
                        contentData[getAllId[i].get("v.text")].pContentRec.Active__c = 'false';
                        var id_selected = selRec.pContentRec.Id;
                        if(!contentsToDelete.includes(selRec.pContentRec)) contentsToDelete.push(selRec.pContentRec);
                        if(!contentsIdToDelete.includes(selRec.pContentRec.Id)) contentsIdToDelete.push(selRec.pContentRec.Id);
                        for (var j = 0; j < contentData.length; j++) {
                            if( (contentData[j].pContentRec.Type__c == 'Takedown' || contentData[j].pContentRec.Type__c == 'AB Test' || contentData[j].pContentRec.Type__c == 'Contengency' )
                               && contentData[j].pContentRec.Parent_Content__c == id_selected){
                                contentData[j].pContentRec.Active__c = false;
                                if(!contentsToDelete.includes(contentData[j].pContentRec)) contentsToDelete.push(contentData[j].pContentRec);
                                if(!contentsIdToDelete.includes(contentData[j].pContentRec.Id)) contentsIdToDelete.push(contentData[j].pContentRec.Id);
                            }
                        }
                    }
                }
            }
            
        }
        console.log('--contentsToDelete---',contentsToDelete);
        //hard delete--- contents and its associated details----
        if(contentsToDelete != null && contentsToDelete != undefined){
            var action = component.get("c.deleteContentsWithDetails");
            action.setParams({
                'list_Contents' : contentsToDelete,
                'contentIds' : contentsIdToDelete
            });
            action.setCallback(this,function(response){
                var state = response.getState();
                if(state === 'SUCCESS')
                {
                    var returnVal = response.getReturnValue();
                    if(returnVal !== undefined && returnVal != null)
                    {
                        if(returnVal === 'Success'){
                            this.showToast(component,'dismissible','Success','Placements deleted Successfully!','success');
                            this.fetchContentJsHpr(component,event,helper,'Search');
                        }else{
                            this.showToast(component,'dismissible','Failed',returnVal,'error');
                        }
                    }
                }else{
                    this.showToast(component,'dismissible','Failed','Something went wrong!!','error');
                }
            });
            $A.enqueueAction(action);
        }
        component.set("v.spinner",false);
        //component.set("v.placementContents",contentData);
    },
    
    selectAllHpr : function(component, event) {
        //get the header checkbox value  
        var selectedHeaderCheck = event.getSource().get("v.value");
        // get all checkbox on table with "boxPack" aura id (all iterate value have same Id)
        // return the List of all checkboxs element 
        var getAllId = component.find("boxPack");
        // If the local ID is unique[in single record case], find() returns the component. not array   
        if(getAllId != undefined){
            if(! Array.isArray(getAllId)){
                if(selectedHeaderCheck == true){ 
                    component.find("boxPack").set("v.value", true);
                    component.set("v.selectedCount", 1);
                }else{
                    component.find("boxPack").set("v.value", false);
                    component.set("v.selectedCount", 0);
                }
            }else{
                // check if select all (header checkbox) is true then true all checkboxes on table in a for loop  
                // and set the all selected checkbox length in selectedCount attribute.
                // if value is false then make all checkboxes false in else part with play for loop 
                // and select count as 0 
                if (selectedHeaderCheck == true) {
                    for (var i = 0; i < getAllId.length; i++) {
                        component.find("boxPack")[i].set("v.value", true);
                        component.set("v.selectedCount", getAllId.length);
                    }
                } else {
                    for (var i = 0; i < getAllId.length; i++) {
                        component.find("boxPack")[i].set("v.value", false);
                        component.set("v.selectedCount", 0);
                    }
                } 
            }  
        }
        
    },
    checkboxSelectHpr : function(component, event) {
        // get the selected checkbox value  
        var selectedRec = event.getSource().get("v.value");
        // get the selectedCount attrbute value(default is 0) for add/less numbers. 
        var getSelectedNumber = component.get("v.selectedCount");
        // check, if selected checkbox value is true then increment getSelectedNumber with 1 
        // else Decrement the getSelectedNumber with 1     
        if (selectedRec == true) {
            getSelectedNumber++;
        } else {
            getSelectedNumber--;
        }
        // set the actual value on selectedCount attribute to show on header part. 
        component.set("v.selectedCount", getSelectedNumber);
    },
    openAddHpr : function(component, event) {
        component.set("v.spinner",true);
        component.set("v.spinner",false);
        component.set("v.isAddModalOpen", true);     
    },
    searchContentToAddHpr : function(component, event) {
        event.preventDefault();
        var placLayout = event.getParam("fields");
        if(component.get("v.placementLayout").Floorset_Plan__c == placLayout.Floorset_Plan__c && component.get("v.placementLayout").Page_Types__c == placLayout.Page_Types__c && component.get("v.placementLayout").Brands__c == placLayout.Brands__c && component.get("v.placementLayout").Device_Type__c == placLayout.Device_Type__c)
        {
            this.showToast(component,'dismissible','Failed','Cannot select same plan,brand,page type and device type!!','error');
        }
        else{  
            // checks for editorial page type 
            if(placLayout.Page_Types__c == 'Editorials'){
                //Fetch the existing Editorials for the selected combination
                var action = component.get("c.fetchEditorialLayouts");
                action.setParams({'selectedBrand' : placLayout.Brands__c,
                                  'pageType'      : placLayout.Page_Types__c,
                                  'floorsetId'    : placLayout.Floorset_Plan__c,
                                  'deviceType'    : placLayout.Device_Type__c});
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
                            var editorialId = component.get('v.selectedEditorial');  
                            for ( var key in editorials ) {
                                if(editorialId == key)
                                    editoriallst.push({value:editorials[key], key:key, selected : true});
                                else editoriallst.push({value:editorials[key], key:key});
                            }
                            component.set('v.editorialLayouts', editoriallst);
                            if(component.get("v.selectedEditorial") !=  '' && component.get("v.selectedEditorial") !=  'None'){
                                component.set("v.recordId",component.get("v.selectedEditorial"));
                            }                    
                        }
                    }
                });
                $A.enqueueAction(action);
            }else{
                this.searchContentToAdd(component,event);
            }
            
        }
    },
    
    // search contents from existing layout 
    searchContentToAdd : function(component, event) {
        event.preventDefault(); 
        var placLayout = event.getParam("fields");
        var action = component.get("c.searchSelectedContFromExistingLayout");           
        action.setParams({'pageLayoutForAdd': placLayout,
                          'editorialId':component.get("v.selectedEditorial")});
        action.setCallback(this,function(result){
            var state = result.getState();
            if(state === 'SUCCESS')
            {
                var returnVal = result.getReturnValue();                    
                if(returnVal !== undefined && returnVal != null)
                {                        
                    for (var i = 0; i < returnVal.length; i++) 
                    {
                        var row = returnVal[i];
                        //if(row.pContentRec.Name) row.Name = row.pContentRec.Name;
                        if(row.pContentRec.Placement_type__c) row.Placement_type__c = row.pContentRec.Placement_type__c;
                        if(row.pContentRec.Main_Message__c) row.Main_Message__c = row.pContentRec.Main_Message__c;
                        if(row.pContentRec.Type__c) row.Type__c = row.pContentRec.Type__c;
                        if(row.pContentRec.Id) row.Id = row.pContentRec.Id;
                        if(row.pContentRec.Parent_Content_Name__c) row.Parent_Content_Name__c = row.pContentRec.Parent_Content_Name__c;
                    }
                    component.set("v.addPlacementContents",returnVal);
                }
                else
                {
                    this.showToast(component,'dismissible','Failed','No values for search results, Please try with different search','error');                       
                }
            }else{
                this.showToast(component,'dismissible','Failed','No values for search results, Please try with different search','error');
            }
        });
        $A.enqueueAction(action);
        
    },
    
    addSelectedContentHpr : function(component, event,helper) {
        /*var seleconts = component.get("v.selectedPlacementContents");
        var pContsIds = [];
        for(var key in seleconts)
        {
            var obj = seleconts[key];
            for(var key2 in obj)
            {
                pContsIds.push(obj['pContentRec']);
                break;
            }
        } */
        
        var action = component.get("c.saveSelectedContFromExistingLayout");
        action.setParams({//'list_PlcContentToClone':pContsIds,
                          'list_PlcContentToClone' : component.get("v.CloneFromExistLay"),
                          'pLayoutId':component.get("v.payLayoutId"),
                          'contentType' : 'Controlled',
                          'fromExistingLayout' : true,
                          'testName' : ''});
        action.setCallback(this,function(result){
            var state = result.getState();
            if(state === 'SUCCESS')
            {
                var returnVal = result.getReturnValue();
                if(returnVal !== undefined && returnVal != null)
                {
                    if(returnVal[0].errorStatus != null && returnVal[0].errorStatus != undefined && returnVal[0].errorStatus.includes('DUPLICATE_VALUE')) {
                        this.showToast(component,'dismissible','Failed','Placement already exist with the same library reference!!','error');
                    }
                    else{
                        component.set("v.isAddModalOpen", false);
                        var emptyConts = [];
                        component.set("v.ContentsWithoutChild", emptyConts);
                        component.set("v.removedChildContents", emptyConts);
                        component.set("v.checkChildContsMsg", '');
                        helper.fetchContentJsHpr(component, event,helper,'Search');
                        /* var placcont = [];
                    placcont = component.get("v.placementContents");                    
                    for(var key in returnVal)
                    {
                        if(placcont.length == 0) placcont.push(returnVal[key]);
                        else placcont.push(returnVal[key]);
                    }        
                    component.set("v.placementContents",placcont);
                    component.set("v.isAddModalOpen", false); */
                    } 
                }else{
                    component.set("v.isAddModalOpen", false);
                    this.showToast(component,'dismissible','Failed','Some Error.!!','error');
                }
            }else{
                var errors = result.getError();
                if (errors[0] && errors[0].message) {
                    console.log("Error message: " + errors[0].message);
                }
            }
        });
        $A.enqueueAction(action);
        
    },   
    clearAttributes : function(component, event, helper) {
        var conts = [];
        component.set('v.ContentTypesList',conts);
        component.set('v.contentData',conts);
        component.set('v.placementContents',conts);
        component.set('v.clonePlacementContents',conts);
        component.set("v.editorialPageName", '');
        component.set("v.isEditorials", false);
        component.set("v.nextBtn",false);
        component.set("v.backBtn",false);
        component.set("v.commentlayoutBtn",false);
        component.set("v.chooseViewBtn",false);
        component.set("v.abTestBtn",false);
        component.set("v.TakedownBtns",false);
        component.set("v.moreBtns",false);
        component.set("v.showRejected",false);
        component.set("v.showTakedown",false);
        component.set("v.showABTest",false);
        component.set("v.showDeleted",false);
        component.set("v.showDeleteLayout",false);
        component.set("v.placementLayout.Id", null);
        component.set("v.isNewLayout",false);
        component.set("v.editorialCollectionUrl",'');
        component.set("v.editorialPageName",'');
        component.set("v.payLayoutId", '');
        component.set("v.selectedCount", 0);
        component.set("v.resequence",false);
        component.set("v.layoutResequenced",false);
        component.set("v.abtestcount", 'AB Test [0]');
        component.set("v.takedowncount", 'Takedown [0]');
        component.set("v.contigencycount", 'Contingency [0]');
        component.set("v.isPreviousLayout",false);
        var getAllId = component.find("boxPack");
        if(getAllId != undefined) {
            if(! Array.isArray(getAllId)) getAllId.destroy();
            else {        
                for (var i = 0; i < getAllId.length; i++) {
                    getAllId[i].destroy();
                }
            }
        }
    },
    clearValuesHelper : function(component,event, helper){
        var conts = [];
        component.set('v.addPlacementContents',conts); 
        component.set('v.editorialLayouts',conts); 
        component.set('v.selectedEditorial',''); 
        
    },
    CallfetchSearchfields : function(component,layoutId,helper){
        // console.log('layoutId---',layoutId);
        var action = component.get("c.getLayoutInfo");           
        action.setParams({
            'layoutId': layoutId
        });
        action.setCallback(this,function(result){
            var state = result.getState();
            if(state === 'SUCCESS')
            { 
                var result = result.getReturnValue();
                var Layout = [];
                Layout.push({'sobjectType':'Placement_Layout__c','Brands__c': result.Brands__c,
                             'Page_Types__c' :result.Page_Types__c ,
                             'Floorset_Plan__c' : result.Floorset_Plan__c,
                             'Device_Type__c' : result.Device_Type__c});
                component.set("v.placementLayout",Layout[0]);
                this.CallfetchContentJsHpr(component,'Search',Layout[0],helper);
            }else{
                this.showToast(component,'dismissible','Failed','No Layout Found','error');
            }
        });
        $A.enqueueAction(action);
    },
    digitalLiveUsersJsHpr : function (component,helper){ 
        if(component.get("v.payLayoutId") != null && component.get("v.payLayoutId") !='' && component.get("v.payLayoutId") !=undefined){
            var action = component.get("c.digitalLiveUsers");
            action.setParams({
                'layoutId': component.get("v.payLayoutId")
            });        
            action.setCallback(this, function(result) {
                var state = result.getState();
                if(state === 'SUCCESS')
                {
                    component.set("v.liveUsers",result.getReturnValue());
                }
            });
            $A.enqueueAction(action); 
        }        
    },
    deleteLiveUsersJsHpr : function(component,helper){
        if(component.get("v.payLayoutId") != null && component.get("v.payLayoutId") !='' && component.get("v.payLayoutId") !=undefined){
            var action = component.get("c.deleteLiveUsers");
            action.setParams({
                'layoutId': component.get("v.payLayoutId")
            });        
            action.setCallback(this, function(result) {            
            });
            $A.enqueueAction(action); 
        } 
        
    },    
    resetRowsAndGroups :function (component,event,helper){
        let placementContents = component.get("v.placementContents");
        
        for(var key in placementContents){
            placementContents[key].pContentRec.Row_Start__c = true;
            placementContents[key].pContentRec.Grouped__c = '';
        }
        
        component.set("v.placementContents",placementContents);
        this.showToast(component,'dismissible','Success!','Reset Successfully!!','success');
    },
    historyReplaceHpr  : function (component, event) {
        
        var contentData = component.get("v.placementContents");
        var hisReplace = '';
        hisReplace = event.getParam('hisFields');
        var hisReplaceMap = [];
        hisReplaceMap = hisReplace.split("####");
        var replaceCont = contentData[component.get("v.historyIndex")];
        //this.showToast(component,'dismissible','replaceCont',replaceCont.pContentRec.Main_Message__c,'error');
        for(var key in contentData)
        {
            if(key == component.get("v.historyIndex")){
                
                for(var key2 in hisReplaceMap)
                {
                    var hisfld = hisReplaceMap[key2];
                    // console.log('--hisfld--'+hisfld);
                    var fldVal = hisfld.split(":")[1];
                    if(hisfld.split(":")[1] != undefined && hisfld.split(":")[1] !='undefined')                     
                        contentData[key].pContentRec[hisfld.split(":")[0]] = hisfld.split(":")[1];
                    else
                        contentData[key].pContentRec[hisfld.split(":")[0]] = '';
                    // console.log('--contentData[key]--'+contentData[key].pContentRec[hisfld.split(":")[0]]);
                }
            }
            
            //replaceCont.pContentRec[hisfld.split(":")[0]] = hisfld.split(":")[1];
        }
        component.set("v.placementContents", contentData);
        //this.showToast(component,'dismissible','History fields!',hisReplace,'error');
        this.showToast(component,'dismissible','Success !','Replaced Successfully, Click on Save','success');
        component.set("v.isHistoryModalOpen",false);
        component.set("v.historyIndex",'');
        component.set("v.historyId",'');
    },
    
    createDynamicComponent : function(component,event,helper,componentName,object,divId){
        
        $A.createComponent(
            "c:"+componentName,{
                parameters : object 
            },
            function(newcomponent){
                if (component.isValid()) {
                    let cmp = component.find(divId);
                    var body = cmp.get("v.body");
                    body.push(newcomponent);
                    cmp.set("v.body", body);             
                }else if (status === "INCOMPLETE") {
                    // console.log("No response from server or client is offline.")
                    // Show offline error
                }else if (status === "ERROR") {
                    // console.log("Error: " + errorMessage);
                    // Show error message
                }
            }
        );
        
    },
    getLastModifiedInfo : function(component,event){
        // Get the empApi component.
        var empApi = component.find("empApi");
        // Get the channel from the input box.
        var channel = '/data/';
        
        var sObjectName = component.get('v.sObjectName');
        if (sObjectName.endsWith('__c')) {
            // Custom object
            channel = channel + sObjectName.substring('0', sObjectName.length-3) + '__ChangeEvent';
        }
        else {
            // Standard object
            channel = channel + sObjectName + 'ChangeEvent';
        }
        var replayId = '-1';
        
        // Callback function to be passed in the subscribe call.
        // After an event is received, this callback prints the event
        // payload to the console.
        var callback = function (message) {
            console.log('-message.data.payload.ChangeEventHeader---',message.data.payload.ChangeEventHeader);
            var modifiedRecords = message.data.payload.ChangeEventHeader.recordIds;
            var commitUser = message.data.payload.ChangeEventHeader.commitUser;
            var currentRecordId = component.get('v.payLayoutId');
            var userId = $A.get("$SObjectType.CurrentUser.Id");
            var date = message.data.payload.LastModifiedDate;
            
            if (modifiedRecords.includes(currentRecordId)) { 
                if(commitUser != userId){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "message": "Someone else modified the record you're viewing!",
                        "type": "warning",
                        "mode": "sticky"
                    });
                    toastEvent.fire();
                }
                component.set("v.show",false);
                setTimeout(function(){
                    component.set("v.show",true);
                }, 6000);
            }
            
            
        }.bind(this); 
        
        // Error handler function that prints the error to the console.
        var errorHandler = function (message) {
            console.log("Received error ", message);
        }.bind(this); 
        
        // Register error listener and pass in the error handler function.
        empApi.onError(errorHandler); 
        
        // Subscribe to the channel and save the returned subscription object.
        empApi.subscribe(channel, replayId, callback).then(function(value) {
            console.log("Subscribed to channel " + channel);
        });
    },
    
    unSavedChanges : function(component, event, helper){ 
        /*var unsaved = component.find("unsaved");
        component.set("v.custmUnsavedChanges", true);
        unsaved.setUnsavedChanges(true, { label: 'DGTL_Layout' });*/
    },
    
    onPageTypeChangeHpr : function(component, event, helper, changed){
        var usVal = component.get("v.custmUnsavedChanges");
        
       /* if(usVal == true && changed== false){
            component.set("v.isOpenModel", true);
            component.set("v.isPageTypeChanged", true);
        } else{*/
            let value = component.get("v.discardChangeObj.discarded") ? component.get("v.discardChangeObj.changedValue") : event.getParam("value");
            component.set("v.placementLayoutProxy.Page_Types__c",value);
            component.set("v.placementLayout",component.get("v.placementLayoutProxy"));
            component.set("v.prevVal",component.get("v.placementLayout.Page_Types__c"));
            helper.clearAttributes(component, event, helper);
            helper.deleteLiveUsersJsHpr(component,helper);
            component.set("v.custmUnsavedChanges", false);  
       // }
        
    },
    
    onFloorChangeHpr : function(component, event, helper, changed){
        var usVal = component.get("v.custmUnsavedChanges");
        
       /* if(usVal == true && changed == false ){
            component.set("v.isOpenModel", true);
            component.set("v.isFloorsetChanged", true);
        }else{*/
            let value = component.get("v.discardChangeObj.discarded") ? component.get("v.discardChangeObj.changedValue") : event.getParam("value");
            component.set("v.placementLayoutProxy.Floorset_Plan__c",value);
            component.set("v.placementLayout",component.get("v.placementLayoutProxy"));
            component.set("v.prevVal",component.get("v.placementLayout.Floorset_Plan__c"));
            helper.clearAttributes(component, event, helper);
            helper.deleteLiveUsersJsHpr(component,helper);
            component.set("v.custmUnsavedChanges", false);      
       // }
    },
    
    onDeviceChangeHpr : function(component, event, helper, changed){
        var usVal = component.get("v.custmUnsavedChanges");
        
        /*if(usVal == true && changed == false){
            component.set("v.isOpenModel", true);
            component.set("v.isDeviceTypeChanged", true);
        }else{ */
            let value = component.get("v.discardChangeObj.discarded") ? component.get("v.discardChangeObj.changedValue") : event.getParam("value");
            component.set("v.placementLayoutProxy.Device_Type__c",value);
            component.set("v.placementLayout",component.get("v.placementLayoutProxy"));
            component.set("v.defaultDeviceLay",value);
            component.set("v.defaultDeviceClone",value);
            component.set("v.prevVal",component.get("v.placementLayout.Device_Type__c"));
            helper.clearAttributes(component, event, helper);
            helper.deleteLiveUsersJsHpr(component,helper);
           // component.set("v.custmUnsavedChanges", false);  
       // }
    },
    
    onBrandChangeHpr : function(component, event, helper, changed){
        
        var usVal = component.get("v.custmUnsavedChanges");
        
       /* if(usVal == true && changed == false && component.get("v.prevBrand") != component.get("v.placementLayout.Brands__c"))
        {
            component.set("v.isOpenModel", true);
            component.set("v.isBrandChanged", true);
        }else{ */
            let value = component.get("v.discardChangeObj.discarded") ? component.get("v.discardChangeObj.changedValue") : event.getParam("value");
            component.set("v.placementLayoutProxy.Brands__c",value); 
            component.set("v.placementLayout",component.get("v.placementLayoutProxy"));
            component.set("v.prevVal",component.get("v.placementLayout.Brands__c"));
            
            // helper.unSavedChanges(component, event, helper);
            helper.clearAttributes(component, event, helper);
            helper.deleteLiveUsersJsHpr(component,helper);
           // component.set("v.custmUnsavedChanges", false);      
       // }
    },
    
    fetchContentBackNextHpr : function(component, event, helper, changed){
        var usVal = component.get("v.custmUnsavedChanges");
        /*if(usVal == true && changed == false){
            component.set("v.isOpenModel", true);
        }else{*/
            helper.deleteLiveUsersJsHpr(component,helper);
            component.set("v.spinner",true);
            component.set("v.searchNextBack", 'Next Update');
            component.set("v.payLayoutId", '');
            component.set("v.editorialPageName", '');
            var conts = [];
            component.set('v.placementContents',conts); 
            component.set("v.isEditorials",false);
            helper.fetchContentJsHpr(component, event,helper,event.getSource().getLocalId());
           // component.set("v.custmUnsavedChanges", false); 
       // }
    },
    
    startSorting: function(component,event,helper){
        let dynamicInputArray = {nameFields:['pContentRec.Placement_type__c','pContentRec.Main_Message__c'],isLayout:true};
        component.set("v.dynamicInputArray",dynamicInputArray);
        component.set("v.placementContentToSort",component.get("v.placementContents"));
        component.set('v.sortableWindow',true);
    },
    //Check for AB Test/Takedown/Contingency contents without parent content
    checkChildContentsHpr : function(component,event,helper){
        var seleconts = component.get("v.selectedPlacementContents");
        var pConts = [];
        var conts = [];
        var parentIds = [];
        var pIDs = [];
        var selChildIds = [];
        for(var key in seleconts)
        {
            var obj = seleconts[key];
            for(var key2 in obj)
            {
                
                pConts.push(obj['pContentRec']);
                conts.push(obj['pContentRec']);
                pContentRec = obj['pContentRec'];
                pIDs.push(pContentRec.Id);
                if(pContentRec.Parent_Content__c == undefined)
                    parentIds.push(pContentRec.Id);
                else
                    selChildIds.push(pContentRec.Id);
                break;
            }
        }
        
        var allContswrp = component.get("v.addPlacementContents");
        var ContentsWithoutChild = [];
        var checkChildContsMsg = '';
        var childContsNoParent = false;
        var removedChildContents = [];
        var allChildIds = [];
        for(var key in allContswrp){
            var pContentRec = allContswrp[key].pContentRec;
            if(pContentRec.Parent_Content__c != undefined && !selChildIds.includes(pContentRec.Id) && parentIds.includes(pContentRec.Parent_Content__c))
            ContentsWithoutChild.push(pContentRec.Name);
        }
        component.set("v.ContentsWithoutChild",ContentsWithoutChild);
        for(var key in conts){
            
            if(conts[key].Parent_Content__c != undefined){
                if(!parentIds.includes(conts[key].Parent_Content__c)){
                    childContsNoParent = true;
                    removedChildContents.push(conts[key].Type__c+' For  '+conts[key].Name);
                    
                    //var contkey = 
                    pConts.splice(pIDs.indexOf(conts[key].Id),1);
                    pIDs.splice(conts[key].Id,1);
                }
            }
        }
        if(childContsNoParent){
            checkChildContsMsg = 'Cannot clone AB Test/Takedown/Contigency contents without selecting the original placement library';
            component.set("v.checkChildContsMsg",checkChildContsMsg);
            component.set("v.CloneFromExistLay",pConts);
            component.set("v.removedChildContents",removedChildContents);
        }else{
            component.set("v.checkChildContsMsg",'');
            var removedChildCont = [];
            component.set("v.CloneFromExistLay",pConts);
            component.set("v.removedChildContents",removedChildCont); 
        }
    }
    
    
})