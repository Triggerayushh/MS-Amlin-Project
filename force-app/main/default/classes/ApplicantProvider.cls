public with sharing class ApplicantProvider {
    @AuraEnabled(cacheable=true)
    public static List<Applicant_Detail__c> getApplications(Date fromDate, Date toDate) {
        try {
            return [SELECT Id,Name, First_Name__c, Last_Name__c, Email_Id__c, Date_of_Birth__c, CreatedDate 
                    FROM Applicant_Detail__c 
                    WHERE CreatedDate >= :fromDate AND CreatedDate <= :toDate];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}