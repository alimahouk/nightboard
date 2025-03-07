//
//  SHModelManager.m
//  Nightboard
//
//  Created by MachOSX on 8/3/13.
//
//

#import "SHModelManager.h"

#import "AppDelegate.h"

@implementation SHModelManager

- (id)init
{
	if ( self = [super init] )
    {
        [self synchronizeLatestDB];
	}
    
	return self;
}

// This returns a SQLite-friendly timestamp.
- (NSString *)dateTodayString
{
    NSDate *today = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    
    return [dateFormatter stringFromDate:today];
}

- (int)schemaVersion
{
    FMResultSet *s1 = [self executeQuery:@"PRAGMA user_version" withParameterDictionary:nil];
    int version = 0;
    
    while ( [s1 next] )
    {
        version = [s1 intForColumnIndex:0];
    }
    
    [s1 close];
    [_results close];
    [_DB close];
    
    return version;
}

- (void)incrementSchemaVersion
{
    int currentVersion = [self schemaVersion];
    currentVersion++;
    
    NSString *query = [NSString stringWithFormat:@"PRAGMA user_version = %d", currentVersion];
    FMResultSet *s1 = [self executeQuery:query withParameterDictionary:nil];
    [s1 next];
    [s1 close];
}

#pragma mark - 
#pragma mark Database Creation
/******************************************************************
 Every database has a table called "db_metadata", which stores the
 time that the file was last backed up & the time it was last
 modified (entered manually).
 ******************************************************************/

- (void)synchronizeLatestDB
{
    // Get the documents directory.
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [dirPaths objectAtIndex:0];
    NSString *templateDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DB_TEMPLATE_NAME];
    
    _databasePath = [documentsDirectory stringByAppendingPathComponent:DB_TEMPLATE_NAME];
    _DB = [FMDatabase databaseWithPath:_databasePath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    if ( ![fileManager fileExistsAtPath:_databasePath] )
    {
        if ( [fileManager copyItemAtPath:templateDBPath toPath:_databasePath error:&error] )
        {
            NSLog(@"Database created!");
            
            if ( ![_DB open] )
            {
                NSLog(@"FMDB: failed to open the database!");
            }
        }
        else
        {
            NSLog(@"Failed to copy the DB file: %@", error);
        }
    }
    
    /*
     *  Schema/App versions
     *  ==
     *  1: v1.0
     *  2: v1.2
     */
    switch ( [self schemaVersion] )
    {
        case 1: // Update for users still on the 1.0 schema.
        {
            // Introduction of boards.
            [self executeUpdate:@"CREATE TABLE 'sh_board' ('board_id' INTEGER PRIMARY KEY  NOT NULL, 'rank_score' REAL, 'coordinate_x' INTEGER, 'coordinate_y' INTEGER, 'name' VARCHAR, 'description' VARCHAR, 'owner_id' INTEGER, 'privacy' INTEGER, 'cover_hash' VARCHAR, 'dp' BLOB, 'date_created' VARCHAR, 'last_view_timestamp' DATETIME, 'view_count' INTEGER DEFAULT (0));"
                    withParameterDictionary:nil];
            [self incrementSchemaVersion];
            
            break;
        }
            
        default:
        {
            break;
        }
    }
}

- (void)resetDB
{
    // Get the template file.
    NSString *templateDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DB_TEMPLATE_NAME];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    if ( [fileManager fileExistsAtPath:_databasePath] )
    {
        if ( [fileManager removeItemAtPath:_databasePath error:&error] )
        {
            if ( [fileManager copyItemAtPath:templateDBPath toPath:_databasePath error:&error] )
            {
                NSLog(@"Database reset!");
                
                if ( ![_DB open] )
                {
                    NSLog(@"FMDB: failed to open the database!");
                }
            }
            else
            {
                NSLog(@"Failed to re-copy the DB file: %@", error);
            }
        }
    }
    else
    {
        if ( [fileManager copyItemAtPath:templateDBPath toPath:_databasePath error:&error] )
        {
            NSLog(@"Database reset!");
            
            if ( ![_DB open] )
            {
                NSLog(@"FMDB: failed to open the database!");
            }
        }
        else
        {
            NSLog(@"Failed to re-copy the DB file: %@", error);
        }
    }
}

