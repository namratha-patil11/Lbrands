({
    init : function(component, event, helper) {
        let discardObj = {discarded:false,changedValue:''};
        component.set("v.discardChangeObj",discardObj);
        helper.initHpr(component, event);
    },
    handelEachLoad : function(component,event, helper){
        component.set("v.spinner",false);
    },
    onChangeLayoutAttribute  : function(component,event, helper){
        helper.clearAttributes(component, event, helper);  
    },
    printPDF : function(component, event, helper){
        component.set("v.printView",true);
        window.print();
    },
    fetchContentJs : function(component, event, helper) {
        event.preventDefault();
        if(component.get("v.placementLayout.Device_Type__c") == '' || component.get("v.placementLayout.Device_Type__c") == undefined
           || component.get("v.placementLayout.Page_Types__c") == '' || component.get("v.placementLayout.Page_Types__c") == undefined
           || component.get("v.placementLayout.Brands__c") == '' || component.get("v.placementLayout.Brands__c") == undefined
           || component.get("v.placementLayout.Floorset_Plan__c") == '' || component.get("v.placementLayout.Floorset_Plan__c") == undefined){
            
            helper.showToast(component,'dismissible','Error','Please Fill all the Mandatory Fields for Search!!','error');
        }else{
            if(component.get("v.placementLayout.Page_Types__c") == 'Editorials'){
                component.set("v.isEditorials",true);
            }else{
                component.set("v.isEditorials",false);
                helper.fetchContentJsHpr(component, event,helper,'Search'); 
            }  
        }        
    },
    cascadeAction : function(component, event, helper) {
        var ctarget = event.currentTarget;
        var id_str = ctarget.dataset.value;
        helper.cascadeAction(component,event,id_str);
    },
     handleViewChange : function(component, event, helper){ 
            $A.util.toggleClass(component.find('miniView'), 'hideUsers');       
            $A.util.toggleClass(component.find('fullView'), 'hideUsers');
	},
    addKOD : function(component, event, helper) {
        var ctarget = event.currentTarget;
        component.set("v.selectedContentId",ctarget.dataset.value);
        component.set("v.selectedContentName",ctarget.dataset.name);
        component.set("v.openAddKODModal",true);
    },
    updateCon : function(component, event, helper) {
        if(component.get("v.placementContents").length == 0) {
            component.set("v.enableCreatePrompt", true);
        }
        else {
            helper.updateContentJsHpr(component, event, helper);
        }
    },
    onBrandChange : function(component, event, helper) {
       component.set("v.sourceName", 'Brands__c');
       component.set("v.discardChangeObj.changedValue",event.getParam("value"));
       helper.onBrandChangeHpr(component, event, helper, false);
    },
    viewUpdateContent : function(component, event, helper) {
        var ctarget = event.currentTarget;
        var id_str = ctarget.dataset.value; 
        helper.viewUpdateContentHelper(component, event,id_str);
    },
    addTakedown : function(component, event, helper) {
        component.set("v.ABTestName", '');
        component.set("v.listIndex", event.getSource().get("v.value"));
        component.set("v.enableTakedownPrompt", true);                       
    },
    addContentType : function(component, event, helper) {
        var contentData = [];
        contentData.push(component.get("v.placementContents")[event.getSource().get("v.value")].pContentRec);
        component.set("v.contentData", contentData); 
        component.set("v.ContentTypesList", component.get("v.placementContents")[event.getSource().get("v.value")].ContentTypesList); 
        component.set("v.enableContentTypePrompt", true);                       
    },
    addABTest : function(component, event, helper) {
        component.set("v.ABTestName", '');
        component.set("v.listIndex", event.getSource().get("v.value"));
        component.set("v.enableABTestPrompt", true); 
        
    },  
    onPageTypeChange : function(component, event, helper) {
         component.set("v.sourceName", 'Page_Types__c');
        component.set("v.discardChangeObj.changedValue",event.getParam("value"));
        helper.onPageTypeChangeHpr(component, event, helper, false);
       
    },
    onFloorChange : function(component, event, helper) {
         component.set("v.sourceName", 'Floorset_Plan__c');
        component.set("v.discardChangeObj.changedValue",event.getParam("value"));
        helper.onFloorChangeHpr(component, event, helper, false);
    },   
    
    onDeviceChange : function(component, event, helper) {
        component.set("v.sourceName", 'Device_Type__c');
        component.set("v.discardChangeObj.changedValue",event.getParam("value"));
        helper.onDeviceChangeHpr(component, event, helper, false);
        
    },
    handleMoreButtons:function(component, event, helper) {
        var selectedMenuItemValue = event.getParam("value");
        switch(selectedMenuItemValue) {
            case 'Search_Existing_From_Library':
                component.set("v.isSearchLibraryModalOpen",true);
                break;
            case 'Add_from_Existing_Layout':
                helper.openAddHpr(component, event);
                break;
            case 'Create_Placement' :
                component.set("v.spinner",true);
                component.set("v.isAddPayLibraryModalOpen",true);
                component.set("v.spinner",false);
                break;
            case 'Clone':
                helper.cloneSelectedRecordsHpr(component, event);
                break;
            case 'Delete_Placement' :
                component.set("v.enableDeletePrompt", true);
                component.set("v.toDelete",'Placement');
                break;
            case 'sort' :
                helper.startSorting(component,event,helper);
                break;
            case 'Delete_Layout' :
				component.set("v.enableDeletePrompt", true);
                component.set("v.toDelete",'Layout');
				break;                
        }
    },
    handleStateFulButtons : function(component, event, helper) {
        
        switch(event.getSource().get("v.title")) {
            case 'Deleted' :
                component.set("v.showDeleted", !component.get("v.showDeleted"));
                break;
            case 'Collapse' :
                component.set("v.expandAll", !component.get("v.expandAll"));
                let state = component.get("v.expandAll") ? 'open' : 'close';
                component.set("v.defaultState",state);
                break;
            case 'Reset' :
                component.set("v.spinner",true);
                helper.resetRowsAndGroups(component,event,helper);
                component.set("v.spinner",false);
                break;
                
        }
    },
    handleContentTypesBtns : function(component,event,helper){
        switch(event.getSource().get("v.title")) {
            case 'Takedown' :
                component.set("v.showTakedown", !component.get("v.showTakedown"));
                break;
            case 'ABTest' :
                component.set("v.showABTest", !component.get("v.showABTest"));
                break;
            case 'Contingency' :
                component.set("v.showContingency", !component.get("v.showContingency"));
                break;
                
        }
    },
    handleTestPrompt : function(component, event, helper) {
         if(event.getSource().getLocalId() == 'test_Allow' ) {
             if(component.get("v.ABTestName") != '') {                  
                 helper.addTakedownABHelper(component, event, helper,component.get("v.listIndex"),'AB Test');                 
             }
         }
        else component.set("v.enableABTestPrompt", false);
          
    },
    handleLayoutDeletePrompt : function(component, event, helper) {
        if(event.getSource().getLocalId() == 'delete_Allow') {
            let toDelete = component.get("v.toDelete");
            if(toDelete.toLowerCase() == 'layout'){
                helper.deleteLayoutHelper(component, event,helper);
            }else{
                helper.deletePlacementsHelper(component, event,helper);
            }
        }
        component.set("v.enableDeletePrompt", false);
    },
    handleLayoutCreatePrompt : function(component, event, helper) {
        if(event.getSource().getLocalId() == 'create_Allow') {
             helper.updateContentJsHpr(component, event, helper);
        }
        component.set("v.enableCreatePrompt", false);
    },
    handleTakedownPrompt : function(component, event, helper) {
        if(event.getSource().getLocalId() == 'Takedown_Allow') {
            helper.addTakedownABHelper(component, event, helper,component.get("v.listIndex"), 'Takedown'); 
        }
        component.set("v.enableTakedownPrompt", false);
    },
    handleContentDeletePrompt : function(component, event, helper) {
        if(event.getSource().getLocalId() == 'delete_Allow') {       
            var id_str = component.get("v.listIndex");
            var contentData = component.get("v.placementContents");
            contentData[id_str].pContentRec.Active__c = false;
            var id_selected = contentData[id_str].pContentRec.Id;
            contentData[id_str].pContentRec.Active__c = false;
            for (var i = 0; i < contentData.length; i++) {
                if(contentData[i].pContentRec.Type__c == 'Takedown' || contentData[i].pContentRec.Type__c == 'AB Test' && contentData[i].pContentRec.Parent_Content__c == id_selected){
                     contentData[i].pContentRec.Active__c = false;
                }
            }
            component.set("v.placementContents", contentData);
            component.set("v.spinner",false);
        }
        component.set("v.enableCnDeletePrompt", false);
    },
    
    removeRow: function(component, event, helper) {
       // component.set("v.listIndex", event.getSource().get("v.value"));
       // component.set("v.enableCnDeletePrompt",true);
        //---- comment the above lines n uncomment below code
        
         
         component.set("v.listIndex", event.getSource().get("v.value"));
        var index = event.getSource().get("v.value");
        var contentData = component.get("v.placementContents");
        var object =  contentData[index].pContentRec;
        if(object != undefined && (object.Id == undefined || object.Id == null)){
            component.set("v.enableCnDeletePrompt",true);
        }else{
            console.log("content------------------on delete--",object);
            component.set("v.contentToDelete",object);
            component.set("v.openMultiContentDelete",true);
        }
        
         
    },
    checkboxSelect: function(component, event, helper) {
        helper.checkboxSelectHpr(component, event);
    },
    selectAll: function(component, event, helper) {
        helper.selectAllHpr(component, event);
    },
    closeCloneModel: function(component, event, helper) {
        component.set("v.isCloneModalOpen", false);
    },
    saveClone: function(component, event, helper) {
        component.set("v.spinner",true);
        helper.saveCloneHpr(component, event);
    },
    falseSubmit:function(component, event, helper) {
        event.preventDefault();
    },
    addSelectedContent: function(component, event, helper) {
        helper.addSelectedContentHpr(component, event,helper);
    },
    closeAddModel: function(component, event, helper) {
        component.set("v.isAddModalOpen", false);
        var emptyConts = [];
        component.set("v.addPlacementContents", emptyConts);
        component.set("v.ContentsWithoutChild", emptyConts);
        component.set("v.removedChildContents", emptyConts);
        component.set("v.checkChildContsMsg", '');
    },
    handleSelect : function(component, event, helper) {
        var selectedRows = event.getParam('selectedRows');
        var setRows = [];
        for ( var i = 0; i < selectedRows.length; i++ ) {
            setRows.push(selectedRows[i]);
        }
        component.set("v.selectedPlacementContents", setRows);
        component.set("v.selectedCountAdd",selectedRows.length);
        // this method is used to check child contents without parent and parent without child selected
        helper.checkChildContentsHpr(component, event, helper);
    },
    viewChange: function(component, event, helper) {
        component.set("v.isFullView", event.getParam("value") === 'Mini' ? false : true);        
    },
    openLayoutCommentModel: function(component, event, helper) {
        component.set("v.spinner",true);
        component.set("v.isCommentLayoutModalOpen", true);
        component.set("v.spinner",false);
    },
    openContentCommentModel: function(component, event, helper) {
        component.set("v.spinner",true);
        var cId = event.getSource().get("v.value");
        component.set("v.placContId", cId);
        component.set("v.isCommentContentModalOpen", true);
        component.set("v.spinner",false);
    },    
    closeCommentModel: function(component, event, helper) {
        component.set("v.isCommentLayoutModalOpen", false);
    },
    closeCommentModelCont: function(component, event, helper) {
        component.set("v.isCommentContentModalOpen", false);
    },
    fetchHistory : function(component, event, helper) {        
        var ctarget = event.currentTarget;
    	var id_str = ctarget.dataset.value; 
        var target = event.target;
        var index = target.getAttribute("data-selected-Index");        
        component.set("v.historyId",id_str);
        component.set("v.historyIndex",index);
        component.set("v.isHistoryModalOpen",true);
    },    
    closeHistoryModel : function(component, event, helper) {
        component.set("v.isHistoryModalOpen",false);
    },
    closeContTypeModel : function(component, event, helper) {
        component.set("v.enableContentTypePrompt",false);
        var ContentTypesList = [];
        component.set("v.ContentTypesList",ContentTypesList);
        if(event.getParam('refreshLay'))
        helper.fetchContentJsHpr(component,event,helper,'Search');
    },
    historyReplace  : function (component, event, helper) {
        helper.historyReplaceHpr(component, event);
    },
    closeLibraryModel : function(component, event, helper) {
        component.set("v.isAddPayLibraryModalOpen",false);
        component.set("v.isSearchLibraryModalOpen",false);
        component.set("v.isEditorials",false);
        component.set("v.isCloneModalOpen",false);
        var conts = [];
		component.set('v.clonePlacementContents',conts);
    },    
    fetchContentBackNext : function(component, event, helper) {
        
        component.set("v.sourceName", 'Navigate');
        helper.fetchContentBackNextHpr(component, event, helper, false);
    },

    RemoveComponent:function(component,event){
        //get the parameter you defined in the event, and destroy the component
        var component = event.getParam("comp");      
        component.destroy();
    },
    searchContentToAdd: function(component, event, helper) {
        helper.searchContentToAddHpr(component, event);
    },
    getContentsExisting: function(component, event, helper) {
        helper.searchContentToAdd(component, event);
    },
    clearValues : function(component,event, helper){
        helper.clearValuesHelper(component,event, helper);       
    },
    getContFromLib : function(component, event, helper) {
        var searchFromLibrary = event.getParam("searchFromLibrary");
        helper.clearValuesHelper(component,event, helper);  
        var placcont = [];
        placcont = component.get("v.placementContents"); 
        for(var key in searchFromLibrary)
        {
            placcont.push(searchFromLibrary[key]);
        }        
        component.set("v.placementContents",placcont);
        component.set("v.isSearchLibraryModalOpen",false);
    },
    getAddLibrary : function(component, event, helper) {
        var AddLibrary = event.getParam("AddLibrary");
        var clonedContents =[];
        helper.clearValuesHelper(component,event, helper);  
        var placcont= component.get("v.placementContents");
        for(var key in AddLibrary)
        {
            placcont.push(AddLibrary[key]);
            clonedContents.push(AddLibrary[key].pContentRec);
        }        
        component.set("v.placementContents",placcont);
        component.set("v.isAddPayLibraryModalOpen",false);
        if(component.get("v.openCloneContent")){
            component.set("v.clonePlacementContents", clonedContents);
            component.set("v.isCloneModalOpen", true);
            console.log('clonedContents----,',clonedContents);
            component.set("v.openCloneContent",false);
        }
    },  
    getEditorial : function(component, event, helper) {        
        component.set("v.isEditorials",false);
        component.set("v.isNewLayout",event.getParam("isNewLayout"));
        if(component.get("v.isNewLayout")){
            component.set("v.placementLayout.Id",'');
            component.set("v.payLayoutId",'');
        }else{
            component.set("v.placementLayout.Id",event.getParam("editorialId"));
            component.set("v.payLayoutId",event.getParam("editorialId"));
        }
        
        component.set("v.editorialPageName",event.getParam("editorialPageName"));
        component.set("v.editorialCollectionUrl",event.getParam("editorialcollectionPageUrl"));
        component.set("v.placementLayout.Collection_Page_Name__c",event.getParam("editorialPageName"));
        component.set("v.placementLayout.Collection_Page_Url__c",event.getParam("editorialcollectionPageUrl"));
        helper.fetchContentJsHpr(component, event,helper,component.get("v.searchNextBack"));    	
        
    },
    openEditorial : function(component, event, helper) {
        component.set("v.isEditorials",true);
        helper.clearValuesHelper(component,event, helper);          
    },
   /* allowDrop: function(component, event, helper) {
        if(component.get("v.resequence")){
            event.preventDefault();
        }        
    },
    drag: function (component, event, helper) {
        if(component.get("v.resequence")){
           /* if(component.get("v.layoutLocked")){
                helper.showToast(component,'dismissible','Failed','Layout is Locked','error');
            }else{ */
                //event.dataTransfer.setData("text", event.target.id);
           // }
            
       /* }else{
            helper.showToast(component,'dismissible','Failed','No access to resequence','error');
        }        
    },
    drop: function (component, event, helper) {
        if(component.get("v.resequence") ){ //&& !component.get("v.layoutLocked")
        var data = event.dataTransfer.getData("text"); //Drag Start Record
        //alert('data: '+data);
        // Find the record ID by crawling up the DOM hierarchy
        //alert(event.target.closest('[id]'));
        if(event.target.closest('[id]') != null)
        {
            var tar = event.target.closest('[id]'); //Drop Place Record
            //alert('tar: '+tar.id);
            var contentData = component.get("v.placementContents");
            var index1, index2, temp;
            // Find the index of each item to move
            contentData.forEach((v,i)=>{if(v.conId===data) index1 = i; if(v.conId===tar.id) index2 = i;});
            if(index1<index2) {
                // Lower index to higher index; we move the lower index first, then remove it.
                contentData.splice(index2+1, 0, contentData[index1]);
                contentData.splice(index1, 1);
            } else {
                // Higher index to lower index; we remove the higher index, then add it to the lower index.
                temp = contentData.splice(index1, 1)[0];
                contentData.splice(index2, 0, temp);
            }
            // Trigger aura:valueChange, component will rerender
            component.set("v.placementContents", contentData);
            component.set("v.layoutResequenced", true);  
            event.preventDefault();
        }
        }
    },*/ 
    
    cloneEditorial: function(component, event, helper) {
        var params = event.getParams();
        if(params.value=='Editorials')
        component.set("v.isEditorialsClone",true); 
        else
        component.set("v.isEditorialsClone",false); 
    },
    
    kodModalClose : function(component, event, helper) {
        // DO NOT DELETE OR CHANGE THIS METHOD THIS IS BIENG USED FOR DGTL_MultiContentDelete  
        console.log('-----------callSearch-----------');
        component.set("v.openAddKODModal",false);
        helper.fetchContentJsHpr(component, event,helper,'Search'); 
        
    },

    showRelatedContent : function(component, event, helper) {
        component.set("v.relatedContentId", event.target.getAttribute('data-id'));
        component.set("v.showRelatedContents",true);
    },

    closeRelatedContentModal : function(component, event, helper) {
        component.set("v.relatedContentId", '');
        component.set("v.showRelatedContents",false);
    },
    
    getChange : function(component, event, helper){
     //  alert(component.get("v.custmUnsavedChanges")); 
       // helper.unSavedChanges(component, event, helper);
        console.log('@@@Oninputchange' +component.get("v.custmUnsavedChanges"));
        
        console.log('*****Unsavedchanges' + component.get("v.custmUnsavedChanges"));
    },

 
    handleSave: function(component, event, helper) {
        var sourceval = component.get("v.sourceName");
        if(sourceval == 'Brands__c'){
            component.set("v.placementLayout.Brands__c", component.get("v.placementLayoutProxy.Brands__c"));
        }else if(sourceval == 'Page_Types__c'){
            component.set("v.placementLayout.Page_Types__c", component.get("v..placementLayoutProxy.Page_Types__c"));
        }else if(sourceval == 'Device_Type__c'){
            component.set("v.placementLayout.Device_Type__c", component.get("v.placementLayoutProxy.Device_Type__c"));
        }else if(sourceval == 'Floorset_Plan__c'){ 
            component.set("v.placementLayout.Floorset_Plan__c", component.get("v.placementLayoutProxy.Floorset_Plan__c"));
        } 
        //console.log('@@NewBrand'+ component.get("v.placementLayout.Device_Type__c"));
        // To return control to the Lightning UI after your custom save logic completes, call setUnsavedChanges() again
        
        helper.updateContentJsHpr(component, event, helper);
        
        
        component.set("v.isOpenModel" , false);
    },
    
    
    handleDiscard: function(component, event, helper) {
      
        var sourceval = component.get("v.sourceName");
        component.set("v.discardChangeObj.discarded",true);
        if(sourceval == 'Brands__c'){
           helper.onBrandChangeHpr(component, event, helper, true);
           component.set("v.pagetyperender", true);
        }else if(sourceval == 'Page_Types__c'){
           helper.onPageTypeChangeHpr(component, event, helper, true);
        }else if(sourceval == 'Device_Type__c'){
           helper.onDeviceChangeHpr(component, event, helper, true);  
        }else if(sourceval == 'Floorset_Plan__c'){ 
           helper.onFloorChangeHpr(component, event, helper, true); 
        }else if(sourceval == 'Navigate'){
            helper.fetchContentBackNextHpr(component, event, helper, true);
        }else if(sourceval == 'Search'){
            //component.set("v.custmUnsavedChanges",false);
            helper.fetchContentJsHpr(component, event, helper,'Search');
        }
        component.set("v.discardChangeObj.discarded",false);
        component.set("v.isOpenModel", false);
    },
    
    closeModel: function(component, event, helper){

    var sourceval = component.get("v.sourceName");
        
   // component.set("v.placementLayout", component.get("v.PrevplacementLayout"));
   // console.log("@@@SourceVal" + component.get("v.placementLayout.sourceval"));
    // component.set("v.placementLayout.sourceval", component.get("v.prevVal"));
        
       if(sourceval == 'Brands__c'){
            component.set("v.placementLayout.Brands__c", component.get("v.prevBrand"));
        }
        else if(sourceval == 'Page_Types__c'){
            component.set("v.placementLayout.Page_Types__c", component.get("v.prevPagetype"));
        }
            else if(sourceval == 'Device_Type__c'){
                component.set("v.placementLayout.Device_Type__c", component.get("v.prevDeviceType"));
            }
                else if(sourceval == 'Floorset_Plan__c'){ 
                    component.set("v.placementLayout.Floorset_Plan__c", component.get("v.prevFlrset"));
                } 
        
        component.set("v.isOpenModel" , false);
        
    },
    
    closeSortable: function(component, event, helper){
        component.set("v.sortableWindow",false);
       // component.set("v.placementContentToSort",[]);
    },
    
    applySorting: function(component, event, helper){
        component.set("v.sortableWindow",false);
        component.set("v.spinner",true);

        setTimeout(function(){
            component.set("v.placementContents",[]);
            //component.set("v.custmUnsavedChanges",true);
            component.set("v.sourceName",'resequence'); 
            console.log('--detail/Content---',event.getParam('value'));
            component.set("v.placementContents",event.getParam('value'));
            component.set("v.spinner",false);
        }, 3000);
    },
    
    sortDetail : function(component,event,helper){
        let index= event.target.getAttribute("data-index");
        let contents =  component.get("v.placementContents");
        component.set("v.placementContentToSort",contents);
        component.set("v.detailItemsToSort",contents[index].ContentDetWpr.detailList);
        let dynamicInputArray = {nameFields:['Link_Text__c'],swapIndexField:['S_No__c'],isLayout:false};
        component.set("v.dynamicInputArray",dynamicInputArray);
        console.log('---detailItemsToSort-',component.get("v.detailItemsToSort"));
        component.set('v.sortableWindow',true);
    },
    handleTaskSubmit : function(component, event, helper){
        event.preventDefault();
        var taskFields = event.getParam("fields");
        //taskFields.RecordTypeId = '0122f0000001rV2AAI';
        console.log('taskFields---'+JSON.stringify(taskFields));
        if(taskFields.Reason__c	== '') 
            helper.showToast(component,'dismissible','Error..','Please Select a valid reason!','error');
        else{
            var action = component.get("c.saveTicket");
            action.setParams({
                'Ticket' : taskFields
            })
            action.setCallback(this,function(result){
                var state = result.getState();
                var result =  result.getReturnValue();
                if(state === 'SUCCESS')
                {   
                    if(result != null && result != '' && result == 'Success'){
                        console.log("--Success--saveTicket")
                        helper.showToast(component,'dismissible','Success..','Ticket created successfully!','success');
                        component.set("v.defaultReason",'');
                    }else {
                        helper.showToast(component,'dismissible','Failed','Please contact your admin','error');
                    }
                }
            });
            $A.enqueueAction(action); 
        }
    }
   
})