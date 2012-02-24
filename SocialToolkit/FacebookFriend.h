//
//  FacebookFriend.h
//  SocialToolkit
//

#import <Foundation/Foundation.h>

@interface FacebookFriend : NSObject {
    NSString *name_, *fid_;
}

- (id)initWithDictionary:(NSDictionary*)dictionary;
- (NSDictionary*)getDictionary;

+ (NSArray*)createFacebookFriends:(NSDictionary*)withData;

@property (strong, nonatomic) NSString *name, *fid;

@end
