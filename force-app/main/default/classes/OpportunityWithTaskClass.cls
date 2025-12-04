public class OpportunityWithTaskClass { 

    public static void opportunityTaskDue() {
        
            // Query all tasks related to Opportunities with ActivityDate greater than today, ordered by ActivityDate descending
            List<Task> taskList = [SELECT Id, WhatId, Subject, ActivityDate FROM Task WHERE WhatId IN (SELECT Id FROM Opportunity) AND 
                                   ActivityDate > TODAY ORDER BY ActivityDate ASC];

            // Map to store latest task per Opportunity
            Map<Id, Task> oppTaskDueDate = new Map<Id, Task>();

            if (!taskList.isEmpty()) {
                for (Task ta : taskList) {
                    if (!oppTaskDueDate.containsKey(ta.WhatId)) {
                        oppTaskDueDate.put(ta.WhatId, ta);
                    }
                }
            }

            // Prepare Opportunity records for update
            List<Opportunity> updateOppList = new List<Opportunity>();

            if (!oppTaskDueDate.isEmpty()) {
                for (Id oppId : oppTaskDueDate.keySet()) {
                    Task ta = oppTaskDueDate.get(oppId);
                    Opportunity opp = new Opportunity();
                    opp.Id = oppId;
                    opp.Task_Due_Date__c = ta.ActivityDate;
                    opp.Task_Name__c = ta.Subject;
                    updateOppList.add(opp);
                }
            }

        try {
            // Perform the update if list is not empty
            if (!updateOppList.isEmpty()) {
                update updateOppList;
            }
        } catch (Exception e) {
            // Log the error or handle it as per your org’s error handling policy
            System.debug('Error in opportunityTaskDue: ' + e.getMessage());
        }
    }
}