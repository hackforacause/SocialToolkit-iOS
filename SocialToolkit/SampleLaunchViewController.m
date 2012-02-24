//
//  SampleLaunchViewController.m
//  SocialToolkit
//

#import "SampleLaunchViewController.h"
#import "FBConnect.h"
#import "AppDelegate.h"

@interface SampleLaunchViewController (private)
- (void)getFBFriends;
- (void)loginAndGetFriends:(id)sender;
@end

@implementation SampleLaunchViewController

@synthesize launchFbBtn, currentRequest = currentRequest_;

- (id)init {
    self = [super init];
    if (self) {
        self.title = @"Sample Screen";   
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    launchFbBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-120, self.view.frame.size.height-100, 120, 50)];
    [launchFbBtn addTarget:self action:@selector(loginAndGetFriends:) forControlEvents:UIControlEventTouchUpInside];
    [launchFbBtn setTitle:@"Login" forState:UIControlStateNormal];
    [self.view addSubview:launchFbBtn];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loginAndGetFriends {
    Facebook *fb = [((AppDelegate*)[[UIApplication sharedApplication] delegate]) fbInstance];
    
    // Check if we're currently signed in
    if ( ![fb isSessionValid] ) {
        [fb authorize:nil]; // Basic permissions
    } else {
        [self getFBFriends];
    }
}

// Retrieve friend list
- (void)getFBFriends {
    Facebook *fb = [((AppDelegate*)[[UIApplication sharedApplication] delegate]) fbInstance];
    self.currentRequest = [fb requestWithGraphPath:@"me/friends" andDelegate:self];
}

#pragma mark FBSessionDelegate

- (void)fbDidLogin {
    Facebook *fb = [((AppDelegate*)[[UIApplication sharedApplication] delegate]) fbInstance];
    
    // Save access token/expiry
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[fb accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[fb expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
}

// TODO Logout. Add a button and allow a user to logout.
- (void)fbDidLogout {
    
}

// What if the user decides not to login?
- (void)fbDidNotLogin:(BOOL)cancelled {
    
}

@end