- (BOOL)executeUpdate:(NSString *)statement withParameterDictionary:argsDict
{
    if ( ![_DB open] )
    {
        NSLog(@"FMDB: failed to open database!");
        return NO;
    }
    else
    {
        sqlite3_exec(_DB.sqliteHandle, [[NSString stringWithFormat:@"PRAGMA foreign_keys = ON;"] UTF8String], NULL, NULL, NULL);
        
        BOOL success = [_DB executeUpdate:statement withParameterDictionary:argsDict];
        
        if ( [_DB lastErrorCode] != 0 )
        {
            NSLog(@"FMDB Insert Error: %@", [_DB lastError]);
        }
        
        [_DB close];
        
        return success;
    }
}

- (FMResultSet *)executeQuery:(NSString *)statement withParameterDictionary:argsDict
{
    if ( ![_DB open] )
    {
        NSLog(@"FMDB: failed to open database!");
        return nil;
    }
    else
    {
        _results = [_DB executeQuery:statement withParameterDictionary:argsDict];
        
        if ( [_DB lastErrorCode] != 0 )
        {
            NSLog(@"FMDB SELECT Error: %@", [_DB lastError]);
        }
        
        return _results;
    }
}

- (void)saveCurrentUserData:(NSDictionary *)userData
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    NSString *userID = [NSString stringWithFormat:@"%@", [userData objectForKey:@"user_id"]];
    NSString *name = [userData objectForKey:@"name"];
    NSString *alias = @"";
    NSString *userHandle = @"";
    __block NSString *DPHash = @"";
    NSString *imageData_alias = @""; // Insert this as a blank string since the user can't have an alias DP for themselves.
    NSString *email = @"";
    NSString *gender = @"";
    NSString *birthday = @"";
    NSString *location_country = @"";
    NSString *location_state = @"";
    NSString *location_city = @"";
    NSString *website = @"";
    NSString *bio = @"";
    NSString *joinDate = [userData objectForKey:@"join_date"];
    
    NSString *lastStatus = @"";
    NSString *lastStatusID = @"";
    NSString *lastStatusTimestamp = @"";
    NSString *lastStatusType = @"";
    NSString *lastStatusLocation_latitude = @"";
    NSString *lastStatusLocation_longitude = @"";
    NSString *lastStatusRootItemID = @"";
    NSString *lastStatusMediaType = @"";
    NSString *lastStatusMediaHash = @"";
    NSString *lastStatusMediaData = @"";
    NSString *lastStatusMediaExtra = @"";
    
    // =======================================
    
    if ( [userData objectForKey:@"user_handle"] && ![[NSNull null] isEqual:[userData objectForKey:@"user_handle"]] )
    {
        userHandle = [userData objectForKey:@"user_handle"];
    }
    
    if ( [userData objectForKey:@"dp_hash"] && ![[NSNull null] isEqual:[userData objectForKey:@"dp_hash"]] )
    {
        DPHash = [userData objectForKey:@"dp_hash"];
    }
    
    if ( [userData objectForKey:@"email_address"] && ![[NSNull null] isEqual:[userData objectForKey:@"email_address"]] )
    {
        email = [userData objectForKey:@"email_address"];
    }
    
    if ( [userData objectForKey:@"gender"] && ![[NSNull null] isEqual:[userData objectForKey:@"gender"]] )
    {
        gender = [userData objectForKey:@"gender"];
    }
    
    if ( [userData objectForKey:@"location_country"] && ![[NSNull null] isEqual:[userData objectForKey:@"location_country"]] )
    {
        location_country = [userData objectForKey:@"location_country"];
    }
    
    if ( [userData objectForKey:@"location_state"] && ![[NSNull null] isEqual:[userData objectForKey:@"location_state"]] )
    {
        location_state = [userData objectForKey:@"location_state"];
    }
    
    if ( [userData objectForKey:@"location_city"] && ![[NSNull null] isEqual:[userData objectForKey:@"location_city"]] )
    {
        location_city = [userData objectForKey:@"location_city"];
    }
    
    if ( [userData objectForKey:@"website"] && ![[NSNull null] isEqual:[userData objectForKey:@"website"]] )
    {
        website = [userData objectForKey:@"website"];
    }
    
    if ( [userData objectForKey:@"bio"] && ![[NSNull null] isEqual:[userData objectForKey:@"bio"]] )
    {
        bio = [userData objectForKey:@"bio"];
    }
    
    if ( [userData objectForKey:@"location_latitude"] && ![[NSNull null] isEqual:[userData objectForKey:@"location_latitude"]] )
    {
        lastStatusLocation_latitude = [userData objectForKey:@"location_latitude"];
        lastStatusLocation_longitude = [userData objectForKey:@"location_longitude"];
    }
    
    if ( [userData objectForKey:@"birthday"] && ![[NSNull null] isEqual:[userData objectForKey:@"birthday"]] )
    {
        birthday = [userData objectForKey:@"birthday"];
    }
    
    if ( [userData objectForKey:@"message"] && ![[NSNull null] isEqual:[userData objectForKey:@"message"]] )
    {
        lastStatus = [userData objectForKey:@"message"];
    }
    
    if ( [userData objectForKey:@"thread_id"] && ![[NSNull null] isEqual:[userData objectForKey:@"thread_id"]] )
    {
        lastStatusID = [NSString stringWithFormat:@"%@", [userData objectForKey:@"thread_id"]];
    }
    
    if ( [userData objectForKey:@"timestamp_sent"] && ![[NSNull null] isEqual:[userData objectForKey:@"timestamp_sent"]] )
    {
        lastStatusTimestamp = [userData objectForKey:@"timestamp_sent"];
    }
    
    if ( [userData objectForKey:@"thread_type"] && ![[NSNull null] isEqual:[userData objectForKey:@"thread_type"]] )
    {
        lastStatusType = [userData objectForKey:@"thread_type"];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:appDelegate.modelManager.databasePath];
        [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            __block NSData *imageData;
            
            if ( DPHash.length > 0 )
            {
                NSURL *DPURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/userphotos/theboard/%@/profile/f_%@.jpg", SH_DOMAIN, userID, DPHash]];
                
                NSURLRequest *request = [NSURLRequest requestWithURL:DPURL];
                [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                    if ( data )
                    {
                        imageData = data;
                    }
                    else // Download failed.
                    {
                        DPHash = @""; // Clear the hash out so the manager attempts to redownload the image on the next launch.
                        
                        imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"user_placeholder"], 1.0);
                    }
                    
                    // Now, we might not need all the data we're inserting here, but it's necessary to make an exact copy
                    // of what any of the other users might look like, or else everything breaks...
                    NSDictionary *argsDict_currentUser = @{@"user_id": userID,
                                                           @"name": name,
                                                           @"alias": alias,
                                                           @"user_handle": userHandle,
                                                           @"dp_hash": DPHash,
                                                           @"dp": imageData,
                                                           @"alias_dp": imageData_alias,
                                                           @"last_status_id": lastStatusID,
                                                           @"email_address": email,
                                                           @"gender": gender,
                                                           @"birthday": birthday,
                                                           @"location_country": location_country,
                                                           @"location_state": location_state,
                                                           @"location_city": location_city,
                                                           @"website": website,
                                                           @"bio": bio,
                                                           @"join_date": joinDate,
                                                           @"view_count": [NSNumber numberWithInt:0],
                                                           @"coordinate_x": [NSNumber numberWithInt:0],
                                                           @"coordinate_y": [NSNumber numberWithInt:0],
                                                           @"rank_score": [NSNumber numberWithFloat:0.0]};
                    
                    [db executeUpdate:@"INSERT INTO sh_current_user "
                                        @"(user_id, name, user_handle, dp_hash, dp, email_address, gender, birthday, location_country, location_state, location_city, website, bio, join_date, last_status_id) "
                                        @"VALUES (:user_id, :name, :user_handle, :dp_hash, :dp, :email_address, :gender, :birthday, :location_country, :location_state, :location_city, :website, :bio, :join_date, :last_status_id)"
                            withParameterDictionary:argsDict_currentUser];
                    
                    [db executeUpdate:@"INSERT INTO sh_cloud "
                                        @"(sh_user_id, name, alias, user_handle, dp_hash, dp, alias_dp, last_status_id, email_address, gender, birthday, location_country, location_state, location_city, website, bio, view_count, coordinate_x, coordinate_y, rank_score) "
                                        @"VALUES (:user_id, :name, :alias, :user_handle, :dp_hash, :dp, :alias_dp, :last_status_id, :email_address, :gender, :birthday, :location_country, :location_state, :location_city, :website, :bio, :view_count, :coordinate_x, :coordinate_y, :rank_score)"
                            withParameterDictionary:argsDict_currentUser];
                    
                    if ( lastStatusID.length > 0 )
                    {
                        // Store the latest status update.
                        NSMutableDictionary *argsDict_status = [[NSDictionary dictionaryWithObjectsAndKeys:lastStatusID, @"thread_id",
                                                                 userID, @"owner_id",
                                                                 lastStatus, @"message",
                                                                 lastStatusType, @"thread_type",
                                                                 lastStatusTimestamp, @"timestamp_sent",
                                                                 lastStatusLocation_latitude, @"location_latitude",
                                                                 lastStatusLocation_longitude, @"location_longitude",
                                                                 lastStatusRootItemID, @"root_item_id",
                                                                 lastStatusMediaType, @"media_type",
                                                                 lastStatusMediaHash, @"media_hash",
                                                                 lastStatusMediaData, @"media_data",
                                                                 lastStatusMediaExtra, @"media_extra", nil] mutableCopy];
                        
                        if ( [lastStatusMediaExtra isKindOfClass:NSDictionary.class] )
                        {
                            NSData *mediaExtraData = [NSJSONSerialization dataWithJSONObject:lastStatusMediaExtra options:NSJSONWritingPrettyPrinted error:nil];
                            [argsDict_status setObject:mediaExtraData forKey:@"media_extra"];
                        }
                        
                        [db executeUpdate:@"INSERT INTO sh_thread "
                         @"(thread_id, thread_type, root_item_id, owner_id, timestamp_sent, message, location_longitude, location_latitude, media_type, media_hash, media_data, media_extra) "
                         @"VALUES (:thread_id, :thread_type, :root_item_id, :owner_id, :timestamp_sent, :message, :location_longitude, :location_latitude, :media_type, :media_hash, :media_data, :media_extra)"
                            withParameterDictionary:argsDict_status];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        [appDelegate refreshCurrentUserData];
                    });
                }];
            }
            else
            {
                imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"user_placeholder"], 1.0);
                
                // Now, we might not need all the data we're inserting here, but it's necessary to make an exact copy
                // of what any of the other users might look like, or else everything breaks...
                NSDictionary *argsDict_currentUser = @{@"user_id": userID,
                                                       @"name": name,
                                                       @"alias": alias,
                                                       @"user_handle": userHandle,
                                                       @"dp_hash": DPHash,
                                                       @"dp": imageData,
                                                       @"alias_dp": imageData_alias,
                                                       @"last_status_id": lastStatusID,
                                                       @"email_address": email,
                                                       @"gender": gender,
                                                       @"birthday": birthday,
                                                       @"location_country": location_country,
                                                       @"location_state": location_state,
                                                       @"location_city": location_city,
                                                       @"website": website,
                                                       @"bio": bio,
                                                       @"join_date": joinDate,
                                                       @"view_count": [NSNumber numberWithInt:0],
                                                       @"coordinate_x": [NSNumber numberWithInt:0],
                                                       @"coordinate_y": [NSNumber numberWithInt:0],
                                                       @"rank_score": [NSNumber numberWithFloat:0.0]};
                
                [db executeUpdate:@"INSERT INTO sh_current_user "
                 @"(user_id, name, user_handle, dp_hash, dp, email_address, gender, birthday, location_country, location_state, location_city, website, bio, join_date, last_status_id) "
                 @"VALUES (:user_id, :name, :user_handle, :dp_hash, :dp, :email_address, :gender, :birthday, :location_country, :location_state, :location_city, :website, :bio, :join_date, :last_status_id)"
                        withParameterDictionary:argsDict_currentUser];
                
                [db executeUpdate:@"INSERT INTO sh_cloud "
                 @"(sh_user_id, name, alias, user_handle, dp_hash, dp, alias_dp, last_status_id, email_address, gender, birthday, location_country, location_state, location_city, website, bio, view_count, coordinate_x, coordinate_y, rank_score) "
                 @"VALUES (:user_id, :name, :alias, :user_handle, :dp_hash, :dp, :alias_dp, :last_status_id, :email_address, :gender, :birthday, :location_country, :location_state, :location_city, :website, :bio, :view_count, :coordinate_x, :coordinate_y, :rank_score)"
                        withParameterDictionary:argsDict_currentUser];
                
                if ( lastStatusID.length > 0 )
                {
                    // Store the latest status update.
                    NSMutableDictionary *argsDict_status = [[NSDictionary dictionaryWithObjectsAndKeys:lastStatusID, @"thread_id",
                                                             userID, @"owner_id",
                                                             lastStatus, @"message",
                                                             lastStatusType, @"thread_type",
                                                             lastStatusTimestamp, @"timestamp_sent",
                                                             lastStatusLocation_latitude, @"location_latitude",
                                                             lastStatusLocation_longitude, @"location_longitude",
                                                             lastStatusRootItemID, @"root_item_id",
                                                             lastStatusMediaType, @"media_type",
                                                             lastStatusMediaHash, @"media_hash",
                                                             lastStatusMediaData, @"media_data",
                                                             lastStatusMediaExtra, @"media_extra", nil] mutableCopy];
                    
                    NSData *mediaExtraData = [NSJSONSerialization dataWithJSONObject:lastStatusMediaExtra options:NSJSONWritingPrettyPrinted error:nil];
                    [argsDict_status setObject:mediaExtraData forKey:@"media_extra"];
                    
                    [db executeUpdate:@"INSERT INTO sh_thread "
                     @"(thread_id, thread_type, root_item_id, owner_id, message, location_longitude, location_latitude, media_type, media_hash, media_data, media_extra) "
                     @"VALUES (:thread_id, :thread_type, :root_item_id, :owner_id, :message, :location_longitude, :location_latitude, :media_type, :media_hash, :media_data, :media_extra)"
                        withParameterDictionary:argsDict_status];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [appDelegate refreshCurrentUserData];
                });
            }
        }];
    });
}

