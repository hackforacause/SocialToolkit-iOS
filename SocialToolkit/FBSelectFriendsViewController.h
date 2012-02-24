#import <UIKit/UIKit.h>
#import "FBConnect.h"

@interface FBSelectFriendsViewController : UIViewController <FBSessionDelegate, FBRequestDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource> {
    NSArray *fbFriends_;
    NSArray *fbFriendsFiltered_;
    NSMutableArray *fbFriendsInvited_;
    UITableView *tableView_;
    FBRequest *currentRequest_;
}

- (id)initWithFriends:(NSArray*)selectedFriends;

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *fbFriends;
@property (strong, nonatomic) NSArray *fbFriendsFiltered;
@property (strong, nonatomic) NSMutableArray *fbFriendsInvited;
@property (strong, nonatomic) FBRequest *currentRequest;

@end
