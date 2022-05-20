({
    setReadWriteFields : function(component, event) {
        var detailList = component.get("v.detailList");
        if(detailList == null || detailList == undefined || detailList.length == 0){
            this.createObjectData(component, event);
        }
        
        // mapping read field api name and label 
        var readList = [];
        var read = component.get("v.readFieldsMap");
        for ( var key in read ) {
            readList.push({value:read[key], key:key});
        }
        component.set("v.readFieldsList",readList);
       // console.log('readList--',readList);
        
        // mapping write field api name and label
        var writeList = [];
        var contDetailEditFields = [];
        var write = component.get("v.writeFieldsMap");
        for ( var key in write ) {
            writeList.push({value:write[key], key:key});
            contDetailEditFields.push(key);
        }
        component.set("v.writeFieldsList",writeList);
        component.set("v.contDetailEditFields",contDetailEditFields);
        
        var readList = component.get("v.readFieldsList");
        var writeList = component.get("v.writeFieldsList");
        console.log('writeList----setReadWriteFields--child',writeList);
        for(var item in writeList){
            if(writeList[item].key == 'Sub_Type__c' || writeList[item].value == 'Sub Type'){
                component.set("v.writeSubType",true);
            }
            if(writeList[item].key == 'Slides__c' || writeList[item].value == 'Slides'){
                component.set("v.writeSlides",true);
            }
            if(writeList[item].value == 'Link Text' || writeList[item].key == 'Link_Text__c'){
                component.set("v.writeLink",true);
            }
            if(writeList[item].value == 'Copy' || writeList[item].key == 'Copy__c'){
                component.set("v.writeCopy",true);
            }
            if(writeList[item].value == 'Asset Path' || writeList[item].key == 'Asset_Path__c'){
                component.set("v.writeAsset",true);
            }
            if(writeList[item].value == 'Comments' || writeList[item].key == 'Comments__c'){
                component.set("v.writeComments",true);
            }
        }
        
        for(var item in readList){
            if(readList[item].key == 'Sub_Type__c' || readList[item].value == 'Sub Type'){
                component.set("v.writeSubType",false);
            }
            if(readList[item].key == 'Slides__c' || readList[item].value == 'Slides'){
                component.set("v.writeSlides",false);
            }
            if(readList[item].value == 'Link Text' || readList[item].key == 'Link_Text__c'){
                component.set("v.writeLink",false);
            }
            if(readList[item].value == 'Copy' || readList[item].key == 'Copy__c'){
                component.set("v.writeCopy",false);
            }
            if(readList[item].value == 'Asset Path' || readList[item].key == 'Asset_Path__c'){
                component.set("v.writeAsset",false);
            }
            if(readList[item].value == 'Comments' || readList[item].key == 'Comments__c'){
                component.set("v.writeComments",false);
            }
        }
        
    },
    createObjectData : function(component, event) {
        // get the detailList from component and add(push) New Object to List  
        var RowItemList = component.get("v.detailList");
        RowItemList.push({
            'sobjectType': 'Placement_Content_Detail__c',
            'Product_Link__c': '',
            'Type__c': '',
            'URL__c': '',
            'Page_Link__c':'',
            'Slides__c' : '',
            'Comments__c':'',
            'Placement_Content__c': component.get('v.contentId')
            //'Placement_Library__c': component.get('v.libraryId'),
        });
        // set the updated list to attribute (detailList) again    
        component.set("v.detailList", RowItemList);
    },
    cloneObjectData : function(component, event ,index) {
        // helper function to clone current row data to the next row  
        component.set("v.spinner",true);
        var RowItemList = component.get("v.detailList");
        let tempArray = JSON.parse(JSON.stringify( RowItemList ));
        let detailRecord = tempArray[index];
        let tempRec = JSON.parse(JSON.stringify( detailRecord ));
        
        tempRec.Id = null;
        tempArray.splice(parseInt(index)+1, 0,tempRec);
        
        // set the updated list to attribute (detailList) again
        component.set("v.detailList", tempArray);
        
        console.log('tempArray--',tempArray);
        component.set("v.spinner",false);
        
        var message = 'Row has been Cloned Successfully';
        this.showToast(component,'dismissible','Cloned!',message,'success');
    },
    deleteObjectData : function(component, event, index ,DetailInstance) {
    
        var detailRecord = component.get("v.recToBeDelted");
        //console.log('detailRecord to be deleted-----',detailRecord);
            
        if( detailRecord.Id != '' && detailRecord.Id != null){
            var delList = component.get("v.deleteList");
            delList.push(detailRecord);
            component.set("v.deleteList",delList);
            //console.log('delList---',delList);
        }
        
        // get the all List (detailList attribute) and remove the Object Element Using splice method    
        var AllRowsList = component.get("v.detailList");
        AllRowsList.splice(index, 1);
        // set the detailList after remove selected row element  
        component.set("v.detailList", AllRowsList);
        
        var message = 'Row has been Deteled';
        this.showToast(component,'dismissible','Record Deleted!',message,'success');
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
    initObjectData: function(component, event) {
        /*
        component.set("v.spinner",true);
        var action = component.get("c.initializeComp");
        action.setParams({
            'contentId' : component.get("v.contentId"),
            'selectedBrand' : component.get("v.brand")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var resultWrp = response.getReturnValue();
                //console.log('resultWrp-----',resultWrp);
                component.set("v.detailList",resultWrp.detailList);
                
                // mapping read field api name and label 
                var readList = [];
                var read = resultWrp.readFieldsMap;
                for ( var key in read ) {
                    readList.push({value:read[key], key:key});
                }
                component.set("v.readFieldsList",readList);
                //console.log('readList--',readList);
                
                // mapping write field api name and label
                var writeList = [];
                var write = resultWrp.writeFieldsMap;
                for ( var key in write ) {
                    writeList.push({value:write[key], key:key});
                }
                component.set("v.writeFieldsList",writeList);
                
                component.set("v.allFields",resultWrp.allfieldsList);
                component.set('v.hideSubType',resultWrp.isCarousel)
                //console.log('writeList--',writeList);
                this.setReadWriteFields(component, event);
                
                if(resultWrp.detailList == null || resultWrp.detailList == undefined || resultWrp.detailList.length == 0){
                    this.createObjectData(component, event);
                }
                component.set("v.spinner",false);
            }
            else if(state === 'ERROR'){
                component.set("v.spinner",false);
            }
        });
        $A.enqueueAction(action); */
    },
     saveObjectData : function(component, event) {
        /*
        component.set("v.spinner",true);
        var saveList = component.get("v.detailList");
       // console.log('saveList---',saveList);
        var recList = [];
        for(var rec in saveList){
            if(!((saveList[rec].Sub_Type__c == '')
               || (saveList[rec].Copy__c == 'Undefined'  && saveList[rec].Copy__c == '' )
               || (saveList[rec].Link_Text__c == 'Undefined' && saveList[rec].Link_Text__c == '' )
               || (saveList[rec].Asset_Path__c == 'Undefined' && saveList[rec].Asset_Path__c == '')
               || (saveList[rec].Slides__c == 'Undefined' && saveList[rec].Slides__c == ''))){
                
                recList.push(saveList[rec]);
            }
        }
        component.set("v.saveRecList",recList);
        //console.log('recList--to be saved--',recList);
        var action = component.get("c.saveDetails");
        action.setParams({
            "ListDetails": recList,
            "deleteList" : component.get("v.deleteList")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.spinner",false);
                var message = 'Record Saved Successfully';
                this.showToast(component,'dismissible','Success!',message,'success');
            }else if(  state === "ERROR"){
                component.set("v.spinner",false);
                var message = 'Something went wrong!!';
                this.showToast(component,'dismissible','Error!',message,'error');
            }
        });
        $A.enqueueAction(action); */
    },
     historyReplaceHpr : function(component, event, helper) {
        
        var contentData = component.get("v.detailList");
        var hisReplace = '';
        hisReplace = event.getParam('hisFields');
        var hisReplaceMap = [];
        hisReplaceMap = hisReplace.split("####");
        for(var key in contentData)
        {
            if(key == component.get("v.historyIndex")){
                
                for(var key2 in hisReplaceMap)
                {
                    var hisfld = hisReplaceMap[key2];
                    if(hisfld.split(":")[1] != undefined && hisfld.split(":")[1] !='undefined')  
                    contentData[key][hisfld.split(":")[0]] = hisfld.split(":")[1];
                    else
                    contentData[key][hisfld.split(":")[0]] = '';
                }
            }
        }
        component.set("v.detailList", contentData);
        this.showToast(component,'dismissible','Success !','Replaced Successfully, Click on Save','success');
        component.set("v.checkHistory",false);
        component.set("v.historyIndex",'');
        component.set("v.historyId",'');
    },
})