({
    afterRender: function(component, helper) {
        this.superAfterRender();
        console.log("isPageRefrence---after render---");
        //$A.get("e.force:refreshView").fire();
    }
})