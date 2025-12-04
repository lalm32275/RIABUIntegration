public class OpportunityTaskUpdaterScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        OpportunityWithTaskClass.opportunityTaskDue();
    }
}