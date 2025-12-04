@IsTest
public class RiabuSchedulerTest {
    
    @IsTest
    static void testScheduler() {
        Test.startTest();
        // Schedule the job
        String jobId = System.schedule('Test Riabu Scheduler', '0 0 0 * * ?', new RiabuScheduler());
        Test.stopTest();
        
        // Verify the job was scheduled
        System.assert(jobId != null, 'Job should be scheduled');
    }
    
    @IsTest
    static void testExecute() {
        // Create mock for the queueable job
        Test.setMock(HttpCalloutMock.class, new MockResponseGenerator());
        
        Test.startTest();
        // Execute the scheduler directly
        RiabuScheduler scheduler = new RiabuScheduler();
        scheduler.execute(null);
        Test.stopTest();
        
        // Verify it runs without error
        System.assert(true, 'Scheduler should run without error');
    }
    
    public class MockResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{"data": []}');
            return res;
        }
    }
}