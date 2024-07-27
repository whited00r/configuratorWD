#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>


@class ADVCell;
@protocol ADVCellDelegate 

// define protocol functions that can be used in any class using this delegate
-(UIScrollView *)chooserView;

@end

@interface ADVCell : UIView {

}
NSString *title;
NSString *bundleID;
NSString *key;
NSString *altText;
NSString *cellType;
NSString *subText;
NSString *action;
NSString *defaultValue;
NSArray *titles;
NSArray *values;
UILabel *defaultTitle;
NSString *textColor;
NSString *cellBackgroundColor;
NSString *popupText;
NSString *script;
BOOL enabled;
BOOL isBold;
BOOL localize;
//NSAutoreleasePool *pool;

@property (nonatomic, assign) id  delegate;
@property (nonatomic,retain) NSString *title;
@property (nonatomic,retain) NSString *bundleID;
@property (nonatomic,retain) NSString *key;
@property (nonatomic,retain) NSString *altText;
@property (nonatomic,retain) NSString *cellType;
@property (nonatomic,retain) NSString *subText;
@property (nonatomic,retain) NSString *action;
@property (nonatomic,retain) NSString *defaultValue;
@property (nonatomic,retain) NSString *textColor;
@property (nonatomic,retain) NSString *script;
@property (nonatomic,retain) NSString *cellBackgroundColor;
@property (nonatomic,retain) NSString *popupText;
@property (nonatomic,retain) NSArray *titles;
@property (nonatomic,retain) NSArray *values;
@property (nonatomic,assign) BOOL enabled;
@property (nonatomic,assign) BOOL isBold;
@property (nonatomic,assign) BOOL localize;
-(void)baseInit;
-(NSString *)localize:(NSString *)text forBundle:(NSString*)bundle;


@end

