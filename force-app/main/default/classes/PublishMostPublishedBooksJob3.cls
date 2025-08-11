public class PublishMostPublishedBooksJob3 implements Queueable, Database.AllowsCallouts {
    
    private static final String GETMETHOD = 'GET';
    private static final INTEGER STATUSCODE = 200 ;
    private static final INTEGER FILTEREDITIONSIZE = 600000 ;
    
    public void execute(QueueableContext context) {
        
        try {
            
            HttpResponse response = makeCallOut();
            System.debug('Response Status Code: ' + response.getStatusCode());
            
            if (response.getStatusCode() == STATUSCODE) {
                
                List<PublisherWrapper> publishersList = (List<PublisherWrapper>) JSON.deserialize(response.getBody(), List<PublisherWrapper>.class);
                Map<String, List<BookWrapper>> publisherBookMap = new Map<String, List<BookWrapper>>();
                List<BookWrapper> allBooksList = new List<BookWrapper>();
                
                // Build map and collect all books
                for (PublisherWrapper pub : publishersList) {
                    publisherBookMap.put(pub.Publisher, pub.Books);
                    allBooksList.addAll(pub.Books);
                    
                }
                System.debug('Books before filterng' + allBooksList);
                System.debug('Number of books before filtering' + allBooksList.size());
                
                // Filter the books with edition size > 600000               
                List<BookWrapper> filteredBooksList = new List<BookWrapper>();
                if(allBooksList != null && allBooksList.size() > 0){
                    for (BookWrapper book : allBooksList) {
                        if (book.Edition > FILTEREDITIONSIZE) {
                            filteredBooksList.add(book);
                        }
                    }
                    System.debug('Books after filtering but before sorting %%%%%%%' + filteredBooksList);
                    filteredBooksList.sort();
                }
                
                System.debug('Number of books after filtering' + filteredBooksList.size()); 
                System.debug('Books after Sorting' + filteredBooksList);
                
                // Publish Platform Event 
                List<MostPublishedBooks__e> events = new List<MostPublishedBooks__e>();
                if(filteredBooksList != null && filteredBooksList.size() > 0){
                    for (BookWrapper book : filteredBooksList) {
                        MostPublishedBooks__e event = new MostPublishedBooks__e();
                        event.Title__c = book.Title;
                        event.Author__c = book.Author;
                        event.Edition__c = book.Edition;
                        event.Publisher__c = getPublisherForBook(publisherBookMap, book);
                        events.add(event);
                    }
                }
                
                if (!events.isEmpty()) {
                    EventBus.publish(events);
                }
                
            } 
        } catch (Exception ex) {
            System.debug(' Exception ' + ex.getMessage());
            System.debug(' Exception ' + ex.getLineNumber());           
        }
    }
    
    // Helper method to find publisher name for a given book
    private String getPublisherForBook(Map<String, List<BookWrapper>> publisherBookMapVar, BookWrapper bookVar) {
        for (String publisher : publisherBookMapVar.keySet()) {
            if (publisherBookMapVar.get(publisher).contains(bookVar)) {
                return publisher;
            }
        }
        return null;
    }
    
    private HttpResponse makeCallOut(){    
        HttpResponse responseVar = new HttpResponse();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:PublishedBooks'); // Named Credential
        request.setMethod(GETMETHOD);
        request.setTimeout(10000);
        responseVar = http.send(request);        
        return responseVar ;
    }
    
    // Wrapper class from JSON Response
    public class PublisherWrapper {
        public String Publisher;
        public List<BookWrapper> Books;
    }
    
    public class BookWrapper implements Comparable {
        public String Title;
        public String Author;
        public Integer Edition;
        
        public Integer compareTo(Object obj) {      
            BookWrapper other = (BookWrapper)obj;      
            Integer resultValue;
            
            // if both editions are the same
            if (this.Edition == other.Edition) {
                resultValue = 0;
            }
            
            // if other edition is bigger than this one
            if (this.Edition < other.Edition) {
                resultValue = 1; 
            }
            
            // if this edition is bigger than other one
            if (this.Edition > other.Edition) {
                resultValue = -1; 
            }
            
            return resultValue;
        }
    }
    
}