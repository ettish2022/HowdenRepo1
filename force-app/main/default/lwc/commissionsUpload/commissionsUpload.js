import { LightningElement, track, wire } from 'lwc';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { getObjectInfo } from "lightning/uiObjectInfoApi";
import COMMISSION_STAGING_OBJECT from "@salesforce/schema/Commission_Staging__c";

import Choose_format from '@salesforce/label/c.Choose_format';
import Commission_Upload_Title from '@salesforce/label/c.Commission_Upload_Title';
import Error from '@salesforce/label/c.Error';
import Error_No_fields_mapping_under_format from '@salesforce/label/c.Error_No_fields_mapping_under_format';
import Error_Missing_mandatory_fields from '@salesforce/label/c.Error_Missing_mandatory_fields';
import File_format from '@salesforce/label/c.File_format';
import No_file_uploaded from '@salesforce/label/c.No_file_uploaded';
import Success_message from '@salesforce/label/c.Success_message';
import Upload_button from '@salesforce/label/c.Upload_button';
import Uploaded_file from '@salesforce/label/c.Uploaded_file';

import getFormatsMD from '@salesforce/apex/LWC_CommissionsUpload.getFormatsMD';
import saveRecords from '@salesforce/apex/LWC_CommissionsUpload.saveRecords';

export default class CommissionsUpload extends LightningElement {
    labels = {Choose_format, Commission_Upload_Title, File_format, Uploaded_file, Upload_button};

    isLoading = false;

    formatOptions;
    selectedFormat;
    
    file;
    @track fileName;

    commissionStagingRecordTypes = {};

    @wire(getObjectInfo, { objectApiName: COMMISSION_STAGING_OBJECT })
    getRecordTypes({error, data}){
        if(data){
            Object.values(data.recordTypeInfos).forEach(rt => {
                this.commissionStagingRecordTypes[rt.name] = rt.recordTypeId;
            });
        }
    }

    @wire(getFormatsMD)
    handleFormatsMd(data){
        if(data.data){
            this.formatOptions = [];

            data.data.forEach(format => {
                let formatOption = {};
                formatOption.label = format.MasterLabel;
                formatOption.value = format.DeveloperName;
                formatOption.format = format;
                this.formatOptions.push(formatOption);
            });
        }
    }

    handleFormatChange(event){
        this.selectedFormat = this.formatOptions.filter(format => format.value === event.detail.value)[0].format;
    }

    handleFileUploaded(event){
        const files = event.target.files;
        if (files && files.length > 0) {
            this.file = files[0];
            this.fileName = this.file.name;
        }
    }

    handleSave(){
        if(this.file){
            this.isLoading = true;
            this.parseFile();
        } else {
            this.showNotification('error', Error, No_file_uploaded);
        }
    }   

    parseFile(){
        const reader = new FileReader();
        const that = this;
        reader.onload = function() {
            const fileLines = reader.result.split(/\r\n|\n/);
            if(fileLines.length <= 1){
                that.showNotification('error', Error, Error_Empty_file);
                return;
            } 
            const headersMapping = that.getHeaders(that.splitRecord(fileLines[0]));

            if(headersMapping) {
                fileLines.shift();
                that.handleData(headersMapping,fileLines);
            } 
        }
        reader.readAsText(this.file, 'UTF-8');
    }
    
    getHeaders(fileHeaders){
        let ret = {};
        const headersMapping = this.selectedFormat.Commission_Upload_Field_Mappings__r;
        if(headersMapping){                        
            for (let i = 0; i < headersMapping.length; i++) {
                let flag = false;
                const headerMapping = headersMapping[i];
                for (let j = 0; j < fileHeaders.length; j++) {
                    if (headerMapping.MasterLabel === fileHeaders[j].replaceAll(/"|,|'/g, "").replaceAll('/','')) {
                        ret[j] = headerMapping;            
                        flag = true;  
                    }
                }
                if(!flag && headerMapping.Default_Value__c ){
                    ret[fileHeaders.length + i] = headerMapping;            
                    flag = true;
                }
                if(!flag && !headerMapping.Is_Input_Value__c){
                    const label = Error_Missing_mandatory_fields + ' : ' + headerMapping.MasterLabel;
                    this.showNotification('error', Error, label);
                    return;
                }
            }
        } else {            
            this.showNotification('error', Error, Error_No_fields_mapping_under_format);
            return;
        }
        return ret;

    }

    handleData(headers, fileLines){
        const data = this.buildData(headers, fileLines);
        if(data) this.save(data);        
    }

    buildData(headersMapping, fileData){
        let data = [];
        const recordTypeId = getRTId(this.selectedFormat, this.commissionStagingRecordTypes);
        fileData.forEach(record => { 
            const recordValues = this.splitRecord(record);   

            if(record != '' && recordValues.length !== 0 && record.replaceAll(',','').length !== 0){ 
                let commissionStagingRecord = setRecord(headersMapping, recordValues, recordTypeId);
                setInputValues(this, commissionStagingRecord);
                if(isAmount(commissionStagingRecord.Commission_Amount__c, commissionStagingRecord.Load_Commission_Amount_1__c))
                    data.push(commissionStagingRecord);
            }
        });

        return data;

        function getRTId(format, recordTypesData) {
            const recordTypeName = format.Record_Type__c;
            return recordTypesData[recordTypeName];
        }

        function setRecord(headers, values, rt){
            let ret = {'RecordTypeId': rt};
            Object.keys(headers).forEach(index => {
                const header = headers[index]; 
                const value = header.Default_Value__c ?  
                              header.Default_Value__c : 
                              header.Field_API_Name__c === 'Currency_Name__c' ? values[index].trim().replaceAll('"','') : values[index].trim();

                ret[header.Field_API_Name__c] = value;
            });
            return ret;
        }

        function setInputValues(that,record) {
            that.template.querySelectorAll('lightning-input').forEach(field => {
                record[field.dataset.fieldName] = field.value ;
            });
        }

        function isAmount(amount1, amount2){
            return (amount1 && Number(amount1) !== 0) || (amount2 && Number(amount2) !== 0);
        }
    }  
    
    splitRecord(record){
        let ret = [];
        if(record === '')
            return ret;

        if(!record.includes(','))
            return [record];

        let indexFrom = record.startsWith('"') ? 1 : 0;
        // let indexTo = record.startsWith('"') ? record.indexOf('",') : record.indexOf(',');
        let indexTo = !record.startsWith('"') ? record.indexOf(',') : record.indexOf('",') === -1 ? record.length -1 : record.indexOf('",');

        ret.push(record.substring(indexFrom, indexTo));

        let sliceFrom = record.startsWith('"') ? indexTo + 2 : indexTo + 1;
        return ret.concat(this.splitRecord(record.slice(sliceFrom)));
    }

    save(data){     
        saveRecords({records: data})
        .then(() => {
            const label = this.fileName + ' ' + Success_message;
            this.showNotification('success','', label);
        })
        .catch(error => {
            this.showNotification('error', Error, error.body.message);
        })
        .finally(() => {
            this.file = undefined;
            this.fileName = undefined;
        });
    }

    showNotification(variant, title, message){
        this.isLoading = false;
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);    }
}