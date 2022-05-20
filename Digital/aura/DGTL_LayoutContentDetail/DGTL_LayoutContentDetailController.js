({
    // function call on component Load
    doInit: function(component, event, helper) {
        // hide Delete icon if list has single item
        var action = component.get('c.hideDeleteButton');
        action.setCallback(this, function(response) {
        });
        $A.enqueueAction(action); 
        
        // create a Default RowItem [Instance] on first time Component Load
        // by call this helper function  
        // helper.initObjectData(component, event);
        helper.setReadWriteFields(component, event);
        
    },
    handleSectionToggle: function (component, event) {
        var openSections = event.getParam('openSections');

        if (openSections.length === 0) {
            component.set('v.activeSectionsMessage', "All sections are closed");
        } else {
            component.set('v.activeSectionsMessage', "Open sections: " + openSections.join(', '));
        }
    },
    // function for save the Records 
    Save: function(component, event, helper) {
        helper.saveObjectData(component, event);
    },
    // function for create new object Row in Contact List 
    addNewRow: function(component, event, helper) {
        // call the comman "createObjectData" helper method for add new Object Row to List  
        helper.createObjectData(component, event);
    },
    checkHistory : function(component, event, helper) {
        // call the helper method for getting the history records 
        var ctarget = event.currentTarget;
    	var id_str = ctarget.dataset.value; 
         console.log('id_str--',id_str);
        
        var target = event.target;
        var index = target.getAttribute("data-selected-Index");
        
        console.log('get history of the record'); 
        component.set("v.historyId",id_str);
        component.set("v.historyIndex",index);
        
        component.set("v.checkHistory",true);
     
    },
    handelCloseHistory : function(component, event, helper) {
        // call the helper method for getting the history records 
        console.log('close history of the record'); 
        //component.set("v.checkHistory",event.getParam("close"));
        component.set("v.checkHistory",false);
        /*
        
        component.set("v.ReplacedInst",event.getParam("replacedContentDetail"));       
        var record = event.getParam("replacedContentDetail");
        var index = event.getParam("index");
        console.log('record...',record);
        if(record != null || record != undefined){
            var detList = component.get("v.detailList");
            detList[index] = JSON.parse(JSON.stringify(component.get("v.ReplacedInst")));
            console.log('detList....',detList);
            component.set(component.get("v.detailList"),detList);
        } */
        
    },
    cloneRow : function(component, event, helper) {
        // call the comman "cloneObjectData" helper method for cloning Row to List  
        var target = event.target;
        var index = target.getAttribute("data-selected-Index");
       // console.log('index--',index);
        var DetailInstance = component.get("v.detailList")[index];
        //console.log('DetailInstance--',DetailInstance);
        helper.cloneObjectData(component, event ,index);
    },
    // function for delete the row 
    removeRow : function(component, event, helper) {
        // get the selected row Index for delete, from Lightning Event Attribute  
        var target = event.target;
        var index = target.getAttribute("data-selected-Index");
        
        //var index = event.currentTarget.dataset.value;
        //console.log('index--',index);
        var DetailInstance = component.get("v.detailList")[index];
        //console.log('DetailInstance--',DetailInstance);
        
        component.set("v.recToBeDelted",DetailInstance);
        component.set("v.delIndex",index);
        component.set("v.deletePrompt",true);
        
    },
    removeDeletedRow : function(component, event, helper) {
        var isDelete = event.getParam("delete");
        var index = event.getParam("indexVar");
        var DetailInstance = event.getParam("DetailInstance");
        if(isDelete != undefined){
            component.set("v.deletePrompt",false);
            
            if(isDelete){
                helper.deleteObjectData(component, event, index , DetailInstance );
            }
        }
    },
    hideDeleteButton : function(component, event, helper) {
        var list = component.get("v.detailList");
        if(list != undefined && list.constructor === Array && list.length == 1){
            //console.log('list.length---',list.length);
            component.set("v.hideDel",true);
        }else if(list != undefined && list.constructor === Array && list.length > 1){
            component.set("v.hideDel",false);
            //console.log('list.length---',list.length);
        }
    },
    historyReplace : function(component, event, helper) {
        helper.historyReplaceHpr(component, event, helper);
    },
    
    saveUnsavedChanges: function(component, event, helper){
        /*var issaved = true;
        component.getEvent("Unsavedchanges").setParams({
            "isUnsaved" : issaved
        }).fire();*/
    },
    
    onValChange: function(component, event, helper){
    /*var unsaved = component.find("unsaved");
    unsaved.setUnsavedChanges(true);
    component.set("v.UnsavedChanges", true);*/
},
    
    handleDiscard: function(component, event, helper) {
        // Similar to the handleSave method, but for discarding changes
       /* var unsaved = component.find("unsaved");
        unsaved.setUnsavedChanges(false);*/
    },
    
})