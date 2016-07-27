//
//  CloudConnection.m
//  Ticket Dash
//
//  Created by John Cardasis on 1/24/15.
//  Copyright (c) 2015 John Cardasis. All rights reserved.
//

#import "CloudConnection.h"
#import "JLogging.h"
#import <CloudKit/CloudKit.h>

@implementation CloudConnection

-(id) init{
    self =[super init];
    return self;
}

-(BOOL)uploadToCloudWithValues: (NSDictionary*) values WithCompletionHandler:(onCompletion) block{
    __block BOOL success; //Allows variable to be editted inside a block
    NSString *email = [values objectForKey:@"Email"];
    CKRecord *newRecord;
    if([email containsString:@"catholiccentral.net"]) //will upload student scores so separate record
        newRecord = [[CKRecord alloc] initWithRecordType:@"SchoolScores"];
    else
        newRecord = [[CKRecord alloc] initWithRecordType:@"WorldScores"];
    
    //Create and set record instance properties
    newRecord[@"Name"] = [values objectForKey:@"Name"];
    newRecord[@"Score"]= [values objectForKey:@"Score"];
    newRecord[@"TimeUploaded"]= [values objectForKey:@"TimeUploaded"];
    newRecord[@"Email"]= email;
    newRecord[@"AppVersion"]= [values objectForKey:@"AppVersion"];
    
    //Get the PublicDatabase from the Container for this app
    CKDatabase *publicDatabase = [[CKContainer defaultContainer] publicCloudDatabase];
    
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    //Save the record to the target database
    [publicDatabase saveRecord:newRecord completionHandler:^(CKRecord *record, NSError *error) {
        
        if(error) { //Handle an error saving
            DLog(@"There was an eror uploading to CloudKit: %@", error);
            success = false;
            
        } else {
            DLog(@"Saved successfully with values:");
            DLog(@"Name: %@", record[@"Name"]);
            DLog(@"Score: %@", record[@"Score"]);
            DLog(@"TimeUploaded: %@", record[@"TimeUploaded"]);
            DLog(@"Email: %@", record[@"Email"]);
            DLog(@"App Version: %@", record[@"AppVersion"]);
            
            block();
        }
        dispatch_semaphore_signal(sema);
    }];
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    if(!success)//failed to upload score(s)
        return false;
    
    return true;
}


-(NSArray*)getSchoolScores{
    return [self getRecordsInRecordNamed:@"SchoolScores"];
}

-(NSArray*)getWorldScores{
    return [self getRecordsInRecordNamed:@"WorldScores"];
}


-(NSArray*)getRecordsInRecordNamed:(NSString*)recordName{
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);//Block kernal thread to prevent async
    __block BOOL success; //Allows variable to be editted inside a block
    CKDatabase *publicDatabase = [[CKContainer defaultContainer] publicCloudDatabase];
    CKQuery *query;
    NSMutableArray *records = [[NSMutableArray alloc] init];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"TRUEPREDICATE", nil]; //Do not limit search to keyphrases

    if([recordName isEqualToString:@"SchoolScores"])
        query = [[CKQuery alloc] initWithRecordType:@"SchoolScores" predicate:predicate];
    else//Get World Scores
        query = [[CKQuery alloc] initWithRecordType:@"WorldScores" predicate:predicate];
    
    query.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"Score" ascending:false]];//Sorts from top score to lowest score
    
    CKQueryOperation *queryOp = [[CKQueryOperation alloc] initWithQuery:query];
    queryOp.desiredKeys = @[@"Name", @"Score"]; //Values to store
    queryOp.resultsLimit = 25; //Will get top 25 scores
    
    [publicDatabase addOperation:queryOp]; //Start the query operation
    
    /* Do stuff with the server connection */
    queryOp.recordFetchedBlock = ^(CKRecord *record)
    {
        DLog(@"%@", recordName);
        NSDictionary *currentRecord = @{ //Create dictionary to store results
                                        @"Name": record[@"Name"],
                                        @"Score" : record[@"Score"]
                                        };
        [records addObject:currentRecord];
    };
    
    queryOp.queryCompletionBlock = ^(CKQueryCursor *cursor, NSError *queryError)
    {
        if(queryError != nil){
            DLog(@"An Error Occurred trying to recieve records: %@", queryError);
            success =false;
        }
        
        dispatch_semaphore_signal(sema); //allows to pass the stopped thread
    };
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER); //semaphore will last forever so that the async becomes sync request
    
    if(!success)//failed to get scores
        return nil;
    
    return (NSArray*)records;
}

@end
