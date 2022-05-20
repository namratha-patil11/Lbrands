({
    doInit: function(component,event,helper) {
        console.log('---entityList----',component.get('v.entityList'));
        console.log('----disable---',component.get('v.disable'));
    },
    
    OpenColorToggle : function(component,event,helper){
        var action=component.find("droplist_color");
        $A.util.removeClass(action,"slds-dropdown slds-dropdown--left slds-hide");
        $A.util.addClass(action,"slds-dropdown slds-dropdown--left slds-show");
    },
    
    HideColorToggle : function(component,event,helper){        
        var action=component.find("droplist_color");
        $A.util.removeClass(action,"slds-dropdown slds-dropdown--left slds-show");
        $A.util.addClass(action,"slds-dropdown slds-dropdown--left slds-hide");
        var ySelected=component.get("v.Selected");  
        if(ySelected=="1"){
            var arrColorID=new Array();           
            var isColorSelect=false;   
            console.log('-entityList---',component.get("v.entityList"));
            var ColorResult = component.get("v.entityList");
           //  var ColorResult=JSON.parse(JSON.stringify(component.get("v.entityList")));
            if(ColorResult !=null){
                for(var res in ColorResult){
                    if(ColorResult[res].flag==true){
                        arrColorID.push(ColorResult[res].Name);                       
                    }
                }                
            }            
        }
    },
    clear : function(component,event,helper){
        if(!component.get('v.disable'))  {
            component.set("v.SelectedAllColor",false);
        component.set("v.SelectedColor",null);
        var Colors=[];
        var ColorList=component.get("v.entityList");
        for(var i in ColorList){
            var obj={
                Id:ColorList[i].Id,
                Name:ColorList[i].Name,
                flag:false
            }  
            Colors.push(obj);
        }
        component.set("v.Selected","1");        
        component.set("v.entityList",Colors);
        helper.showSelectedColor(component);
        }
    },
    
    AllColorUnCheck : function(component,event,helper){
        component.set("v.SelectedAllColor",false);
        component.set("v.SelectedColor",null);
        var Colors=[];
        var ColorList=component.get("v.entityList");
        for(var i in ColorList){
            var obj={
                Id:ColorList[i].Id,
                Name:ColorList[i].Name,
                flag:false
            }  
            Colors.push(obj);
        }
        component.set("v.Selected","1");        
        component.set("v.entityList",Colors);
        helper.showSelectedColor(component);

    },
    
    AllColorCheck : function(component,event,helper){
        component.set("v.SelectedAllColor",true);
        component.set("v.SelectedColor",null);
        var Colors=[];
        var ColorList=component.get("v.entityList");
        for(var i in ColorList){
            var obj={
                Id:ColorList[i].Id,
                Name:ColorList[i].Name,
                flag:true
            }  
            Colors.push(obj);
        }
        component.set("v.Selected","1");
        component.set("v.SelectedColor",Colors.length);
        component.set("v.entityList",Colors);  
        helper.showSelectedColor(component);
    },
    
    ColorCheck : function(component, event, helper){
        var ColorId=event.target.getAttribute('id'); 
        var ColorList=component.get("v.entityList");
        component.set("v.SelectedAllColor",false);
        var count=1;
        var Colors=[];
        for(var i in ColorList){
            if(ColorList[i].Id==ColorId){
                var obj={
                    Id:ColorList[i].Id,
                    Name:ColorList[i].Name,
                    flag:true
                }  
                Colors.push(obj);                
            }
            else{
                var obj={
                    Id:ColorList[i].Id,
                    Name:ColorList[i].Name,
                    flag:ColorList[i].flag
                }  
                Colors.push(obj);
            }
        }
        for(var a in Colors){
            if(ColorList[a].flag==true){
                count +=1;
            }
        }
        component.set("v.Selected","1");
        component.set("v.SelectedColor",count);
        component.set("v.entityList",Colors); 
        helper.showSelectedColor(component);
    },
    
    ColorUnCheck : function(component, event, helper){
        var ColorId=event.target.getAttribute('id'); 
        var ColorList=component.get("v.entityList");
        component.set("v.SelectedAllColor",false);
        var count=component.get("v.SelectedColor");        
        var Colors=[];
        for(var i in ColorList){
            if(ColorList[i].Id==ColorId){
                var obj={
                    Id:ColorList[i].Id,
                    Name:ColorList[i].Name,
                    flag:false
                }  
                Colors.push(obj);
                count -=1;  
            }
            else{
                var obj={
                    Id:ColorList[i].Id,
                    Name:ColorList[i].Name,
                    flag:ColorList[i].flag
                }  
                Colors.push(obj);                
            }
        }        
        if(count==0){
            component.set("v.SelectedColor",null);
        }
        else{
            component.set("v.SelectedColor",count);
        }
        component.set("v.Selected","1");
        component.set("v.entityList",Colors);
        helper.showSelectedColor(component);
    },  
     
 })