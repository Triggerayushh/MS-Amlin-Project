public class UpdateApplicationStatusBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    // Lists to hold the IDs
    private List<Id> successfulRecordIds = new List<Id>();
    private List<Id> failedRecordIds = new List<Id>();
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        // Query to get applicants who were created in the last month and have no assets
        return Database.getQueryLocator([
            SELECT Id, Status__c  
            FROM Applicant_Detail__c 
            WHERE CreatedDate = LAST_MONTH 
            AND Id NOT IN (SELECT Applicant_Detail__c FROM Asset) 
            AND Status__c  = false // Only consider active applicants
        ]);
    }
    
    public void execute(Database.BatchableContext BC, List<Applicant_Detail__c> applicantList) {
        // Update the inactive status for these applicants
        for (Applicant_Detail__c applicant : applicantList) {
            try {
                applicant.Status__c  = true; // Set checkbox to inactive
                successfulRecordIds.add(applicant.Id); // Track successful IDs
            } catch (Exception e) {
                // Track failed IDs and log the error
                failedRecordIds.add(applicant.Id);
                System.debug('Error updating record ID: ' + applicant.Id + ' - ' + e.getMessage());
            }
        }
        
        // Perform DML Update
        if (!applicantList.isEmpty()) {
            try {
                update applicantList;
            } catch (Exception e) {
                // Log the error and add all IDs to failed list if the update fails
                for (Applicant_Detail__c applicant : applicantList) {
                    failedRecordIds.add(applicant.Id);
                }
            }
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        // Construct email content
        String emailBody = 'Batch processing completed.\n\n' +
            'Successfully processed record IDs:\n' + String.join(successfulRecordIds, ', ') + '\n\n' +
            'Failed record IDs:\n' + String.join(failedRecordIds, ', ');
        
        // Send email to System Admin
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[] {'ayushhh060@gmail.com'}); // Replace with actual admin email
        email.setSubject('Batch Processing Results');
        email.setPlainTextBody(emailBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        
        System.debug('Email sent to System Admin with results.');
    }
}