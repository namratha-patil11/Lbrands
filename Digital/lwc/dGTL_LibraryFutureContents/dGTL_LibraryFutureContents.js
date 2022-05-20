import { LightningElement, api, track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getFutureContents from '@salesforce/apex/DGTL_WebRemoter.getFutureContents';

const columns = [
    {label:'Name', fieldName:'Name',type: 'text'},
    {label:'Main Message', fieldName:'Main_Message__c',type: 'text'}
    /*{label:'Layout', fieldName:'layout',type: 'String'}*/
];

export default class DGTL_LibraryFutureContents extends LightningElement {
    @api contentId ;
    futureContents ;
    @track showModal = false;
    showSpinner = false;
    columns = columns ;

    connectedCallback() {
        this.showSpinner = true;
        getFutureContents({contentId:this.contentId})
        .then(result => {
            if(result !== undefined && result.length > 0){
            this.futureContents = result;
            this.showModal = true;
            }else{
                this.showToast('Error','No records found!','error');
                this.closeModal();
            }
        })
        .catch(error => {
            let errorMsg = error.body ? error.body.message : error;
            this.showToast('Error',errorMsg,'error');
            this.closeModal();
        });
        this.showSpinner = false;
    }

    closeModal(){
        const closeModalEvt = new CustomEvent('closeModal');
        this.dispatchEvent(closeModalEvt);
    }

    showToast(tittle,msg,type){
        const toastEvent = new ShowToastEvent({
            title: tittle,
            message: msg,
            variant: type,
        });
        this.dispatchEvent(toastEvent);
    }
    
}