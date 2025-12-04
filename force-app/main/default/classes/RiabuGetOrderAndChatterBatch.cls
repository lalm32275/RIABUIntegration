public class RiabuGetOrderAndChatterBatch implements Database.Batchable<sObject>,Database.AllowsCallouts {
    public Database.QueryLocator start( Database.BatchableContext bc ){
        return Database.getQueryLocator('SELECT Id,RiabuAccountId__c,Name,Registration_Number__c,Days_to_Pay__c,Procurement_Portal__c FROM Account WHERE RiabuAccountId__c != Null');
    }
    public void execute( Database.BatchableContext bc, List<Account> existAccountList ){
         Riabu__c riabuObj = [
            SELECT Id, Name, Client_Id__c, client_secret__c, Password__c, refreshToken__c, AccessToken__c, Expire_Date__c 
            FROM Riabu__c 
            WHERE Expire_Date__c > TODAY 
         	LIMIT 1
        ];
        List<Account> acclistToUpdate = new List<Account>();
        List<Contact>updateContactList = new List<Contact>();
        List<Contact>contactInsertList = new List<Contact>();
        Set<String> existAccountIdSet = new Set<String>();
        for( Account acc : existAccountList ){
            existAccountIdSet.add( acc.Id );
        }
        Map<Id,Contact> existConDataMap = new Map<Id,Contact> (  );
        for( Contact con : [ Select id,LastName,AccountId From Contact Where AccountId In : existAccountIdSet AND isPrimary__c = True ] ){
            existConDataMap.put( con.AccountId, con );
        }
        Map<String,Opportunity> existOppDataMap = new Map<String,Opportunity> (  );
        for( Opportunity opp : [ Select id,AccountId,riabu_Order_Id__c From Opportunity Where AccountId In : existAccountIdSet AND riabu_Order_Id__c != Null ] ){
            existOppDataMap.put( opp.riabu_Order_Id__c, opp );
        }
        Map<String,Task> existTaskDataMap = new Map<String,Task> (  );
        for( Task taskObj : [ SELECT Id, WhoId, WhatId, Subject,riabu_Task_Id__c, ActivityDate FROM Task WhERE riabu_Task_Id__c != Null ] ){
            existTaskDataMap.put( taskObj.riabu_Task_Id__c, taskObj );
        }
        Map<String,FeedItem> existChatterDataMap = new Map<String,FeedItem> (  );
        for( FeedItem feedObj : [ SELECT Id, Title, Body, LinkUrl, IsRichText, RelatedRecordId, InsertedById, BestCommentId FROM FeedItem ] ){
            //List<String> serviceCallDataList = feedObj.Body.split(',');
			//System.debug( serviceCallDataList[0] );
            existChatterDataMap.put( feedObj.Body, feedObj );
        }
        List<Opportunity> updateOppList = new List<Opportunity>();
        List<Opportunity> insertOppList = new List<Opportunity>();
        List<Task> insertTaskList = new List<Task>();
        List<Task> updateTaskList = new List<Task>();
        List<FeedItem> insertChatterList = new List<FeedItem>();
        List<FeedItem> updateChatterList = new List<FeedItem>();
        for( Account acc : existAccountList){            
            //Getting orders of an Account
            HttpRequest req2 = new HttpRequest();
            req2.setEndpoint('https://admin.riabu.com/api/v1/order/get-list/'+acc.RiabuAccountId__c+'?per-page=99999&page=1');
            req2.setMethod('GET');
			req2.setHeader('Authorization', 'Bearer '+riabuObj.AccessToken__c); 
            Http http2 = new Http();
            HttpResponse res2 = http2.send(req2);
            
            if (res2.getStatusCode() == 200) {
                String jsonResponse2 = res2.getBody();
                System.debug( 'jsonResponse2' + jsonResponse2 );
                
                Map<String, Object> topMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse2);
                
                // Extract data > items
                Map<String, Object> dataMap = (Map<String, Object>) topMap.get('data');
                List<Object> itemsList = (List<Object>) dataMap.get('items');
                
                for (Object itemObj : itemsList) {
                    Opportunity opp = new Opportunity();
                    Map<String, Object> itemMap = (Map<String, Object>) itemObj;
                    opp.riabu_Order_Id__c = String.valueOf( itemMap.get('id') );
                   // opp.Name = 'Riabu Opportunity';
                   // Integer unixTimestamp = (Integer)itemMap.get('end_date');     
                  //  Integer milliseconds = unixTimestamp * 1000;
                  //  DateTime dt = DateTime.newInstance(milliseconds);
                  //  Date closeDate = dt.date();
                   // opp.CloseDate = closeDate;
                    opp.AccountId = acc.Id;
                   // opp.StageName = 'Enquiry received – MUST REPLY!';
                    if(  existOppDataMap.ContainsKey( String.valueOf( itemMap.get('id') ) ) ){
                            opp.Id = existOppDataMap.get( String.valueOf( itemMap.get('id') ) ).Id;
                            system.debug('existOppDataMap'+existOppDataMap);
                        	system.debug( 'opp' + opp );
                                updateOppList.add( opp );    
                        system.debug( 'updateOppList' + updateOppList );
                     }
                     else{
                                opp.Name=acc.name+' - RIABU Order - '+opp.riabu_Order_Id__c+' - Opp - '+Date.today().format();
                                opp.CloseDate = Date.Today().addDays(30);
                                opp.StageName = 'Enquiry received – MUST REPLY!';
                                OpportunityTriggerHandler.isBatchCall = true;
                                insertOppList.add( opp );       
                        }
                    // Order-level fields
                    Integer orderId = (Integer) itemMap.get('id');
                    Integer masterFileId = (Integer) itemMap.get('master_file_id');
                    String createdAt = (String) itemMap.get('created_at');
                    String purchaseNumber = (String) itemMap.get('purchase_number');
                    
                    System.debug('Order ID: ' + orderId + ', Purchase Number: ' + purchaseNumber);
                    
                    // Extract order_items
                    List<Object> orderItems = (List<Object>) itemMap.get('order_items');
                    
                    for (Object orderItemObj : orderItems) {
                        Map<String, Object> orderItemMap = (Map<String, Object>) orderItemObj;
                        System.debug('acc.Id'+ acc.Id );
                        system.debug('existConDataMap'+ existConDataMap);
                        system.debug('existOppDataMap'+ existOppDataMap);
                        if( existConDataMap.ContainsKey( acc.Id ) && existOppDataMap.ContainsKey( String.valueOf( orderItemMap.get('order_id') ) ) ){
                            
                            system.debug('existConDataMap'+ existConDataMap);
                            system.debug('existOppDataMap'+ existOppDataMap);
                            Task riabuTask = new Task();
                            riabuTask.Subject = (String) orderItemMap.get('name');
                            riabuTask.WhoId =  existConDataMap.get( acc.Id).Id;
                            riabuTask.WhatId = existOppDataMap.get( String.valueOf( orderItemMap.get('order_id') ) ).Id;
                            String deadline = (String) orderItemMap.get('deadline');
                            riabuTask.ActivityDate  = date.valueOf( deadline.substring(0,10) );
                            riabuTask.riabu_Task_Id__c  =  String.valueOf( orderItemMap.get('id') );
                            if( !existTaskDataMap.isEmpty() && existTaskDataMap.containsKey( String.valueOf( orderItemMap.get('id') ) ) ){
                               riabuTask.Id =  existTaskDataMap.get( String.valueOf( orderItemMap.get('id') ) ).Id;
                               updateTaskList.add( riabuTask );
                            }
                            else{
                                insertTaskList.add( riabuTask );
                            }
                        }
                        
                     
                        
                        Integer itemId = (Integer) orderItemMap.get('id');
                        
                        String name = (String) orderItemMap.get('name');
                        
                        String detail = (String) orderItemMap.get('detail');
                        String deadline = (String) orderItemMap.get('deadline');
                        // Optional: access deadline_object
                        Map<String, Object> deadlineObj = (Map<String, Object>) orderItemMap.get('deadline_object');
                        String day = (String) deadlineObj.get('day');
                        String month = (String) deadlineObj.get('month');
                        String year = (String) deadlineObj.get('year');
                        
                        System.debug('  → Item ID: ' + itemId + ', Name: ' + name + ', Deadline: ' + day + '-' + month + '-' + year);
                     
                    }
                }
                
            }
            HttpRequest req3 = new HttpRequest();
            req3.setEndpoint('https://admin.riabu.com/api/v1/service-call/'+acc.RiabuAccountId__c+'?per-page=999999&page=1');
            req3.setMethod('GET');
			req3.setHeader('Authorization', 'Bearer '+riabuObj.AccessToken__c);
            Http http3 = new Http();
            HttpResponse res3 = http3.send(req3);
            try
            {
            if (res3.getStatusCode() == 200) {
                String jsonResponse3 = res3.getBody();
                System.debug( 'jsonResponse3' + jsonResponse3 );
                Map<String, Object> serviceMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse3);
                
                // Extract data > items
                Map<String, Object> dataMap = (Map<String, Object>) serviceMap.get('data');
                Map<String, Object> itemsMap = (Map<String, Object>) dataMap.get('calls');
              	List<Object> itemsList = (List<Object>) itemsMap.get('items');
                for (Object itemObj : itemsList) {
                	Map<String, Object> itemMap = (Map<String, Object>) itemObj;
                    String serviceCallId = String.valueOf( itemMap.get('id') );
                   	FeedItem post = new FeedItem();
					post.ParentId = acc.Id; 
					String Body = String.valueOf( itemMap.get('id') )+','+itemMap.get('person')+','+itemMap.get('assigned_discrepancy_manager')+','+itemMap.get('assigned_discrepancy_supervisor')+','+itemMap.get('assigned_gm_ceo')+','+itemMap.get('invoice_number')+','+itemMap.get('invoice_amount');
					System.debug( 'Body' + Body );
                    post.Body = Body; 
                    post.Type = 'LinkPost';
					post.LinkUrl = 'https://www.riabu.com/account/my-customers';
                    if( !existChatterDataMap.isEmpty() && existChatterDataMap.containsKey( Body ) ){
                          post.Id =  existChatterDataMap.get( Body ).Id;
                          updateChatterList.add( post );
                    }
                    else{
                          insertChatterList.add( post );
                    }
                }
            }
            } 
            catch(Exception e)
            {
                System.debug('Exception Occurred :'+ e.getMessage());
            }
        }
        if( !acclistToUpdate.isEmpty() ){
            System.debug( 'acclistToUpdate' + acclistToUpdate );
            try
            {
            UPDATE acclistToUpdate;
            }
            catch(Exception e)
            {
                System.debug('Accounts Updation Failed:'+e.getMessage());
            }
        }
        if( !contactInsertList.isEmpty() ){
            System.debug( 'contactInsertList' + contactInsertList );
            ContactTriggerHandler.isBatchCall = true;
            try
            {
            INSERT contactInsertList;
            }
            catch(Exception e)
            {
                System.debug('Contact Insertion Failed :'+e.getMessage());
            }
        }
        if( !updateContactList.isEmpty() ){
            System.debug( 'updateContactList' + updateContactList );
            ContactTriggerHandler.isBatchCall = true;
            try
            {
            UPDATE updateContactList;
            }
            catch(Exception e)
            {
                System.debug('Contact Update Failed :'+e.getMessage());
            }
        }
        if( !insertOppList.isEmpty() ){
            System.debug( 'insertOppList' + insertOppList );
            OpportunityTriggerHandler.isBatchCall = true;
            try
            {
            INSERT insertOppList;
            }
            catch(Exception e)
            {
                System.debug('Opportunity Insertion Failed :'+e.getMessage());
            }
        }
        System.debug( 'updateOppList' + updateOppList );
        if (!updateOppList.isEmpty()) {
            // Deduplicate by Opportunity Id
            Map<Id, Opportunity> uniqueOppMap = new Map<Id, Opportunity>();
            for (Opportunity opp : updateOppList) {
                if (opp.Id != null) {
                    uniqueOppMap.put(opp.Id, opp); // If same Id repeats, last one will overwrite
                }
            }
            
            List<Opportunity> deduplicatedUpdateList = uniqueOppMap.values();
            
            System.debug('Deduplicated updateOppList: ' + deduplicatedUpdateList);
            OpportunityTriggerHandler.isBatchCall = true;
            UPDATE deduplicatedUpdateList;
        }
        if( !updateTaskList.isEmpty() ){
            System.debug( 'updateTaskList' + updateTaskList );
            try
            {
             UPDATE updateTaskList;
            }
            catch(Exception e)
            {
                System.debug('Task Updation Failed :'+e.getMessage());
            }
        }
        if( !insertTaskList.isEmpty() ){
            System.debug( 'insertTaskList' + insertTaskList );
            try
            {
            INSERT insertTaskList;
            }
            catch(Exception e)
            {
               System.debug('Task Insertion Failed :'+e.getMEssage());
            }
        }
        if( !updateChatterList.isEmpty() ){
            System.debug( 'updateChatterList' + updateChatterList );
            try
            {
              UPDATE updateChatterList;
            }
            catch(Exception e)
            {
                System.debug('Chatter Update Faied :'+e.getMessage());
            }
        }
        if( !insertChatterList.isEmpty() ){
            System.debug( 'insertChatterList' + insertChatterList );
            try
            {
            INSERT insertChatterList;
            }
            catch(Exception e)
            {
                System.debug('Chatter Insertion Failed :'+e.getMessage());
            }
        }
        
    }
    public void finish( Database.BatchableContext bc ){
        System.debug('Batch finish');
    }
    
}