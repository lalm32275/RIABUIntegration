@isTest
public class RiabuAccountDataFetcherClassTest {

    // --------------------------
    // 1. Mock All HTTP Callouts
    // --------------------------
    private class RiabuMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {

            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);

            // MASTER FILE RESPONSE
            if (req.getEndpoint().contains('master-file/view')) {
                res.setBody('{"data":{"company_name":"Test Co","model":{"id":111,"agreed_credit_terms_day":30,"procurement_portal":"Portal","company":{"uen":"UEN123"},"accounts_payable_email_address":"ap@test.com","accounts_payable_phone_number":"9999","email_to_send_e_invoices_to":"invoice@test.com","accounts_payable_contact_name":"John","high_risk_customer":false,"has_customer_signed":1,"reason_has_not_signed":"None"}}}');
                return res;
            }

            // ORDER LIST RESPONSE
            if (req.getEndpoint().contains('order/get-list')) {
                res.setBody('{"data":{"items":[{"id":222,"end_date":1700000000,"master_file_id":1,"purchase_number":"PN001","order_items":[{"id":333,"order_id":222,"name":"Order1","detail":"details","deadline":"2025-01-01","deadline_object":{"day":"01","month":"01","year":"2025"}}]}]}}');
                return res;
            }

            // SERVICE CALL RESPONSE
            if (req.getEndpoint().contains('service-call')) {
                res.setBody('{"data":{"calls":{"items":[{"id":444,"person":"P1","assigned_discrepancy_manager":"DM1","assigned_discrepancy_supervisor":"DS1","assigned_gm_ceo":"CEO","invoice_number":"INV123","invoice_amount":"100"}]}}}');
                return res;
            }

            return res;
        }
    }


    // --------------------------
    // 2. TEST METHOD
    // --------------------------
    @isTest
    static void testBatchExecution() {

        // Insert Riabu__c record
        Riabu__c riabu = new Riabu__c(
            Name = 'Test',
            Client_Id__c = 'abc',
            client_secret__c = 'sec',
            Password__c = 'pass',
            refreshToken__c = 'ref',
            AccessToken__c = 'token123',
            Expire_Date__c = Date.today().addDays(10)
        );
        insert riabu;

        // Account that batch will update
        Account acc = new Account(
            Name = 'Old Name',
            RiabuAccountId__c = '111'
        );
        insert acc;

        // Pre-existing Contact (will test update branch)
        Contact oldCon = new Contact(
            LastName = 'Old',
            AccountId = acc.Id,
            isPrimary__c = true
        );
        insert oldCon;

        // Pre-existing Opportunity (update branch)
        Opportunity oldOpp = new Opportunity(
            Name = 'Old Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            AccountId = acc.Id,
            riabu_Order_Id__c = '222'
        );
        insert oldOpp;

        // Pre-existing Task (update)
        Task oldTask = new Task(
            Subject = 'Test Task',
            WhoId = oldCon.Id,
            WhatId = oldOpp.Id,
            riabu_Task_Id__c = '333',
            ActivityDate = Date.today()
        );
        insert oldTask;

        // Pre-existing FeedItem (update)
        FeedItem oldPost = new FeedItem(
            ParentId = acc.Id,
            Body = '444,P1,DM1,DS1,CEO,INV123,100'
        );
        insert oldPost;


        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new RiabuMock());

        Database.executeBatch(new RiabuAccountDataFetcherClass(), 1);

        Test.stopTest();


        // --------------------------
        // ASSERTIONS
        // --------------------------
        Account updatedAcc = [
            SELECT Name, Registration_Number__c, Days_to_Pay__c, Procurement_Portal__c
            FROM Account
            WHERE Id = :acc.Id
        ];

        System.assertEquals('Old Name', updatedAcc.Name);
        System.assertEquals(null, updatedAcc.Registration_Number__c);
        System.assertEquals(null, updatedAcc.Days_to_Pay__c);
        System.assertEquals(null, updatedAcc.Procurement_Portal__c);


        // Contact updated
        Contact con = [
            SELECT Email, LastName
            FROM Contact
            WHERE AccountId = :acc.Id
            LIMIT 1
        ];
        System.assertEquals('ap@test.com', con.Email);


        // Opportunity updated/inserted
        Opportunity opp = [
            SELECT riabu_Order_Id__c
            FROM Opportunity
            WHERE AccountId = :acc.Id
            LIMIT 1
        ];
        System.assertEquals('222', opp.riabu_Order_Id__c);


        // Chatter post updated
        FeedItem post = [
            SELECT Body
            FROM FeedItem
            WHERE ParentId = :acc.Id
            LIMIT 1
        ];
        System.assert(post.Body.contains('444'));
    }
}