@IsTest
public class AccountTriggerHandlerTest {
    
    @IsTest
    static void testCreateAccount() {
        // Create test account
        Account testAcc = new Account(Name = 'Test Account');
        
        Test.startTest();
        insert testAcc;
        Test.stopTest();
        
        // Verify account was created
        List<Account> accounts = [SELECT Id, Name FROM Account];
        System.assertEquals(1, accounts.size(), 'Account should be created');
    }
}