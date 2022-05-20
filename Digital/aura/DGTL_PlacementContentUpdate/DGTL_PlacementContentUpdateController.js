({
    doInit : function(component, event, helper) {
        helper.initHelper(component, event, helper);
    },
    contentChanged : function(component, event, helper) {
        console.log('change----');
        var ctarget = event.currentTarget;
        var id_str = ctarget.dataset.value; 
        //console.log('changed field....',id_str);
        var changedList = component.get("v.changedFields");
        changedList.push(id_str);
        component.set("v.changedFields",changedList);
    },
    sendEmail : function(component, event, helper) {
        helper.sendEmailHelper(component, event, helper);
    },
    handelSave : function(component, event, helper) {
        console.log('save----');
        var fieldList = component.get("v.changedFields");
        var fieldSet = new Set();
        for( var field in fieldList){
            fieldSet.add(fieldList[field]);
        }
        console.log('fieldSet...',fieldSet);
        helper.saveHelper(component, event, helper, fieldSet);
    },
    handelView : function(component, event, helper) {
        console.log('View Task....');
        component.set("v.viewTask",true);
    },
    handleCloseView : function(component, event, helper) {
        console.log('View Task...close...');
        component.set("v.viewTask",false);
    },
    handelCancel : function(component, event, helper) {
        window.close();
       /* component.set("v.spinner",true);
        //navigate to the layout tab on cancel
        var pageReference = {
            //type: 'standard__component',
            type: 'standard__navItemPage',
            attributes: {
                //componentName: 'c__DGTL_MainCmpNew',
                apiName: 'Layout_New_Test',
            },
        };
        component.set("v.pageReference", pageReference);
        
        console.log('navigating to Layout');
        var navService = component.find("navService");
        var pageReference = component.get("v.pageReference");
        event.preventDefault();
        
        //--- getting URL from the pagerefrence to navigate to it in new Tab.
        navService.generateUrl(pageReference).then($A.getCallback(function(url) {
            console.log('url --- in get callback--',url);
            component.set("v.url", url ? url : "#");
            //---- open url in new tab
            window.open(
                'https:'+url,
                '_self' 
            );
        }), $A.getCallback(function(error) {
            console.log('url --- in get error--',url);
            component.set("v.url", "#");
        })); */
    },
})