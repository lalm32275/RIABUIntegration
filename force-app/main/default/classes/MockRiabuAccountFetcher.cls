@IsTest
public class MockRiabuAccountFetcher {
    public static List<Map<String, Object>> mockData = new List<Map<String, Object>>();
    public static Boolean throwException = false;

    public static void setupMock(List<Map<String, Object>> data, Boolean shouldThrowException) {
        mockData = data;
        throwException = shouldThrowException;
    }
}