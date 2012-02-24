#import "FBSelectFriendsViewController.h"
#import "AppDelegate.h"
#import "FacebookFriend.h"

/* FBSelectFriendsViewController 
 *
 * Best used as a modal view controller. 
 *
 * Select and pass a list of FacebookFriends to a listening controller.
 *
 */

#define kSelectionLimit 5

@interface FBSelectFriendsViewController (private) 
- (void)dismiss;
- (BOOL)invitedHas:(NSString*)id;
@end

@implementation FBSelectFriendsViewController

@synthesize tableView = tableView_, fbFriends = fbFriends_, fbFriendsFiltered = fbFriendsFiltered_, fbFriendsInvited = fbFriendsInvited_, currentRequest = currentRequest_;

- (id)init
{
    self = [super init];
    if (self) {
        self.title = [NSString stringWithFormat:@"Select %d Friends", kSelectionLimit];
    }
    return self;
}

- (id)initWithFriends:(NSArray*)selectedFriends {
    self.fbFriendsInvited = [NSMutableArray arrayWithArray:selectedFriends];
    return [self init];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = nil;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, self.view.frame.size.height-90) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    searchBar.barStyle = UIBarStyleBlack;
    searchBar.backgroundColor = [UIColor blackColor];
    searchBar.placeholder = @"Search friends";
    searchBar.delegate = self;
    [self.view addSubview:searchBar];
    
    Facebook *fb = [((AppDelegate*)[[UIApplication sharedApplication] delegate]) fbInstance];
    fb.sessionDelegate = self;
    
    // Check if we already have an access token (user is signed in with FB app itself)
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        fb.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        fb.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    
    
    if ( ![fb isSessionValid] ) {
        [fb authorize:nil];
    } else {
        Facebook *fb = [((AppDelegate*)[[UIApplication sharedApplication] delegate]) fbInstance];
        self.currentRequest = [fb requestWithGraphPath:@"me/friends" andDelegate:self];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ( !fbFriendsFiltered_ ) {
        fbFriendsInvited_ = [[NSMutableArray alloc] init];
    }
}

#pragma mark FBRequestDelegate

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Facebook request for friends failed. %@", [error userInfo]);
}

- (void)request:(FBRequest *)request didLoad:(id)result {
    self.fbFriends = [FacebookFriend createFacebookFriends:result];
    self.fbFriendsFiltered = self.fbFriends;
    [self.tableView reloadData];
}

- (void)request:(FBRequest *)request didLoadRawResponse:(NSData *)data {
   
}

- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
   
}

#pragma mark UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if ( [searchText isEqualToString:@""] ) {
        self.fbFriendsFiltered = self.fbFriends;
        return;
    }
    
    self.fbFriendsFiltered = [self.fbFriends filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        NSString *name = ((FacebookFriend*)evaluatedObject).name;
        if ([name rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound) {
            return YES;
        }
        return NO;
    }]];
    
    [searchBar setShowsCancelButton:YES animated:YES];
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.fbFriendsFiltered = self.fbFriends;
    [self.tableView reloadData];
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.currentRequest.delegate = nil;
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.fbFriendsFiltered count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If it's the same name, then the accessory view follows the table position, and is incorrect for 
    // a specific cell
    NSString *CellIdentifier = ((FacebookFriend*)[self.fbFriendsFiltered objectAtIndex:indexPath.row]).fid;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    FacebookFriend *friend = [self.fbFriendsFiltered objectAtIndex:indexPath.row];
    
    if ( [self invitedHas:((FacebookFriend*)[self.fbFriendsFiltered objectAtIndex:indexPath.row]).fid] ) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    cell.textLabel.text = friend.name;
        
    return cell;
}

- (BOOL)invitedHas:(NSString*)id {
    for ( FacebookFriend *f in self.fbFriendsInvited ) {
        if ( [f.fid isEqualToString:id] ) {
            return YES;
        }
    }
    return NO;
}

          
#pragma mark private

- (void)dismiss {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"fbFriendsInvited" object:self];
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
    
    FacebookFriend *friend = [self.fbFriendsFiltered objectAtIndex:indexPath.row];
    
    // Build list to invite
    if ( [self.fbFriendsInvited containsObject:friend] ) {
        [self.fbFriendsInvited removeObject:friend];
        [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryNone];
    } else {
        if ( [self.fbFriendsInvited count] >= kSelectionLimit )
            return;
            
        [self.fbFriendsInvited addObject:friend];
        [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
}

#pragma mark FBSessionDelegate

- (void)fbDidLogin {
    Facebook *fb = [((AppDelegate*)[[UIApplication sharedApplication] delegate]) fbInstance];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[fb accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[fb expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    self.currentRequest = [fb requestWithGraphPath:@"me/friends" andDelegate:self];
}

@end
