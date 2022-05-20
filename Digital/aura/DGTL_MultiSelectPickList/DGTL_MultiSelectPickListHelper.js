({
    showSelectedColor: function(component) {
        var selectedColor=[];
        //component.set('v.SelectedList',[]);
        var ColorList=component.get("v.entityList");
        for(var i in ColorList){           
            if(ColorList[i].flag){
                selectedColor.push(ColorList[i].Name);
            }
        }
        if(selectedColor.length>0)
		component.set('v.SelectedList',selectedColor);
    },
})