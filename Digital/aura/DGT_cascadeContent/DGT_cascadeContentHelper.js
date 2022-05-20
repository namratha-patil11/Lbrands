({
    fetchAllContentsHpr : function(component,event,helper) {
        component.set("v.Spinner",true);
        var action = component.get("c.fetchContents");
        action.setParams({'recId':component.get("v.recordId")});
        action.setCallback(this,function(result){
            if(result.getState() === 'SUCCESS')
            {
                if(result.getReturnValue() != undefined)
                {
                    var rVal = result.getReturnValue();
                    let initialLoad = component.get("v.isInitialLoad");
                    component.set("v.mainReturnValue",rVal);
                    component.set("v.mainContent",rVal.mainPlcContent);
                    component.set("v.allRelatedContents",rVal.list_PlcContents);
                    component.set("v.Spinner",false);
                    component.set("v.linkKODs",false);
                    component.set("v.isInitialLoad",false);
                }
                else
                {
                    component.set("v.Spinner",false);
                    this.showToast(component,'dismissible','Failed','Error','error');
                }
            }
            else
            {
                component.set("v.Spinner",false);
                this.showToast(component,'dismissible','Failed','Error','error');
            }
        });
        $A.enqueueAction(action);
    },
    selectMainContFieldHpr : function(component,event) {
        component.set("v.Spinner",true);
        var selectLocation = event.currentTarget.dataset.placeid;
        var mainPlcContent = component.get("v.mainContent");
        mainPlcContent.list_PlContentFieldData[selectLocation].isChecked = !mainPlcContent.list_PlContentFieldData[selectLocation].isChecked;
        component.set("v.mainContent",mainPlcContent);
        component.set("v.Spinner",false);
    },
    selectMainContDetFieldHpr : function(component,event) { 
        component.set("v.Spinner",true);
        var selectLocation = event.currentTarget.dataset.placeid;
        //alert(selectLocation);
        var detRowIndex = selectLocation.split("@")[0];
        var detRowFieldIndex = selectLocation.split("@")[1];
        var mainPlcContent = component.get("v.mainContent");
        mainPlcContent.list_contentDetWpr[detRowIndex].list_PlcConDetFieldData[detRowFieldIndex].isChecked = !mainPlcContent.list_contentDetWpr[detRowIndex].list_PlcConDetFieldData[detRowFieldIndex].isChecked;
        var currentDetail = mainPlcContent.list_contentDetWpr[detRowIndex].list_PlcConDetFieldData[detRowFieldIndex];
        
        for(var i=0;i<mainPlcContent.list_contentDetWpr.length;i++){
            if(detRowIndex != i){
                for(var k=0;k<mainPlcContent.list_contentDetWpr[i].list_PlcConDetFieldData.length;k++){
                    var detail = mainPlcContent.list_contentDetWpr[i].list_PlcConDetFieldData[k];
                    if(detail.fieldApi == currentDetail.fieldApi && currentDetail.isChecked){
                        detail.isChecked = false;
                    }
                }
            }
        }
        component.set("v.mainContent",mainPlcContent);
        component.set("v.Spinner",false);
    },
    promotePlcContentRowHpr : function(component,event) {
        component.set("v.Spinner",true);
        var allRelContents = component.get("v.allRelatedContents");
        var mainPlcContent = component.get("v.mainContent");
        var parentIndex = event.getSource().get("v.value");
        for(var j=0;j<allRelContents[parentIndex].list_PlContentFieldData.length;j++){
            var relatedContentFiled = allRelContents[parentIndex].list_PlContentFieldData[j];
            for(var k=0;k<mainPlcContent.list_PlContentFieldData.length;k++){
                var mainContentField = mainPlcContent.list_PlContentFieldData[k];
                if(mainContentField.isChecked && mainContentField.fieldApi === relatedContentFiled.fieldApi){
                    if(mainContentField.fieldType === 'boolean'){
                        allRelContents[parentIndex].plContent[relatedContentFiled.fieldApi] =  JSON.parse(mainContentField.newFieldValue); 
                    }
                    else{
                        allRelContents[parentIndex].plContent[relatedContentFiled.fieldApi] = mainContentField.newFieldValue; 
                    }
                    relatedContentFiled.newFieldValue = mainContentField.newFieldValue;
                }
            }
        }
        component.set("v.allRelatedContents",allRelContents);
        component.set("v.popOverShowCombination","");
        component.set("v.Spinner",false);
    },
    revertPlcContentRowHpr : function(component,event) {
        component.set("v.Spinner",true);
        var allRelContents = component.get("v.allRelatedContents");
        var parentIndex = event.getSource().get("v.value");
        allRelContents[parentIndex].linkedKods = allRelContents[parentIndex].oldlinkedKods;
        allRelContents[parentIndex].isContentSelected = false;
        for(var j=0;j<allRelContents[parentIndex].list_PlContentFieldData.length;j++){
            var relatedContentFiled = allRelContents[parentIndex].list_PlContentFieldData[j];
            
            if(relatedContentFiled.fieldType === 'boolean'){
                allRelContents[parentIndex].plContent[relatedContentFiled.fieldApi] =  JSON.parse(relatedContentFiled.actualFieldValue); 
            }
            else{
                allRelContents[parentIndex].plContent[relatedContentFiled.fieldApi] = relatedContentFiled.actualFieldValue; 
            }
            relatedContentFiled.newFieldValue = relatedContentFiled.actualFieldValue;
        }
        
        component.set("v.allRelatedContents",allRelContents);
        component.set("v.popOverShowCombination","");
        component.set("v.Spinner",false);
    },
    choosePlcContentDetailRecordHpr : function(component,event,sLocation) {
        component.set("v.Spinner",true);
        var allRelContents = component.get("v.allRelatedContents");
        var mainPlcContent = component.get("v.mainContent");
        var selectLocation = sLocation;
        
        var parentIndex = selectLocation.split('@')[0];
        var childIndex = selectLocation.split('@')[1];
        var selectedVal = selectLocation.split('@')[2];
        
        var choosedPCD;
        if(selectedVal === 'revert'){
            choosedPCD = allRelContents[parentIndex].list_contentDetWpr[childIndex].list_PlcConDetFieldData;
        }
        else{
            choosedPCD = mainPlcContent.list_contentDetWpr[selectedVal].list_PlcConDetFieldData;
        }
        var updatingPCD = allRelContents[parentIndex].list_contentDetWpr[childIndex];
        for(var i=0;i<choosedPCD.length;i++){
            var mainPCD = choosedPCD[i];
            for(var j=0;j<updatingPCD.list_PlcConDetFieldData.length;j++){
                if(updatingPCD.list_PlcConDetFieldData[j].fieldApi === mainPCD.fieldApi){
                    if(selectedVal === 'revert'){
                        if(mainPCD.fieldType === 'boolean'){
                            allRelContents[parentIndex].list_contentDetWpr[childIndex].plContentDetail[allRelContents[parentIndex].list_contentDetWpr[childIndex].list_PlcConDetFieldData[j].fieldApi] =  JSON.parse(mainPCD.actualFieldValue);
                        }
                        else{
                            allRelContents[parentIndex].list_contentDetWpr[childIndex].plContentDetail[allRelContents[parentIndex].list_contentDetWpr[childIndex].list_PlcConDetFieldData[j].fieldApi] =  mainPCD.actualFieldValue;
                        }
                        updatingPCD.list_PlcConDetFieldData[j].newFieldValue = mainPCD.actualFieldValue;
                    }
                    else{
                        if(mainPCD.fieldType === 'boolean'){
                            allRelContents[parentIndex].list_contentDetWpr[childIndex].plContentDetail[allRelContents[parentIndex].list_contentDetWpr[childIndex].list_PlcConDetFieldData[j].fieldApi] =  JSON.parse(mainPCD.newFieldValue);
                        }
                        else{
                            allRelContents[parentIndex].list_contentDetWpr[childIndex].plContentDetail[allRelContents[parentIndex].list_contentDetWpr[childIndex].list_PlcConDetFieldData[j].fieldApi] =  mainPCD.newFieldValue;
                        }
                        updatingPCD.list_PlcConDetFieldData[j].newFieldValue = mainPCD.newFieldValue;
                    }
                }
            }
        }
        var unsaved = component.find("unsaved");
        unsaved.setUnsavedChanges(true, { label: component.get("v.unsavedChangesMessage") });
        component.set("v.allRelatedContents",allRelContents);
        component.set("v.popOverShowCombination","");
        component.set("v.Spinner",false);
    },
    choosePcDetailRowForNewhpr : function(component, event, combination) {
        component.set("v.Spinner",true);
        var allRelContents = component.get("v.allRelatedContents");
        var mainPlcContent = component.get("v.mainContent");
        
        var parentIndex = combination.split('@')[0];
        var plConId = combination.split('@')[1];
        var selectedVal = combination.split('@')[2];
        var selPCD = mainPlcContent.list_contentDetWpr[selectedVal];
        var action = component.get("c.addNewPlConDet");
        action.setParams({'plcId':plConId,
                          'selectedPlcDet':selPCD});
        action.setCallback(this,function(result){
            if(result.getState() === 'SUCCESS')
            {
                if(result.getReturnValue() != undefined)
                {
                    allRelContents[parentIndex].list_contentDetWpr.push(result.getReturnValue());
                    component.set("v.allRelatedContents",allRelContents);
                    component.set("v.popOverShowCombination","");
                    component.set("v.Spinner",false);
                    var unsaved = component.find("unsaved");
                    unsaved.setUnsavedChanges(true, { label: component.get("v.unsavedChangesMessage") });
                    this.showToast(component,'dismissible','Success','Added Successfully !','success');
                }
                else
                {
                    component.set("v.Spinner",false);
                    this.showToast(component,'dismissible','Failed','Error','error');
                }
            }
            else
            {
                component.set("v.Spinner",false);
                this.showToast(component,'dismissible','Failed','Error','error');
            }
        });
        $A.enqueueAction(action);
    },
    removePlcDetHpr : function(component, event) {
        component.set("v.Spinner",true);
        var allRelContents = component.get("v.allRelatedContents");
        var selectedValue = event.getSource().get("v.value");
        var parentIndex = selectedValue.split("@")[0];
        var childIndex = selectedValue.split("@")[1];
        //var detailId = selectedValue.split("@")[2];
        allRelContents[parentIndex].list_contentDetWpr.splice(childIndex,1);
        component.set("v.allRelatedContents",allRelContents);
        component.set("v.Spinner",false);
        var unsaved = component.find("unsaved");
        unsaved.setUnsavedChanges(true, { label: component.get("v.unsavedChangesMessage") });
        //----------------adding deleted Id to list
        var deleteId_List = component.get("v.deletedIds");
        if(allRelContents[parentIndex].plContent.Placement_Content_Details__r != undefined && allRelContents[parentIndex].plContent.Placement_Content_Details__r[childIndex] != null &&
           allRelContents[parentIndex].plContent.Placement_Content_Details__r[childIndex] != undefined){
            var detailId = allRelContents[parentIndex].plContent.Placement_Content_Details__r[childIndex].Id;
            if(detailId != null && detailId != undefined){
                deleteId_List.push(detailId);
            }
        }
    },
    promoteAllHpr : function(component, event) {
        component.set("v.Spinner",true);
        var allRelContents = component.get("v.allRelatedContents");
        var mainPlcContent = component.get("v.mainContent");
        var selectedFieldsCount = 0;
        var selectedRecordsCount = 0;
        
        for(var k=0;k<mainPlcContent.list_PlContentFieldData.length;k++){
            var mainContentField = mainPlcContent.list_PlContentFieldData[k];
            if(mainContentField.isChecked){
                selectedFieldsCount++;
            }
        }
        for(var i=0;i<allRelContents.length;i++){
            if(allRelContents[i].isContentSelected){
                selectedRecordsCount++;
            }
        }
        if(!component.get("v.linkKODs") && selectedFieldsCount == 0 && selectedRecordsCount == 0){
            component.set("v.Spinner",false);
            this.showToast(component,'dismissible','Failed','At-least one field/Linked KODS  and at-least one Content should be Selected !','error');
        }
        else if((component.get("v.linkKODs") || selectedFieldsCount > 0) && selectedRecordsCount == 0){
            component.set("v.Spinner",false);
            this.showToast(component,'dismissible','Failed','At-least one Content should be Selected !','error');
        }else if(!component.get("v.linkKODs") && selectedFieldsCount == 0 && selectedRecordsCount > 0){
                component.set("v.Spinner",false);
                this.showToast(component,'dismissible','Failed','At-least one main Content field/Linked KODS  should be Selected !','error');
            }else{
                component.set("v.isContentCascaded",true);
                var selectedContKod = [];
                  var linkKod =  component.get("v.linkKODs");
                for(var i=0;i<allRelContents.length;i++){
                    //Mapping Placement Content Fields
                    if(allRelContents[i].isContentSelected){
                        //Check for link kod is selected
                        if(linkKod){
                            // adding selected content id to link kods
                            selectedContKod.push(allRelContents[i].plContent['Id'] ); 
                            allRelContents[i].linkedKods = component.get("v.mainReturnValue.linkedKods");
                        }
                        
                        for(var j=0;j<allRelContents[i].list_PlContentFieldData.length;j++){
                            var relatedContentFiled = allRelContents[i].list_PlContentFieldData[j];
                            for(var k=0;k<mainPlcContent.list_PlContentFieldData.length;k++){
                                var mainContentField = mainPlcContent.list_PlContentFieldData[k];
                                if(mainContentField.isChecked && mainContentField.fieldApi === relatedContentFiled.fieldApi){
                                    if(mainContentField.fieldType === 'boolean'){
                                        allRelContents[i].plContent[relatedContentFiled.fieldApi] =  JSON.parse(mainContentField.newFieldValue); 
                                    }
                                    else{
                                        if(mainContentField.newFieldValue === undefined){
                                            allRelContents[i].plContent[relatedContentFiled.fieldApi] = '';
                                        }else{
                                            allRelContents[i].plContent[relatedContentFiled.fieldApi] = mainContentField.newFieldValue; 
                                        }
                                    }
                                    relatedContentFiled.newFieldValue = mainContentField.newFieldValue;
                                }
                            }
                        }
                    }
                }
                
                component.set("v.allRelatedContents",allRelContents);
                component.set("v.popOverShowCombination",""); 
                component.set("v.Spinner",false);
                component.set("v.seleContIdKod",selectedContKod);
                var unsaved = component.find("unsaved");
                unsaved.setUnsavedChanges(true, { label: component.get("v.unsavedChangesMessage") });
                this.showToast(component,'dismissible','Success','Click on \"Save\" to confirm changes','success');
            }
    },
    promoteAllDetailsHpr : function(component, event) {
        component.set("v.Spinner",true);
        var allRelContents = component.get("v.allRelatedContents");
        var mainPlcContent = component.get("v.mainContent");
        var selectedFieldsCount = 0;
        var selectedRecordsCount = 0;
        
        for(var i=0;i<mainPlcContent.list_contentDetWpr.length;i++){
            for(var j=0;j<mainPlcContent.list_contentDetWpr[i].list_PlcConDetFieldData.length;j++){
                if(mainPlcContent.list_contentDetWpr[i].list_PlcConDetFieldData[j].isChecked){
                    selectedFieldsCount++;
                }
            }
        }
        for(var i=0;i<allRelContents.length;i++){
            for(var j=0;j<allRelContents[i].list_contentDetWpr.length;j++){
                if(allRelContents[i].list_contentDetWpr[j].isConDetSelected){
                    selectedRecordsCount++;
                }
            }
        }
        if(selectedFieldsCount == 0 && selectedRecordsCount == 0){
            component.set("v.Spinner",false);
            this.showToast(component,'dismissible','Failed','At-least one main Content field and at-least one Content Detail should be Selected..!!','error');
        }
        else if(selectedFieldsCount > 0 && selectedRecordsCount == 0){
            component.set("v.Spinner",false);
            this.showToast(component,'dismissible','Failed','At-least one Content Detail should be Selected..!!','error');
        }else if(selectedFieldsCount == 0 && selectedRecordsCount > 0){
            component.set("v.Spinner",false);
            this.showToast(component,'dismissible','Failed','At-least one main Content Detail field should be Selected..!!','error');
        }else{
            component.set("v.isContentCascaded",true);
            for(var i=0;i<allRelContents.length;i++){
                for(var j=0;j<allRelContents[i].list_contentDetWpr.length;j++){
                    if(allRelContents[i].list_contentDetWpr[j].isConDetSelected){
                        for(var k=0;k<allRelContents[i].list_contentDetWpr[j].list_PlcConDetFieldData.length;k++){
                            var relDetail = allRelContents[i].list_contentDetWpr[j].list_PlcConDetFieldData[k];
                            for(var m=0;m<mainPlcContent.list_contentDetWpr.length;m++){
                                for(var n=0;n<mainPlcContent.list_contentDetWpr[m].list_PlcConDetFieldData.length;n++){
                                    var mainDetail = mainPlcContent.list_contentDetWpr[m].list_PlcConDetFieldData[n];
                                    if(mainDetail.isChecked && mainDetail.fieldApi === relDetail.fieldApi){
                                        relDetail.newFieldValue = mainDetail.newFieldValue;
                                        if(relDetail.fieldType == 'boolean'){
                                            allRelContents[i].list_contentDetWpr[j].plContentDetail[relDetail.fieldApi] = JSON.parse(mainDetail.newFieldValue);
                                        }
                                        else{
                                            if(mainDetail.newFieldValue === undefined){
                                                allRelContents[i].list_contentDetWpr[j].plContentDetail[relDetail.fieldApi] = '';
                                            }else{
                                                allRelContents[i].list_contentDetWpr[j].plContentDetail[relDetail.fieldApi] = mainDetail.newFieldValue;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            component.set("v.allRelatedContents",allRelContents);
            component.set("v.popOverShowCombination","");
            component.set("v.Spinner",false);
            var unsaved = component.find("unsaved");
            unsaved.setUnsavedChanges(true, { label: component.get("v.unsavedChangesMessage") });
            this.showToast(component,'dismissible','Success','Click on \"Save\" to confirm changes','success');
        }
    },
    saveAllHpr : function(component,event){
        component.set("v.Spinner",true);
        var placementContents = [];
        var placementContentDetails = [];
        var selectedContKod = [];
        var linkKod =  component.get("v.linkKODs");
        var allRelContents = component.get("v.allRelatedContents");
        for(var i=0;i<allRelContents.length;i++){
            // Check for link kod and selected contents to link kod
            if(linkKod && allRelContents[i].isContentSelected){
                // adding selected content id to link kods
                selectedContKod.push(allRelContents[i].plContent['Id'] );
                }
            placementContents.push(allRelContents[i].plContent);
            
            if(allRelContents[i].list_contentDetWpr != undefined && allRelContents[i].list_contentDetWpr.length>0){
                for(var j=0;j<allRelContents[i].list_contentDetWpr.length;j++){
                    placementContentDetails.push(allRelContents[i].list_contentDetWpr[j].plContentDetail);
                }
            }
        }
        var action = component.get("c.saveContents");
        action.setParams({'list_NewPlcContents':placementContents,
                          'list_NewPlcConDets':placementContentDetails,
                          'linkKODs' : component.get("v.linkKODs"),
                          'selContKod' : selectedContKod,
                          'contId' : component.get("v.mainContent.plContent.Id")});
        action.setCallback(this,function(result){
            if(result.getState() === 'SUCCESS'){
                if(result.getReturnValue() != undefined){
                    if(result.getReturnValue() === 'Success'){
                        this.fetchAllContentsHpr(component, event,false);
                        component.set("v.Spinner",false);
                        this.showToast(component,'dismissible','Success','Cascade Successful !','success');
                    }
                    else{
                        component.set("v.Spinner",false);
                        this.showToast(component,'dismissible','Failed',result.getReturnValue(),'error');
                    }
                }
                else{
                    component.set("v.Spinner",false);
                    this.showToast(component,'dismissible','Failed','Error','error');
                }
            }
            else{
                component.set("v.Spinner",false);
                this.showToast(component,'dismissible','Failed','Error','error');
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
    }
})
