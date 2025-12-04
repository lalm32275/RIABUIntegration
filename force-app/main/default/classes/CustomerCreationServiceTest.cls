@isTest
public class CustomerCreationServiceTest {
    @testSetup
    public static void  testRiabuTokenData(){
        INSERT new Riabu__c( Client_Id__c='123123',client_secret__c='test',Password__c='testpass',Name='testRiabu',Expire_Date__c=(datetime.now()+10),refreshToken__c='testrefreshtokentest',AccessToken__c='testaccesstokentest' );
    	INSERT new Account( Name='testRiabuAccount',Registration_Number__c='123123',Days_to_Pay__c='14',Procurement_Portal__c='Coupa',RiabuAccountId__c='123123');
    }
    
    @isTest
    public static void createAccountRecordsinRiabu(){
        Riabu__c riabuObj  = [SELECT Id, Name, Client_Id__c, client_secret__c, Password__c, refreshToken__c, AccessToken__c, Expire_Date__c 
                              FROM Riabu__c LIMIT 1];
        Account acc = [SELECT Id,Name FROM Account LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new CustomerCreationServiceTestMock());
        Test.startTest();
        CustomerCreationService.createCustomer( acc.Id );
        Test.stopTest();     
    }
    
    @isTest
    public static void accountFetchQueueTest(){
        Riabu__c riabuObj  = [SELECT Id, Name, Client_Id__c, client_secret__c, Password__c, refreshToken__c, AccessToken__c, Expire_Date__c 
                              FROM Riabu__c LIMIT 1];
        Account acc = [SELECT Id,Name FROM Account LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new RiabuAccountFetchQueueTestMock());
        Test.startTest();
            System.enqueueJob(new RiabuAccountFetchQueue(acc.Id));
        Test.stopTest();
        
    }
    
    @isTest
    public static void updateAccountRecord(){
		Riabu__c riabuObj  = [SELECT Id, Name, Client_Id__c, client_secret__c, Password__c, refreshToken__c, AccessToken__c, Expire_Date__c 
                              FROM Riabu__c LIMIT 1];
        Account acc = [SELECT Id,Name FROM Account LIMIT 1];
        Contact con = new Contact( LastName = 'testLast', AccountId = acc.Id, Email= 'testEmail@gmail.com', Phone='1234567890', E_Invoice_Email__c='testEInvoiceEmail@gmail.com', high_risk_customer__c=true, has_customer_signed__c=false,reason_has_not_signed__c ='testReasonHasNotSigned',isPrimary__c =true  );
        Insert con;
        Test.setMock( HttpCalloutMock.class, new CustomerCreationServiceTestMock() );
        Test.startTest();
        CustomerCreationService.updateCustomer( con.Id );
        Test.stopTest();
		
    }
    @isTest
    public static void createOrderRiabu(){
        Riabu__c riabuObj  = [SELECT Id, Name, Client_Id__c, client_secret__c, Password__c, refreshToken__c, AccessToken__c, Expire_Date__c 
                              FROM Riabu__c LIMIT 1];
        Account acc = [SELECT Id,Name FROM Account LIMIT 1];
        Opportunity opp = new Opportunity( Name ='test',CloseDate =Date.today(),AccountId = acc.Id,StageName='Closed Won',NextStep ='testNextStep', Amount=1000);
        Insert opp;
        Test.setMock(HttpCalloutMock.class, new CustomerCreationServiceTestMock());
        Test.startTest();
        CustomerCreationService.createOrder( acc.Id, opp.Id );
        Test.stopTest();
        Opportunity updatedOpp = [SELECT riabu_Order_Id__c FROM Opportunity WHERE Id = :opp.Id];
    }
    @isTest
    public static void getRiabuData(){
        Account acc = [SELECT Id,Name FROM Account LIMIT 1];
	    Riabu__c riabuObj  = [SELECT Id, Name, Client_Id__c, client_secret__c, Password__c, refreshToken__c, AccessToken__c, Expire_Date__c 
                              FROM Riabu__c LIMIT 1];
        Contact con = new Contact( LastName = 'testLast', AccountId = acc.Id, Email= 'testEmail@gmail.com', Phone='1234567890', E_Invoice_Email__c='testEInvoiceEmail@gmail.com', high_risk_customer__c=true, has_customer_signed__c=false,reason_has_not_signed__c ='testReasonHasNotSigned',isPrimary__c =true  );
        Insert con;
        Opportunity opp = new Opportunity( Name ='test',CloseDate =Date.today(),AccountId = acc.Id,StageName='Closed Won',NextStep ='testNextStep', Amount=1000,riabu_Order_Id__c = '123123');
        Insert opp;
        Test.setMock(HttpCalloutMock.class, new RiabuAccountDataFetcherTestMock());
        Test.startTest();
   		Id jobid= Database.executeBatch( new RiabuAccountDataFetcherClass(),1);
        Test.stopTest();
    }
    @isTest
    public static void getRiabuOrderChatterData(){
        Account acc = [SELECT Id,Name FROM Account LIMIT 1];
	    Riabu__c riabuObj  = [SELECT Id, Name, Client_Id__c, client_secret__c, Password__c, refreshToken__c, AccessToken__c, Expire_Date__c 
                              FROM Riabu__c LIMIT 1];
        Contact con = new Contact( LastName = 'testLast', AccountId = acc.Id, Email= 'testEmail@gmail.com', Phone='1234567890', E_Invoice_Email__c='testEInvoiceEmail@gmail.com', high_risk_customer__c=true, has_customer_signed__c=false,reason_has_not_signed__c ='testReasonHasNotSigned',isPrimary__c =true  );
        Insert con;
        Opportunity opp = new Opportunity( Name ='test',CloseDate =Date.today(),AccountId = acc.Id,StageName='Closed Won',NextStep ='testNextStep', Amount=1000,riabu_Order_Id__c = '123123');
        Insert opp;
        Test.setMock(HttpCalloutMock.class, new RiabuAccountDataFetcherTestMock());
        Test.startTest();
   		Id jobid= Database.executeBatch( new RiabuGetOrderAndChatterBatch(),1);
        Test.stopTest();
    }    
}