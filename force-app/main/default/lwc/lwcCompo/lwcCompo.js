import { LightningElement , track} from 'lwc';
import getApplications from '@salesforce/apex/ApplicantProvider.getApplications';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LwcCompo extends LightningElement {
    @track fromDate;
    @track toDate;
    @track isModalOpen = false;
    @track applications = [];
    @track agentName = 'John Doe'; // Static agent name for now; can be dynamically fetched

    columns = [
        { label: 'Application ID', fieldName: 'Name', type: 'text' },
        { label: 'First Name', fieldName: 'First_Name__c', type: 'text' },
        { label: 'Last Name', fieldName: 'Last_Name__c', type: 'text' },
        { label: 'Email ID', fieldName: 'Email_Id__c', type: 'email' },
        { label: 'Date of Birth', fieldName: 'Date_of_Birth__c', type: 'date' },
        { label: 'Created Date', fieldName: 'CreatedDate', type: 'date' }
    ];

    handleAgentNameChange(event) {
        this.agentName = event.target.value;
    }
    handleFromDateChange(event) {
        this.fromDate = event.target.value;
    }

    handleToDateChange(event) {
        this.toDate = event.target.value;
    }

    handleSearch() {
        if (!this.fromDate || !this.toDate) {
            this.showToast('Error', 'Please select both From Date and To Date', 'error');
            return;
        }

        getApplications({ fromDate: this.fromDate, toDate: this.toDate })
            .then(result => {
                this.applications = result;
                this.isModalOpen = true;
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            });
    }

    handleCloseModal() {
        this.isModalOpen = false;
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant,
        });
        this.dispatchEvent(event);
    }
}