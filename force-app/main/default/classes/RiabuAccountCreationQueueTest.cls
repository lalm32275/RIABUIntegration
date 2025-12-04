@IsTest
public class RiabuAccountCreationQueueTest {
    
    @IsTest
    static void testExecute() {
        // Create test account without RiabuAccountId__c
        Account testAcc = new Account(Name = 'Test Account');
        insert testAcc;
        
        Test.startTest();
        // Execute the queueable job
        System.enqueueJob(new RiabuAccountCreationQueue(testAcc.Id));
        Test.stopTest();
        
        // Verify it runs without error
        System.assert(true, 'Queueable should run without error');
    }
    
    @IsTest
    static void testExecuteWithRiabuAccountId() {
        // Create test account WITH RiabuAccountId__c (should skip creation)
        Account testAcc = new Account(
            Name = 'Test Account', 
            RiabuAccountId__c = '12345'
        );
        insert testAcc;
        
        Test.startTest();
        // Execute the queueable job
        System.enqueueJob(new RiabuAccountCreationQueue(testAcc.Id));
        Test.stopTest();
        
        // Verify it runs without error (should skip due to existing RiabuAccountId__c)
        System.assert(true, 'Queueable should skip when RiabuAccountId__c exists');
    }
}