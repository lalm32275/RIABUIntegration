public class RiabuBatchLauncher implements Queueable {
    public void execute( QueueableContext qc ){
        Database.executeBatch( new RiabuAccountDataFetcherClass(), 1);
    }
}