import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import { refreshApex } from '@salesforce/apex';
/* eslint-disable no-console */
/* eslint-disable no-alert */
/*eslint guard-for-in: "error"*/
import saveSelectedContFromExistingLayout from '@salesforce/apex/DGTL_Layout.saveSelectedContFromExistingLayout'; 

export default class DGTL_ContentType extends LightningElement {
    enableABTestPrompt;
    enableTakedownPrompt;
    enableContigencyPrompt;
    @api ContentTypesList;
    buttonLabel;
    buttonTitle;
    abTestName;
    NewContentType;
    @api contentData;
    @api pLayoutId;
    buttonLabel = "Save";
    buttonTitle = "Save";
    refreshLayout = false;
   invokeCreateContent(){
    saveSelectedContFromExistingLayout({list_PlcContentToClone: this.contentData,pLayoutId:this.pLayoutId,contentType:this.NewContentType,testName:this.abTestName,fromExistingLayout:false})
    .then(result => {
        if(result !== undefined && result.length > 0){
            if(result[0].errorStatus !== undefined && result[0].errorStatus !== null && result[0].errorStatus.includes('DUPLICATE_VALUE')){
                if(this.enableABTestPrompt){
                    this.displayToastMessage('error','Duplicate AB Test '+this.abTestName,'error');
                }else if(this.enableTakedownPrompt){
                    this.displayToastMessage('error','Duplicate TakeDown','error');
                }else if(this.enableContigencyPrompt){
                    this.displayToastMessage('error','Duplicate Contingency','error');  
                }
            }else{
                this.displayToastMessage('success','Successfully Created','success');
                this.refreshLayout = true;
                this.closeModalBox();
            }
        }else{
            this.displayToastMessage('error','Failed','error');  
        }
    })
    .catch(error => {
        let errorMsg = error.body ? error.body.message : error;
        this.displayToastMessage('error','--catch--'+errorMsg,'error'); 
    });
   }
    getTestName(event) {
        this.abTestName = event.target.value;
    }
    get contTypes() {
        var cnttypes = [];
        // eslint-disable-next-line guard-for-in
        for (let key in this.ContentTypesList) {
            cnttypes.push({ label: this.ContentTypesList[key], value: this.ContentTypesList[key] });
        }
        return cnttypes;
    }

    handleOnChange(event) {
        this.NewContentType = event.target.value;
        if (this.NewContentType === "AB Test") {
            this.buttonLabel = "Save Test & Close";
            this.buttonTitle = "Save Test & Close";
            this.enableABTestPrompt = true;
            this.enableTakedownPrompt = false;
            this.enableContigencyPrompt = false;
        } else if (this.NewContentType === "Takedown") {
            this.buttonLabel = "Create Takedown & Close";
            this.buttonTitle = "Create Takedown & Close";
            this.enableABTestPrompt = false;
            this.enableTakedownPrompt = true;
            this.enableContigencyPrompt = false;
        } else if (this.NewContentType === "Contingency") {
            this.buttonLabel = "Create Contingency & Close";
            this.buttonTitle = "Create Contingency & Close";
            this.enableABTestPrompt = false;
            this.enableTakedownPrompt = false;
            this.enableContigencyPrompt = true;
        }
    }
  /*  get enableABTestPrompt() {
        return this.NewContentType === "AB Test";
    }
    get enableTakedownPrompt() {
        return this.NewContentType === "Takedown";
    }
    get enableContigencyPrompt() {
        return this.NewContentType === "Contingency";
    } */
    
    // createContentType button method
    createContentType() {
        if (this.NewContentType !== undefined && this.NewContentType !== '') {
            if(this.enableABTestPrompt && (this.abTestName === undefined || this.abTestName === '')){  
                this.displayToastMessage('error','Test Name is Mandatory','error');               
            }else{           
                     this.invokeCreateContent();     
            }
        }else{
            this.displayToastMessage('error','Please select AB Test/Takedown/Contingency','error');           
        }

    }
    // close/cancel button method
    closeModalBox() {
        const refreshLay = this.refreshLayout;
        const closeLWC = new CustomEvent('closeCont', {
            detail: { refreshLay },
        });
        //Fire Event
        this.dispatchEvent(closeLWC);
    }

    displayToastMessage(title,message,variant){
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
    

}
