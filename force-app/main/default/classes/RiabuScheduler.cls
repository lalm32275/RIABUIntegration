public class RiabuScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
          System.enqueueJob( new RiabuAccountJob());
          Database.executeBatch( new RiabuAccountDataFetcherClass(), 1);
          Database.executeBatch( new RiabuGetOrderAndChatterBatch(), 1);
        
    }
}