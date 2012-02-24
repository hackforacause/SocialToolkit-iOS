//
//  SampleLaunchViewController.h
//  SocialToolkit
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"

@interface SampleLaunchViewController : UIViewController <FBSessionDelegate> {
    UIButton *launchFbBtn;
    FBRequest *currentRequest_;
}

@property (strong, nonatomic) FBRequest *currentRequest;
@property (strong, nonatomic) UIButton *launchFbBtn;

@end
