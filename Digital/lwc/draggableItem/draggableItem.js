/* eslint-disable vars-on-top */
/* eslint-disable guard-for-in */
import { LightningElement, api, track } from 'lwc';
export default class DraggableItem extends LightningElement 
{
	@api item = {};
    @api index = -1;
    @api dynamicinputarray = {};
    @track title;

    connectedCallback() {
        // set the title to show on the card
        if(this.dynamicinputarray.name && this.dynamicinputarray.name !== '') {
            this.title = this.dynamicinputarray.name;
        }else if(this.dynamicinputarray.nameFields && this.dynamicinputarray.nameFields.length > 0){
            this.title = '';
            for(var key in this.dynamicinputarray.nameFields){
                this.title += this.getDynamicField(this.item,this.dynamicinputarray.nameFields[key]) + ' - ';
            }
            this.title = this.title.substring(0, this.title.length - 2);
        }
    }

    getDynamicField(item,field){
        let dynamicValue = '';
        if(field.includes('.')){
            let fieldArray = field.split('.');
            let value = '';
            for(var index in fieldArray ){
                if(index == fieldArray.length - 1){
                    dynamicValue = value[fieldArray[index]];
                }else{
                    value = index == 0 ? item[fieldArray[index]] : value[fieldArray[index]];
                }
            }
        }else{
            dynamicValue = item[field];
        }
        return dynamicValue == undefined ? '' : dynamicValue;
    }
}