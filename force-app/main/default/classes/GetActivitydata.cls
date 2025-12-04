public class GetActivitydata {
@AuraEnabled
public static List<Task> activityrecord(string recordId){
    List<Task> tasklist = [select id, WhatId,Subject, TaskSubtype from Task where WhatId =:recordId ];
    return tasklist;
}
}