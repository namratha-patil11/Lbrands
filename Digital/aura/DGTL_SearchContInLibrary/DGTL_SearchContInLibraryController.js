({
	init : function(component, event, helper) {
        component.set("v.spinner",true);
        helper.initHpr(component, event);
        component.set("v.spinner",false);
    },
    onChangeBrand : function(component, event, helper){
        component.set("v.spinner",true);
        var params = event.getParams();
        component.set("v.selectedBrand",params.value);
        helper.clearVariables(component, event, helper);
    },
    onChangePageType : function(component, event, helper){
        component.set("v.spinner",true);
        var params = event.getParams();
        component.set("v.selectedPageType",params.value);
        helper.clearVariables(component, event, helper);
    },
    onChangeDate : function(component, event, helper){
        component.set("v.spinner",true);
        var params = event.getParams();
        component.set("v.dateSelect",params.value);
        helper.clearVariables(component, event, helper);
    },
    onChangeMainMsg : function(component, event, helper){
        component.set("v.spinner",true);
        var params = event.getParams();
        component.set("v.mainMsg",params.value);
        helper.clearVariables(component, event, helper);
    },
    fetchLibraryJs : function(component, event, helper) {
        component.set("v.spinner",true);
        helper.fetchLibraryJsHpr(component, event,helper);
        component.set("v.spinner",false);
    },    
    addConts : function(component, event, helper) {
        component.set("v.spinner",true);
       /* var contIds = [];
        var conts = component.get("v.selectedContents");
        for(var key in conts)
        {
            var objcont = conts[key];
            for(var key in objcont)
                {
                    contIds.push(objcont[key]);
                    break;
                }
        }
        */
      helper.addContsHpr(component, event, component.get("v.selectedContents"));
        component.set("v.spinner",false);
    },
    closeModalBox : function(component, event, helper) {
        var cmpEvent = component.getEvent("searchFromLibrary");
        cmpEvent.setParams( { "openModal" : false } );
        cmpEvent.fire();
         //component.destroy();
    },
    onNext : function(component, event, helper) {
	component.set("v.spinner",true);        
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber+1);
        helper.buildData(component, helper);
        component.set("v.spinner",false);
    },
    
    onPrev : function(component, event, helper) { 
        component.set("v.spinner",true);
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber-1);
        helper.buildData(component, helper);
        component.set("v.spinner",false);
    },
    
    processMe : function(component, event, helper) {
        component.set("v.spinner",true);
        component.set("v.currentPageNumber", parseInt(event.target.name));
        helper.buildData(component, helper);
        component.set("v.spinner",false);
    },
    
    onFirst : function(component, event, helper) { 
        component.set("v.spinner",true);
        component.set("v.currentPageNumber", 1);
        helper.buildData(component, helper);
        component.set("v.spinner",false);
    },
    
    onLast : function(component, event, helper) { 
        component.set("v.spinner",true);
        component.set("v.currentPageNumber", component.get("v.totalPages"));
        helper.buildData(component, helper);
        component.set("v.spinner",false);
    },
    addContId : function(component, event, helper) { 
         var selectedRows = event.getParam('selectedRows');
         var selectedIds = [];
         for(var key in selectedRows)
         {             
             var obj = selectedRows[key];
             for(var key in obj)
             {
                 selectedIds.push(obj['Id']);
                 break;
             }
         }
        //alert('--selectedIds--'+selectedIds);
        component.set("v.selectedContents",selectedIds);
       // helper.addContsHpr(component, event,selectedIds)
    },
    
})