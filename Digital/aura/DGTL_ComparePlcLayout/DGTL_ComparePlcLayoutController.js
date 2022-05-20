({
    init : function(component, event, helper) {
        // these values are onlu to display on the UI
        let lockedDetailFields = ['ContentDetails'];
        component.set("v.lockedDetailFields",lockedDetailFields);
		helper.initHpr(component, event);
	},
	fetchLayouts : function(component, event, helper) {
		helper.fetchLayoutsHpr(component, event);
	},
    navigateToLayout : function(component, event, helper) {
        var targetElement = event.currentTarget;
    	var targetId = targetElement.dataset.value;
        console.log("targetId---",targetId);
        helper.fetchLayoutRecHpr(component, event,targetId);
	},
     onChangeBrand : function(component,event,helper){
         var params = event.getParams();
         component.set("v.finalData",null);
         component.set("v.selectedBrand",params.value);
         component.set("v.userPreferences",{});
         if(params.value){
             helper.getUserPreference(component, event);
         }else component.set("v.hasAccessManagement",false);
    },
    onChangePageType : function(component,event,helper){
        var params = event.getParams();
        component.set("v.selectedPageType",params.value);
        if(params.value == 'Editorials'){
            helper.getEditorialOption(component,event,helper,true);
        }
    },
    onDeviceType : function(component,event){
        var params = event.getParams(); 
        var deviceType = String(params.value);
        component.set("v.deviceType",deviceType);
        
        //--- add styles to show Field is required
       /* var deviceEle = component.find('deviceTypeID');
        if(component.get("v.deviceType") != ''){
            $A.util.removeClass(deviceEle, 'slds-has-error');
        }else{
            $A.util.addClass(deviceEle, 'slds-has-error');
        }*/
    },
    
    closeModal:function(component){
       component.set("v.viewRecord",false);
       component.set("v.viewHistory",false);
       component.set("v.showInfo",false);
       component.set("v.currentInfo",'');
       component.set("v.showFieldsToSelect",false);
       component.set("v.selectedValues",component.get("v.userPreferences.selectedOptions"));
    },
    
    viewRecord:function(component,event){
        component.set("v.viewRecordId",event.target.getAttribute('data-recid'));
        component.set("v.viewRecord",true);
    },
    
    handleEditorialTypeahead:function(component,event,helper){
        helper.getEditorialOption(component,event,helper,false);
    },
    
    showFields : function(component, event, helper){
        if(component.get("v.selectedBrand")){
          component.set("v.showFieldsToSelect",true);  
        }else{
            helper.showToast(component,'dismissible','Failed','Brand is required to set preferences!','error');
        }
    },
    
    saveUserPreferences : function(component, event, helper){
        let selectedValues = component.get("v.selectedValues");
        
        
       // if(selectedValues && selectedValues.length > 0){
            component.set("v.userPreferences.selectedOptions",component.get("v.selectedValues"));
            helper.saveCompareSetup(component,event);
            component.set("v.showFieldsToSelect",false);
       /* }else{
            helper.showToast(component,'dismissible','Failed','Preferences can not be empty!','error');
        }*/
        
    },
    
    showChangesIcon: function(component, event, helper){
        let layoutIndex = event.target.getAttribute('data-index');
        let layout = component.get("v.finalData.list_pLayoutWpr");
        if(layout[layoutIndex].showChanges){
            helper.setAcknowledgement(component, event, layout, layoutIndex);
        }else{
            helper.getContentWithHistory(component,layoutIndex);
            //layout[layoutIndex].showChanges = true;
            //component.set("v.finalData.list_pLayoutWpr",layout);
        }
    },
    
    showContentHistory : function(component, event, helper){
        let idCombo = event.getSource().get("v.name");
        helper.getContentHistory(component, event, idCombo);
    },
    
    showInfo : function(component, event, helper){
        let changesData = event.getSource().get("v.name");
        console.log('changesData---'+JSON.stringify(changesData));
        if(changesData.detailChanges && changesData.detailChanges.length > 0){
            for(var index in changesData.detailChanges){
                 changesData.detailChanges[index].copy = changesData.detailChanges[index].name.split('~~')[0];
                changesData.detailChanges[index].url = changesData.detailChanges[index].name.split('~~')[1];
            }
        }
        component.set("v.changeDataObj",changesData); 
        component.set("v.showInfo",true);
    }

})