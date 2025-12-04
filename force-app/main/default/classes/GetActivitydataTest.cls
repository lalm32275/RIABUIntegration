@istest
public class GetActivitydataTest {
@istest
    public static void testdata(){
        opportunity opp = new opportunity(Name='test',stagename='Close Won',closedate=date.today());
        GetActivitydata.activityrecord(opp.Id);
    }
}