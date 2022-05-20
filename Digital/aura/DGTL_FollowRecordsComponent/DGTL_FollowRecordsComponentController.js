({
	doInit : function(component, event, helper) {
		helper.checkFeedEnabled(component, event, helper);
	},
    
    handleClick : function (component, event, helper) {
        helper.followUnfollow(component, event, helper); 
    }
})