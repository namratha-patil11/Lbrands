({
	afterRender: function(component, helper) {
        this.superAfterRender();
        var layoutList = component.get("v.placementLayout");
        if(layoutList != null && layoutList != undefined){
            if(layoutList == 1){
                component.set("v.sectionState",'open');
            }else{
                component.set("v.sectionState",'close');
            }
            console.log('sectionState--in after render--',component.get("v.sectionState"));
        }
        
    }
})