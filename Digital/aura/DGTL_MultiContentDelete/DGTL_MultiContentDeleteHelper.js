({
    initHpr : function(component,event,helper) {  
        component.set("v.spinner",true);
        var content = component.get("v.content");
        var contentObj = JSON.parse(JSON.stringify(content));
        component.set("v.contentObj",contentObj);
        
        if(contentObj != undefined ){
            if((contentObj.Placement_Library__c == undefined || contentObj.Placement_Library__c == null) /*||
               (contentObj.Type__c != undefined && contentObj.Type__c != 'Controlled')*/){
                component.set("v.disableRadio",true);
                component.set("v.showTable",true);

            } else{
                var action =  component.get("c.getRelatedPlacements");
                action.setParams({
                    'content' : contentObj
                });
                action.setCallback(this,function(result){
                    var state = result.getState();
                    if(state === 'SUCCESS')
                    {   
                        if(result.getReturnValue() != null){
                            var response = result.getReturnValue();
                        }
                        if(response != null){
                            console.log("-----result---delete---",response);
                            component.set("v.showTable",true);
                            component.set("v.listLockedContents",response.list_LockedContents);
                            component.set("v.listPlacementContents",response.list_Contents);
                             component.set("v.nonCotrolled",response.list_nonControlled);
                            component.set("v.currentPageNumber",1);
                            //helper.buildData(component, helper);
                        }
                    }else if( state === 'ERROR'){
                        console.log('ERROR : error in getting related contents ');
                    }
                });
                $A.enqueueAction(action);
                component.set("v.spinner",true);
                component.set("v.addColumns", [
                    {label:'Name', fieldName:'Name',type: 'text'},
                    {label:'Main Message', fieldName:'Main_Message__c',type: 'text'}
                ]);
            }
        }
     component.set("v.spinner",false);
    },
    deleteHpr : function(component,event) {  
        if(component.get("v.choosenValue") == 'DeleteContent'){
            var list_contents = [];
            list_contents.push(component.get("v.content"));
        }else{
            var list_contents = component.get("v.selectedPlacementContents");
        }
        var action =  component.get("c.deletePlacements");
        action.setParams({
            'list_Contents' : list_contents
        });
        action.setCallback(this,function(result){
            var state = result.getState();
            if(state === 'SUCCESS')
            {   
                this.showToast(component,'dismissible','Success','Placement(s) deleted Successfully !','success');
                component.set("v.openMultiContentDelete",false);
                
                // fire event to call search in DGTL_Layouts
                component.getEvent("closeKODPopup").setParams({
                    'close' : true
                }).fire();
                
            }else if( state === 'ERROR'){
                var returnVal = result.getReturnValue();
                console.log('ERROR : error in getting related contents ');
                this.showToast(component,'dismissible','Failed',returnVal,'error');
            }
        });
        $A.enqueueAction(action);
    },
    buildData : function(component, helper) {
        var data = [];
        var pageNumber = component.get("v.currentPageNumber");
        var pageSize = component.get("v.pageSize");
        var allData = component.get("v.allData");
        var x = (pageNumber-1)*pageSize;
        
        //creating data-table data
        for(; x<=(pageNumber)*pageSize; x++){
            if(allData[x]){
                data.push(allData[x]);
            }
        }
        component.set("v.listPlacementContents", data);
        helper.generatePageList(component, pageNumber);
    },
    
    /*
     * this function generate page list
     * */
    generatePageList : function(component, pageNumber){
        pageNumber = parseInt(pageNumber);
        var pageList = [];
        var totalPages = component.get("v.totalPages");
        if(totalPages > 1){
            if(totalPages <= 10){
                var counter = 2;
                for(; counter < (totalPages); counter++){
                    pageList.push(counter);
                } 
            } else{
                if(pageNumber < 5){
                    pageList.push(2, 3, 4, 5, 6);
                } else{
                    if(pageNumber>(totalPages-5)){
                        pageList.push(totalPages-5, totalPages-4, totalPages-3, totalPages-2, totalPages-1);
                    } else{
                        pageList.push(pageNumber-2, pageNumber-1, pageNumber, pageNumber+1, pageNumber+2);
                    }
                }
            }
        }
        component.set("v.pageList", pageList);
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
