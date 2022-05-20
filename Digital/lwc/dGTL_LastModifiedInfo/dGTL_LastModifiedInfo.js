import { LightningElement, api, wire, track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { getRecord,getFieldValue  } from 'lightning/uiRecordApi';
const FIELDS = ['Placement_Layout__c.LastModifiedById', 'Placement_Layout__c.LastModifiedDate'];


import getLastModified from '@salesforce/apex/DGTL_Layout.getLastModified'; 

export default class Poc extends LightningElement {
    @api payLayoutId;
    @track layout;
    @track LastModifiedName;
    @track LastModifiedDate;
    @track wiredResult;
/*
    @wire(getRecord, { recordId: '$payLayoutId', fields: ['Placement_Layout__c.LastModifiedBy.Name', 'Placement_Layout__c.LastModifiedDate' ] })
    getlayoutRecord({ data, error }) {
        console.log('layoutRecord => ', data, error);
        if (data) {
            this.layout = data;
            this.LastModifiedName = this.layout.fields.LastModifiedBy.displayValue;
            this.LastModifiedDate = this.layout.fields.LastModifiedDate.displayValue;
            this.processRelatedObjects();
        } else if (error) {
            console.error('ERROR => ', JSON.stringify(error)); // handle error properly
        }
    }

    processRelatedObjects() {
        console.log('processRelatedObjects for => ', JSON.stringify(this.layout));
        // further processing like refreshApex or calling another wire service
    }

    @api
    refresh() {
        return refreshApex(this.layout); 
    }*/
  




@wire(getLastModified,{placementLayoutId:'$payLayoutId'})
wiredModifiedResult(result) {
this.wiredResult = result;
if (result.data) {
    this.layout = result.data;
    console.log('-------layout------',this.layout);
    this.LastModifiedName = this.layout.LastModifiedBy;
    this.LastModifiedDate = this.layout.LastModifiedDate;
    this.refresh(); 
} else if (result.error) {
    
    }    
} 

@api
refresh() {
    return refreshApex(this.wiredResult); 
}
}