({
	initHpr : function(component,event) {        
        var action = component.get("c.fetchFilterValues");
        action.setCallback(this,function(result){
            var state = result.getState();
            if(state === 'SUCCESS')
            {
                var returnVal = result.getReturnValue();
                if(returnVal !== undefined)
                {
                    component.set('v.list_LibraryearchFilter', returnVal);
                }
            }
        });
        $A.enqueueAction(action);
    },
    fetchLibraryJsHpr : function(component,event,helper) {
        component.set('v.columns', [
            {label: 'Name', fieldName: 'nameVal' , type: 'text'}
        ]);
        var lib_search = component.get("v.list_LibraryearchFilter")[0];
        lib_search.Brands__c = component.get("v.selectedBrand");
        lib_search.Page_Types__c = component.get("v.selectedPageType");
        lib_search.Start_Date__c = component.get("v.dateSelect");
        lib_search.Main_Message__c = component.get("v.mainMsg");   
        lib_search.Editorial_Name__c = component.get("v.editorialName"); 
        
        if( component.get("v.selectedBrand") == '' || component.get("v.selectedPageType") == '' ||  component.get("v.dateSelect") == null )
        {
            
            //component.set("v.spinner",false); 
            this.showToast(component,'dismissible','Failed','Brand, Page Type,Date Mandatory..!!','error');
        } else {  
                    
			var action = component.get("c.fetchLibrary");
            action.setStorable();
			action.setParams({'lib_search':lib_search});
		   
			action.setCallback(this,function(result){
				var state = result.getState();
				if(state === 'SUCCESS')
				{
                    
					var returnVal = result.getReturnValue();
					if(returnVal !== undefined && returnVal != '')
					{     
                       	component.set("v.placementContents",returnVal);
                        component.set("v.totalPages", Math.ceil(result.getReturnValue().length/component.get("v.pageSize")));
                		
                        for (var i = 0; i < returnVal.length; i++) {
                            var row = returnVal[i];console.log('row.Name---',row.Name);
                            row.nameVal = row.Name.split(" - ")[2]   ;
                            row.nameVal = row.Name.split(" - ")[3] != undefined ? row.nameVal + ' - '+row.Name.split(" - ")[3] : row.nameVal +'' ;
                        }
                        
                        component.set("v.allData", returnVal);
                		component.set("v.currentPageNumber",1);
                		helper.buildData(component, helper);
						component.set("v.spinner",false);
                        
					}
					else
					{
						component.set("v.spinner",false);
						this.showToast(component,'dismissible','Failed','No Library found ','error');
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
            var requestInitiatedTime = new Date().getTime();
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
    addContsHpr : function(component,event, recordsIds) {
        var action = component.get("c.getSelectedConts");
        action.setParams({'lst_SelectedContIds': recordsIds,"pLayoutId":component.get("v.payLayoutId")});
        action.setCallback(this,function(result){
            var state = result.getState();
            console.log('---state--'+state);
            if(state === 'SUCCESS')
            {
                var returnVal = result.getReturnValue();
                console.log('--returnVal--'+returnVal);
                if(returnVal != undefined  )
                {
                    console.log('--if returnval');
                     var cmpEvent = component.getEvent("searchFromLibrary");
                    cmpEvent.setParams( { "searchFromLibrary" : returnVal,"openModal" : false } );
                    cmpEvent.fire();
                }else{
                console.log('--else returnval');
                this.showToast(component,'dismissible','Failed','Content already exist','error');
            }
            }
            
        });
        $A.enqueueAction(action);
    },
    /*
     * this function will build table data
     * based on current page selection
     * */
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
        component.set("v.data", data);
        
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
    clearVariables : function(component, event, helper) {
        var conts = [];
        component.set('v.placementContents',conts);
		component.set("v.spinner",false);  
    }
})