- (NSMutableDictionary *)refreshCurrentUserData
{
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    
    NSString *accessToken = [appDelegate.credsKeychainItem objectForKey:(__bridge id)(kSecValueData)];
    NSString *accessTokenID = [[NSUserDefaults standardUserDefaults] stringForKey:@"SHSilphScope"];
    
    FMResultSet *s1 = [self executeQuery:@"SELECT * FROM sh_current_user"
                 withParameterDictionary:nil];
    
    // Read & store current user's data.
    while ( [s1 next] )
    {
        NSString *userID = [NSString stringWithFormat:@"%@", [s1 stringForColumn:@"user_id"]];
        NSString *userHandle = [s1 stringForColumn:@"user_handle"];
        NSString *alias = @"";
        NSString *DPHash = [s1 stringForColumn:@"dp_hash"];
        NSData *DP = [s1 dataForColumn:@"dp"];
        NSString *aliasDP = @"";
        NSString *emailAddress = [s1 stringForColumn:@"email_address"];
        NSString *gender = [s1 stringForColumn:@"gender"];
        NSString *birthday = [s1 stringForColumn:@"birthday"];
        NSString *location_country = [s1 stringForColumn:@"location_country"];
        NSString *location_state = [s1 stringForColumn:@"location_state"];
        NSString *location_city = [s1 stringForColumn:@"location_city"];
        NSString *website = [s1 stringForColumn:@"website"];
        NSString *bio = [s1 stringForColumn:@"bio"];
        NSString *lastStatusID = [s1 stringForColumn:@"last_status_id"];
        NSString *magicRunDate = [s1 stringForColumn:@"last_magic_run"];
        NSString *lastLocationCheck = [s1 stringForColumn:@"last_location_check"];
        NSString *lastMiniFeedRefresh = [s1 stringForColumn:@"last_mini_feed_refresh"];
        
        if ( !DPHash || DPHash.length == 0 )
        {
            DPHash = @"";
            DP = UIImageJPEGRepresentation([UIImage imageNamed:@"user_placeholder"], 1.0);
        }
        
        if ( !userHandle )
        {
            userHandle = @"";
        }
        
        if ( !emailAddress )
        {
            emailAddress = @"";
        }
        
        if ( !gender )
        {
            gender = @"";
        }
        
        if ( !birthday )
        {
            birthday = @"";
        }
        
        if ( !location_country )
        {
            location_country = @"";
        }
        
        if ( !location_state )
        {
            location_state = @"";
        }
        
        if ( !location_city )
        {
            location_city = @"";
        }
        
        if ( !website )
        {
            website = @"";
        }
        
        if ( !bio )
        {
            bio = @"";
        }
        
        if ( !lastStatusID )
        {
            lastStatusID = @"";
        }
        
        if ( !lastStatusID )
        {
            lastStatusID = @"";
        }
        
        if ( !magicRunDate )
        {
            magicRunDate = @"";
        }
        
        if ( !lastLocationCheck )
        {
            lastLocationCheck = @"";
        }
        
        if ( !lastMiniFeedRefresh )
        {
            lastMiniFeedRefresh = @"";
        }
        
        if ( accessToken )
        {
            [data setObject:accessToken forKey:@"access_token"];
        }
        
        if ( accessTokenID )
        {
            [data setObject:accessTokenID forKey:@"access_token_id"];
        }
        
        [data setObject:userID forKey:@"user_id"];
        [data setObject:[s1 stringForColumn:@"name"] forKey:@"name"];
        [data setObject:userHandle forKey:@"user_handle"];
        [data setObject:alias forKey:@"alias"];
        [data setObject:DPHash forKey:@"dp_hash"];
        [data setObject:DP forKey:@"dp"];
        [data setObject:aliasDP forKey:@"alias_dp"];
        [data setObject:emailAddress forKey:@"email_address"];
        [data setObject:gender forKey:@"gender"];
        [data setObject:birthday forKey:@"birthday"];
        [data setObject:location_country forKey:@"location_country"];
        [data setObject:location_state forKey:@"location_state"];
        [data setObject:location_city forKey:@"location_city"];
        [data setObject:website forKey:@"website"];
        [data setObject:bio forKey:@"bio"];
        [data setObject:[s1 stringForColumn:@"join_date"] forKey:@"join_date"];
        [data setObject:lastStatusID forKey:@"last_status_id"];
        [data setObject:magicRunDate forKey:@"last_magic_run"];
        [data setObject:lastLocationCheck forKey:@"last_location_check"];
        [data setObject:lastMiniFeedRefresh forKey:@"last_mini_feed_refresh"];
    }
    
    [s1 close]; // Very important that you close this!
    
    if ( data.count > 0 )
    {
        FMResultSet *s2 = [self executeQuery:@"SELECT message FROM sh_thread WHERE thread_id = :last_status_id"
                     withParameterDictionary:@{@"last_status_id": [data objectForKey:@"last_status_id"]}];
        
        while ( [s2 next] )
        {
            [data setObject:[s2 stringForColumn:@"message"] forKey:@"message"];
        }
        
        [s2 close];
    }
    
    [_results close];
    [_DB close];
    
    return data;
}

@end
