import { LightningElement, api, wire, track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
/* eslint-disable no-console */
 /* eslint-disable no-alert */
 /*eslint guard-for-in: "error"*/ 
import HistoryRecordsList from '@salesforce/apex/DGTL_History.HistoryRecordsList'; 
export default class dGTL_HistoryLWC extends LightningElement {
    @api selectedFields ;
    @api objRecordId ;
    @api contEditFields; 
    @api contDetailEditFields;   
    @api selectedHisIds;
    @api historyRecords;
    @api layoutLocked;
    @track resultslength;
    @api showTable;
    wiredHistoryResult;
   
   // @wire(HistoryRecordsList,{objectId:'$objRecordId',contEdtFields:'$contEditFields',contDtEdtFields:'$contDetailEditFields'}) historyRecords;
    @wire(HistoryRecordsList,{objectId:'$objRecordId',contEdtFields:'$contEditFields',contDtEdtFields:'$contDetailEditFields'})
     wiredHistory(result) {
        this.wiredHistoryResult = result;
        if (result.data) {
            this.historyRecords = result.data;
            this.error = undefined;
            this.refresh(); 
            //this.showTable= JSON.stringify(data);
           // this.showTable = true;                 
        } else if (result.error) {
            this.error = result.error;
            this.historyRecords = undefined;
            //this.showTable = false;
        }
       // this.resultslength= JSON.stringify(result.data);
        // this.showTable = this.result.length;
    } 
    
    @api
    refresh() {
        return refreshApex(this.wiredHistoryResult); 
    }
   
    handleFieldSelection(event) {
       
        if(event.target.checked && this.selectedFields !==undefined && this.selectedFields !=='' && this.selectedFields.includes(event.target.name.contHistRec.Field_Name__c) ){//
           event.target.checked = !event.target.checked;   
            const evt2 = new ShowToastEvent({
                title: 'Duplicate',
                message: 'This Field is already selected '+event.target.name.contHistRec.Field_Name__c,
                variant: 'error',
            });
            this.dispatchEvent(evt2);
        }else{
            const checked = Array.from(
                this.template.querySelectorAll('lightning-input')
            )
                // Filter down to checked items
                .filter(element => element.checked)
                // Map checked items to their labels
                .map(element => element.name.contHistRec.Field_Name__c);
            this.selectedFields = checked.join(', ');
        }
        
    }

    // Replace button method 
    replaceValues(){
        if(this.selectedFields ===undefined || this.selectedFields ===''){
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Please select at least one field',
                variant: 'error',
            });
            this.dispatchEvent(evt);
        }else{
            
           // const hisData = [];
            const checked = Array.from(
                this.template.querySelectorAll('lightning-input')
           )
                // Filter down to checked items
                .filter(element => element.checked)
                .map(element => element.name.contHistRec.Field_API__c+':'+element.name.contHistRec.Old_Value__c);
                this.selectedHisIds = checked.join('####');                
                const hisFields = this.selectedHisIds;
                const closeLWC = new CustomEvent('replaceHis',{
                    detail : {hisFields},
                });
                this.historyRecords = [];
                this.objRecordId = '';               
                this.dispatchEvent(closeLWC);
        }
        
    }

    // close/cancel button method
    closeModalBox(){        
        const v = false;
        const closeLWC = new CustomEvent('closeHis',{
            detail : {v},
        });
        this.historyRecords = [];
        this.objRecordId = '';
        //Fire Event
        this.dispatchEvent(closeLWC);
    }
    
}