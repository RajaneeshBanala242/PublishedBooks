import { LightningElement } from 'lwc';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';
import enqueueJob from '@salesforce/apex/MostPublishedBooksJob.enqueueJob';

export default class Publishbooks extends LightningElement {
    books = [];
    subscription = null;
    channelName = '/event/MostPublishedBooks__e';

    connectedCallback() {
        var self = this; 

        onError(function(error) {
            console.error('Error from EMP API: ', error);
        });

        // Subscribe to the Platform Event channel
        this.subscribeToChannel();
    }

    disconnectedCallback() {
        // Unsubscribe when component is removed
        this.unsubscribeFromChannel();
    }

    subscribeToChannel() {
        var self = this;        
        function messageHandler(response) {
            // Get the event data from the response
            var eventData = response.data.payload;

            // Create a book object and pass eventdata
            var book = {
                title: eventData.Title__c,
                author: eventData.Author__c,
                edition: eventData.Edition__c,
                publisher: eventData.Publisher__c,
                key: eventData.Title__c + '-' + eventData.Edition__c
            };
        
            self.books = self.books.concat(book);
        }

        // Subscribe to the event channel
        subscribe(this.channelName, -1, messageHandler).then(function(response) {
            self.subscription = response;
            console.log('@@@@Subscribed to channel: ', response.channel);
        });
    }

    unsubscribeFromChannel() {
        var self = this;

        if (this.subscription) {
            unsubscribe(this.subscription, function(response) {
                console.log('Unsubscribed from channel');
                self.subscription = null;
            });
        }
    }
    // function to call the onclick utton associated 
     handleFetchBooks(event) {
        const actionName = event.target.value;
        enqueueJob()
            .then(() => {              
                console.log('********Queueable job enqueued successfully.');
            })
            .catch(error => {
                console.error('Error enqueuing job: ', error);
            });
    }
}