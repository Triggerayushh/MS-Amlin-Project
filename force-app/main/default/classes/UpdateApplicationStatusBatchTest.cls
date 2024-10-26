@isTest (seeAlldata = false)
public class UpdateApplicationStatusBatchTest {
	@isTest
    static void UpdateApplicationStatusBatch() {
        // Create test data
        Applicant_Detail__c applicant1 = new Applicant_Detail__c(Status__c = false);
        insert applicant1;
        
        Applicant_Detail__c applicant2 = new Applicant_Detail__c(Status__c = false);
        insert applicant2;

        // Create an Asset record to link it to applicant1
        Asset asset = new Asset(
            Name = 'Test Asset',
            Applicant_Detail__c = applicant1.Id  // Linking asset to applicant1
            /* Include any additional required fields */
        );
        insert asset;

        Test.startTest();
        UpdateApplicationStatusBatch batch = new UpdateApplicationStatusBatch();
        Database.executeBatch(batch);
        Test.stopTest();

        // Re-query records to see the changes
        applicant1 = [SELECT Id, Status__c FROM Applicant_Detail__c WHERE Id = :applicant1.Id];
        applicant2 = [SELECT Id, Status__c FROM Applicant_Detail__c WHERE Id = :applicant2.Id];

        // Assert that applicant1's status remains active
        System.assertEquals(false, applicant1.Status__c, 'Applicant 1 should not be inactive because it has an asset.');
        // Assert that applicant2's status is now inactive
        System.assertEquals(true, applicant2.Status__c, 'Applicant 2 should be inactive because it has no assets.');
    }
}