//
//  AppDelegate.h
//  SocialToolkit
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"
#import "SampleLaunchViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    UIWindow *window_;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) Facebook *fbInstance;

@end
