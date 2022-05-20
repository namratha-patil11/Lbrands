({	
    init : function(component, event, helper) {
        helper.initHpr(component,event,helper);
        //component.set("v.deviceType",'Desktop');
        var isPdf = component.get("v.isPDFDownload");
        console.log('isPdf-----',isPdf);
        if(isPdf){
            console.log('---inside isPdf-----');
            helper.fetchContentJsHpr(component, event,'Search');   
        }
    },
    fetchContentJs : function(component, event, helper) {
        component.set('v.hasContent',false);  
        if(component.get("v.selectedBrand") == '' || component.get("v.selectedBrand") == undefined
           || component.get("v.selectedFloorset") == '' || component.get("v.selectedFloorset") == undefined
           || component.get("v.deviceType") == '' || component.get("v.deviceType") == undefined){
            
            helper.showToast(component,'dismissible','Error','Please Fill all the Mandatory Fields for Search!!','error');
        }else{ 
            helper.fetchContentJsHpr(component, event,'Search');   
        }    
    },
    fetchContentJsNext : function(component, event, helper) {
        component.set('v.hasContent',false);  
        helper.fetchContentJsHpr(component, event,'Next');
        //component.set("v.sectionState",'open');
    },
    fetchContentJsBack : function(component, event, helper) {
        helper.fetchContentJsHpr(component, event,'Back');
        component.set('v.hasContent',false);
        //component.set("v.sectionState",'open');
    },
    downloadPDF : function(component, event, helper) {
        var margins = {
            top: 70,
            bottom: 40,
            left: 30,
            width: 550
        };
        var pdf = new jsPDF('p', 'pt', 'a4');
        pdf.setFontSize(18);
        pdf.fromHTML(document.getElementById('pdfBlock'), 
                     margins.left, // x coord
                     margins.top,
                     {
                         // y coord
                         width: margins.width// max width of content on PDF
                     }, function(dispose) {
                         
                     },
                     margins);
        
        var iframe = document.createElement('iframe');
        iframe.setAttribute('style','position:absolute;right:0; top:0; bottom:0; height:100%; width:650px; padding:20px;');
        document.body.appendChild(iframe);
        
        iframe.src = pdf.output('datauristring');
    },
    headerFooterFormatting : function(doc){
        var totalPages  = doc.internal.getNumberOfPages();
        for(var i = totalPages; i >= 1; i--)
        { //make this page, the current page we are currently working on.
            doc.setPage(i);      
            header(doc);
            footer(doc, i, totalPages);
        }
    },    
    onChangeBrand : function(component,event){
        var params = event.getParams();
        component.set("v.selectedBrand",params.value);
        component.set('v.hasContent',false);
        var cmp = component.find("pageTypeInput");
        //component.set("v.sectionState",'open');
    },
    onChangePageType : function(component,event){
        var params = event.getParams();
        component.set("v.selectedPageType",params.value);
        component.set('v.hasContent',false);
        component.set("v.sectionState",'');
        console.log('selectedPageType---',component.get("v.selectedPageType"));
    
        if(component.get("v.selectedPageType") == ''){
             console.log('selectedPageType---inside--',component.get("v.selectedPageType"));
           /* var pageTypeEle = component.find("pageTypeInput");
            $A.util.removeClass(pageTypeEle, "slds-has-error");
            $A.util.removeClass(pageTypeEle, "slds-required"); */
            
            var elements = document.getElementsByClassName("slds-form-element slds-has-error");
            console.log('elements--',elements);
            for (var i=0; i<elements.length; i++) {
                console.log(elements[i].innerHTML);
                $A.util.removeClass(elements[i], "slds-has-error");
            }
           /*  var pageType = component.find("pageType");
            $A.util.removeClass(pageType, "slds-has-error");
            $A.util.removeClass(pageType, "slds-required"); */
        }
    },
    onChangeFloorset : function(component,event, helper){
        var params = event.getParams(); 
        var floorset = String(params.value);
        component.set("v.selectedFloorset",floorset);
        component.set('v.hasContent',false); 
        if(floorset != '' && floorset != null && floorset != undefined) helper.validateFloorsetBrand(component, event);
        //component.set("v.sectionState",'open');
    },
    onChangeSnapshot : function(component,event){
        component.set('v.hasContent',false); 
    },
    onDeviceType : function(component,event){
        var params = event.getParams(); 
        var deviceType = String(params.value);
        component.set("v.deviceType",deviceType);
        component.set('v.hasContent',false); 
        //component.set("v.sectionState",'open');
        
        //--- add styles to show Field is required
        var deviceEle = component.find('deviceTypeID');
        if(component.get("v.deviceType") != ''){
            $A.util.removeClass(deviceEle, 'slds-has-error');
        }else{
            $A.util.addClass(deviceEle, 'slds-has-error');
        }
    },
    toggleTheSection : function(component, event, helper) {
        var rectarget = event.currentTarget;
        $A.util.toggleClass(rectarget, 'slds-is-open');
    },
    openPDF : function(component){
        var pType = component.get("v.selectedPageType");
        var fType = component.get("v.selectedFloorset"); 
        var brand = component.get("v.selectedBrand");
        var dType = component.get("v.deviceType"); //DGTL_ViewPDFGenerator
      var url = '/apex/DGTL_ViewPlcLayoutPDF?fType=' + fType + '&pType=' + pType +'&brand=' +brand + '&dType=' +dType;
     //  var url = '/apex/DGTL_ViewPlcLayoutPDF';
        window.open(url, '_blank');
    }, 
    printPDF : function(component, event, helper){
       // console.log('--'+document.getElementsByTagName('title'));
     /*  var css = "@media print { @page { margin: 0; }.slds-no-print {display: none;}}";
    var head = document.head || document.getElementsByTagName('head')[0];
    var style = document.createElement('style');

head.appendChild(style);

style.type = 'text/css';
if (style.styleSheet){
  // This is required for IE8 and below.
  style.styleSheet.cssText = css;
} else {
  style.appendChild(document.createTextNode(css));
} */
        //document.title = " ";
        //document.getElementsByTagName('title')[0].remove();
        //document.header.style.display = 'none';
    	//component.set("v.collapsableSection",'open');
        window.print();
        //var printContents = document.getElementById('pdfBlock').innerHTML;
      // window.print(window.document.getElementById("header"));
       // console.log('--printContents--'+printContents)
       // var originalContents = document.body.innerHTML;
       // document.getElementById('header').style.display = 'none';
       // document.getElementById('footer').style.display = 'none';
       // document.body.innerHTML = printContents;
		//printContents.print();
    }
})