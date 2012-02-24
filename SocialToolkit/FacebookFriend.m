//
//  FacebookFriend.m
//  SocialToolkit
//

#import "FacebookFriend.h"

@implementation FacebookFriend

@synthesize name = name_, fid = fid_;

// Instantiate a FacebookFriend
- (id)initWithDictionary:(NSDictionary*)dictionary {
    if ( (self = [super init]) ) {
        self.name = [dictionary objectForKey:@"name"];
        self.fid = [dictionary objectForKey:@"id"];
        
        if ( [self.name isEqualToString:@""] || [self.fid isEqualToString:@""] ) {
            NSLog(@"FacebookFriend: creation has empty strings. Is this really a true friend?");
        }
        
    }
    return self;
}

// Returns a dictionary compatible with Facebook Graph API
// Used for transmitting friend information
- (NSDictionary*)getDictionary {
    return [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:name_, fid_, nil] forKeys:[NSArray arrayWithObjects:@"name", @"id", nil]];
}

// Static: Create FacebookFriend objects given a dictionary of friends
+ (NSArray*)createFacebookFriends:(NSDictionary*)withData {
    NSMutableArray *friends = [[NSMutableArray alloc] init];
    NSArray *fData = [withData objectForKey:@"data"];
    
    for ( NSDictionary *f in fData ) {
        [friends addObject:[[FacebookFriend alloc] initWithDictionary:f]];
    }
    
    return friends;
}

@end
