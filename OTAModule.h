#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>


@class OTAModule;
@protocol OTAModuleDelegate 

// define protocol functions that can be used in any class using this delegate
-(UIScrollView *)chooserView;

@end

@interface OTAModule : UIView {

}
NSString *moduleTitle;
NSString *moduleBundleID;
NSString *version;
NSString *url;
NSString *password;
NSString *plistName;
NSMutableDictionary *moduleInfo;
NSString *executable;
NSString *developer;
UITextField *passwordBar;
//NSAutoreleasePool *pool;

UIScrollView *chooser;
UIScrollView *mainView;
UIView *chooserShadow;
UIButton *chooserButton;
UILabel *loadingLabel;
UIActivityIndicatorView *loadingIndicator;
UIView *headerView;
UIView *moduleLoader;

@property (nonatomic, assign) id  delegate;
@property (nonatomic,retain) NSString *moduleTitle;
@property (nonatomic,retain) NSString *moduleBundleID;
@property (nonatomic,retain) NSString *version;
@property (nonatomic,retain) NSString *url;
@property (nonatomic,retain) NSString *password;
@property (nonatomic,retain) NSString *plistName;
@property (nonatomic,retain) NSString *executable;
@property (nonatomic,retain) NSString *developer;
@property (nonatomic,retain) NSMutableDictionary *moduleInfo;

-(void)baseInit;



@end

