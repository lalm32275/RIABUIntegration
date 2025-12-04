@isTest
public class OpportunityWithTaskClassTest {
    
     @testSetup
    static void setupTestData() {
        List<Opportunity> testOpps = new List<Opportunity>();
        for (Integer i = 0; i < 3; i++) {
            testOpps.add(new Opportunity(
                Name = 'Test Opp ' + i,
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(30)
            ));
        }
        insert testOpps;
        
        List<Task> testTasks = new List<Task>();
        for (Opportunity opp : testOpps) {
            testTasks.add(new Task(
                WhatId = opp.Id,
                Subject = 'Follow-up Task for ' + opp.Name,
                ActivityDate = Date.today().addDays(5),
                Status = 'Not Started'
            ));
            testTasks.add(new Task(
                WhatId = opp.Id,
                Subject = 'Earlier Task for ' + opp.Name,
                ActivityDate = Date.today().addDays(2),
                Status = 'Not Started'
            ));
        }
        insert testTasks;
    }

    @isTest
    static void testOpportunityTaskDue() {
        Test.startTest();
        OpportunityWithTaskClass.opportunityTaskDue();
        Test.stopTest();

        List<Opportunity> updatedOpps = [SELECT Id, Task_Due_Date__c, Task_Name__c FROM Opportunity WHERE Task_Due_Date__c != null];

        System.assertEquals(3, updatedOpps.size(), 'All Opportunities should have been updated');

        for (Opportunity opp : updatedOpps) {
            System.assertEquals(Date.today().addDays(2), opp.Task_Due_Date__c, 'Task due date should be the earliest task date');
            System.assert(opp.Task_Name__c.contains('Earlier Task'), 'Task name should be from the earliest task');
        }
    }
    
    @isTest
    static void testOpportunityTaskUpdaterScheduler() {
        Test.startTest();
        String jobId = System.schedule('Test Opportunity Task Updater', '0 0 0 * * ?', new OpportunityTaskUpdaterScheduler());
        Test.stopTest();

        CronTrigger ct = [SELECT Id, CronJobDetail.Name, State FROM CronTrigger WHERE CronJobDetail.Name = 'Test Opportunity Task Updater'];
        System.assertEquals('WAITING', ct.State, 'Scheduler job should be in WAITING state');

        List<Opportunity> updatedOpps = [SELECT Id, Task_Due_Date__c, Task_Name__c FROM Opportunity WHERE Task_Due_Date__c != null];
        
        System.assertEquals(3, updatedOpps.size(), 'All Opportunities should have been updated by scheduler');
        for (Opportunity opp : updatedOpps) {
            System.assertEquals(Date.today().addDays(2), opp.Task_Due_Date__c, 'Task due date should be the earliest task date');
            System.assert(opp.Task_Name__c.contains('Earlier Task'), 'Task name should be from the earliest task');
        }
    }   
}