({
	init : function(component, event, helper) {
        //is called from Rerderer
		//helper.fetchAllContentsHpr(component, event,true);
	},
    callInit : function(component, event, helper) {
        component.set("v.isContentCascaded",false);
        component.set("v.deletedIds",[]);
        var unsaved = component.find("unsaved");
        unsaved.setUnsavedChanges(false);
		helper.fetchAllContentsHpr(component, event,helper);
	},
    selectMainContField : function(component, event, helper) {
		helper.selectMainContFieldHpr(component, event);
	},
    selectMainContDetField : function(component, event, helper) {
		helper.selectMainContDetFieldHpr(component, event);
	},
    promotePlcContentRow : function(component, event, helper) {
        component.set("v.Spinner",true);
        helper.promotePlcContentRowHpr(component, event);
    },
    revertPlcContentRow : function(component, event, helper) {
        component.set("v.Spinner",true);
        helper.revertPlcContentRowHpr(component, event);
    },
    promotePcDetailRow : function(component, event, helper) {
        component.set("v.Spinner",true);
        component.set("v.popOverShowCombination",event.getSource().get('v.value'));
        component.set("v.Spinner",false);
    },
    choosePlcContentDetailRecord : function(component, event, helper) {
        var selvar = event.currentTarget.dataset.placeid;
        if(selvar.split('@').length === 4){
            helper.choosePlcContentDetailRecordHpr(component, event, selvar.split('@')[0]+'@'+selvar.split('@')[1]+'@'+selvar.split('@')[3]);
        }
        else{
            helper.choosePcDetailRowForNewhpr(component, event, selvar);
        }
        component.set("v.isContentCascaded",true);
    },
    choosePlcContentDetailRecordIcon : function(component, event, helper) {
        helper.choosePlcContentDetailRecordHpr(component, event, event.getSource().get("v.value"));
        component.set("v.isContentCascaded",true);
    },
    addPcDetailRowForNew : function(component, event, helper) {
        component.set("v.Spinner",true);
        component.set("v.popOverShowCombination",event.getSource().get('v.value'));
        component.set("v.Spinner",false);
    },
    removePlcDet : function(component, event, helper) {
        component.set("v.Spinner",true);
        helper.removePlcDetHpr(component, event);
    },
    promoteAll : function(component, event, helper) {
        helper.promoteAllHpr(component, event);
    },
    promoteAllDetails : function(component, event, helper) {
        helper.promoteAllDetailsHpr(component, event);
    },
    saveAll : function(component, event, helper) {
        helper.saveAllHpr(component, event);
        var unsaved = component.find("unsaved");
        unsaved.setUnsavedChanges(false);
    },
    closePopOver : function(component, event, helper) {
        component.set("v.popOverShowCombination","");
    }
})
