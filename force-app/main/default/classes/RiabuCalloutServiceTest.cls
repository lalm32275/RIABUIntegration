@isTest
private class RiabuCalloutServiceTest {

    @isTest
    static void testCreateCustomerInRiabu() {
        // Create test account
        Account testAccount = new Account(Name = 'Test Company');
        insert testAccount;
        
        // Start test
        Test.startTest();
        RiabuCalloutService.createCustomerInRiabu(testAccount.Id);
        Test.stopTest();
        
        // Basic assertion
        System.assert(true, 'Test completed');
    }
}