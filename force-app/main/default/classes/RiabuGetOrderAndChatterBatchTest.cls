@isTest
public class RiabuGetOrderAndChatterBatchTest {

    // Mock for both Order API and Service Call API
    private class RiabuOrderServiceMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type','application/json');

            if(req.getEndpoint().contains('/order/get-list/')){
                res.setStatusCode(200);
                res.setBody('{"data": {"items": ['+
                    '{"id": 1001, "end_date": 1700000000, "master_file_id": 10, "created_at":"2024-01-01", "purchase_number":"P-123",'+
                    '"order_items": ['+
                        '{"id": 501, "order_id": 1001, "name": "Task A", "detail":"detail",'+
                        '"deadline":"2024-12-31",'+
                        '"deadline_object": {"day":"31","month":"12","year":"2024"}}'+
                    ']}' +
                ']}}');
            }
            else if(req.getEndpoint().contains('/service-call/')){
                res.setStatusCode(200);
                res.setBody('{"data": {"calls": {"items": ['+
                    '{"id": 201, "person": "John Doe", "assigned_discrepancy_manager": "Jane Smith",'+
                    '"assigned_discrepancy_supervisor": "Robert Brown",'+
                    '"assigned_gm_ceo": "Alice White",'+
                    '"invoice_number":"INV-98765",'+
                    '"invoice_amount":"15000.00"}'+
                ']}}}');
            } else {
                res.setStatusCode(200);
                res.setBody('{"data": {"items": []}}');
            }

            return res;
        }
    }

    @isTest
    static void testBatchExecution(){

        // Insert Riabu Settings
        Riabu__c r = new Riabu__c(
            Name='Config',
            Client_Id__c='123',
            client_secret__c='secret',
            Password__c='pass',
            refreshToken__c='ref',
            AccessToken__c='abc123',
            Expire_Date__c=Date.today().addDays(5)
        );
        insert r;

        // Create Test Account
        Account acc = new Account(
            Name='Test Acc',
            RiabuAccountId__c='999'
        );
        insert acc;

        // Existing contact
        Contact con = new Contact(
            LastName='Primary',
            AccountId=acc.Id,
            isPrimary__c=true
        );
        insert con;

        // Existing opportunity with riabu order id matching mock
        Opportunity opp = new Opportunity(
            Name='Old Opp',
            StageName='Prospecting',
            CloseDate=Date.today().addDays(10),
            AccountId=acc.Id,
            riabu_Order_Id__c='1001'
        );
        insert opp;

        // Existing Task
        Task t = new Task(
            WhoId = con.Id,
            WhatId = opp.Id,
            Subject='Old Task',
            ActivityDate=Date.today(),
            riabu_Task_Id__c='501'
        );
        insert t;

        // Existing FeedItem (Chatter)
        FeedItem fi = new FeedItem(
            Body='201,John Doe,Jane Smith,Robert Brown,Alice White,INV-98765,15000.00',
            ParentId = acc.Id,
            Type='LinkPost'
        );
        insert fi;

        Test.setMock(HttpCalloutMock.class, new RiabuOrderServiceMock());

        Test.startTest();
        RiabuGetOrderAndChatterBatch batchObj = new RiabuGetOrderAndChatterBatch();
        Database.executeBatch(batchObj,1);
        Test.stopTest();

        // Assertions
        System.assertEquals(1, [SELECT COUNT() FROM Opportunity WHERE AccountId=:acc.Id]);
        System.assertEquals(1, [SELECT COUNT() FROM Task WHERE WhoId=:con.Id]);
        System.assertEquals(1, [SELECT COUNT() FROM FeedItem WHERE ParentId=:acc.Id]);
    }
}