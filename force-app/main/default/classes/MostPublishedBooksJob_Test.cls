@isTest
private class MostPublishedBooksJob_Test {

    // Mock class for successful callout
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);    
          // Success response from API 
          String responsevar = '[{"Publisher":"OReilly Media","Books":[{"Author":"Eric Freeman","Title":"Head First Design Patterns","Edition":1000000},{"Author":"David Flanagan","Title":"JavaScript: The Definitive Guide","Edition":500000},{"Author":"Mark Lutz","Title":"Learning Python","Edition":500000}]},{"Publisher":"Manning Publications","Books":[{"Author":"Andrew Hunt, David Thomas","Title":"The Pragmatic Programmer","Edition":750000},{"Author":"Bruce Eckel","Title":"Thinking in Java","Edition":300000}]},{"Publisher":"Addison-Wesley","Books":[{"Author":"Robert C. Martin","Title":"Clean Code","Edition":1200000},{"Author":"Martin Fowler","Title":"Refactoring: Improving the Design of Existing Code","Edition":900000},{"Author":"Kent Beck","Title":"Test Driven Development: By Example","Edition":450000},{"Author":"Don Norman","Title":"The Design of Everyday Things","Edition":600000}]}]';
            res.setBody(responsevar);
            return res;
        }
    }

    // Mock class for failed callout
    private class MockHttpResponseFailure implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('Internal Server Error');
            return res;
        }
    }

    @isTest static void testExecuteWithMock() {
        
        MockHttpResponseGenerator mocksuccess = new MockHttpResponseGenerator();
        Test.setMock(HttpCalloutMock.class, mocksuccess);
        
        MostPublishedBooksJob publisbookjob = new MostPublishedBooksJob();        
        Test.startTest();             
        System.enqueueJob(publisbookjob);
        Test.stopTest();
    }

    @isTest static void testExecuteCalloutFailure() {      
        MockHttpResponseFailure mockfailure = new MockHttpResponseFailure();
        Test.setMock(HttpCalloutMock.class, mockfailure);
        
        MostPublishedBooksJob publisbookjob = new MostPublishedBooksJob();
        Test.startTest();       
        System.enqueueJob(publisbookjob);
        Test.stopTest();
    }
}