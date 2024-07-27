#import <Preferences/Preferences.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ADVCell.h"
#import "OTAModule.h"
#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <Foundation/NSTask.h>
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>

@interface ConfiguratorListController: PSListController {
UILabel *workingLabel;
UILabel *warningLabel;
UILabel *activateText;
UILabel *activateDesc;
UIButton *applyButton;
UIButton *cancelButton;
UIButton *acceptButton;
UIView *activateView;
UIWindow *containerWindow;
UIScrollView *chooser;
UIScrollView *mainView;
UIView *chooserShadow;
UIButton *chooserButton;
UILabel *loadingLabel;
UIActivityIndicatorView *loadingIndicator;
UIScrollView *moduleList;
UIView *keyboardView;
BOOL showingAddModule;
UIImageView *loadingUnderlay;
UIView *loadingView;
UIView *mainLoadingView;
NSMutableDictionary *categories;
}
@end
static BOOL isWhited00r = FALSE;
extern "C" void UIKeyboardEnableAutomaticAppearance();
@implementation ConfiguratorListController


- (id)specifiers {
showingAddModule = FALSE;

if(!mainView){

	//NSLog(@"Loading stuff upppppp");
 UIKeyboardEnableAutomaticAppearance();
[self performSelectorInBackground:@selector(showLoadingView) withObject:nil];
[self performSelectorInBackground:@selector(loadEverything) withObject:nil];
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
NSFileManager *fMgr = [NSFileManager defaultManager]; 
if (![fMgr fileExistsAtPath:[NSString stringWithFormat:@"/var/mobile/Whited00r/resources/Configurator/info.plist"]]) { 
system("plutil -create /var/mobile/Whited00r/resources/Configurator/info.plist");
system("plutil -key model -value `uname -i` /var/mobile/Whited00r/resources/Configurator/info.plist");
}
//NSLog(@"Loaded stuff upppp");




NSString *firstLevel = [NSString stringWithFormat:@"%@-CantCrackDis",[[UIDevice currentDevice] uniqueIdentifier]];
NSString *arguments = [NSString stringWithFormat:@"echo %@ | openssl dgst -sha1 -hmac \"PlsNo\"", firstLevel];
NSPipe *resultPipe = [[NSPipe alloc] init];
NSTask *taskCrypt = [[NSTask alloc] init];
NSArray *argsCrypt = [NSArray arrayWithObjects:@"-c", arguments, nil];
[taskCrypt setStandardOutput:resultPipe];

[taskCrypt setLaunchPath:@"/bin/bash"];
[taskCrypt setArguments:argsCrypt];
[taskCrypt launch];    // Run
[taskCrypt waitUntilExit]; // Wait
NSData *result = [[resultPipe fileHandleForReading] readDataToEndOfFile];
NSString *licenseKey = [[NSString alloc] initWithData: result
                               encoding: NSUTF8StringEncoding];

licenseKey = [licenseKey substringToIndex:[licenseKey length] - 1];

NSString *magicFilePath = [NSString stringWithFormat:@"/var/mobile/Whited00r/%@", licenseKey];
//NSLog(magicFilePath);

if ([fMgr fileExistsAtPath:magicFilePath] && [fMgr fileExistsAtPath:@"/var/lib/dpkg/info/com.whited00r.whited00r.list"]) { 
//NSLog(@"LicenceKey isWhited00r: /var/mobile/Whited00r/%@", licenseKey);

isWhited00r = TRUE;
}
[taskCrypt release];
//[result release];
//[licenseKey release];
[resultPipe release];


[pool drain];
}

//if(_specifiers == nil) {
	//	_specifiers = [[self loadSpecifiersFromPlistName:@"Bob" target:self] retain];

//}
	//return _specifiers;


}


-(NSString *)localize:(NSString *)text forBundle:(NSString*)bundle{

NSFileManager *fMgr = [NSFileManager defaultManager]; 
NSMutableDictionary *langDict;
if(!bundle){
if (![fMgr fileExistsAtPath:[NSString stringWithFormat:@"/System/Library/PreferenceBundles/Configurator.bundle/%@.lproj/Configurator.strings", [[NSLocale preferredLanguages] objectAtIndex:0]]]) { 
langDict = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"/System/Library/PreferenceBundles/Configurator.bundle/en.lproj/Configurator.strings"]];

}
else{
langDict = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"/System/Library/PreferenceBundles/Configurator.bundle/%@.lproj/Configurator.strings", [[NSLocale preferredLanguages] objectAtIndex:0]]];

}
if([langDict objectForKey:text]){

return [langDict objectForKey:text];
}
else{
return text;
}
}
else{
if (![fMgr fileExistsAtPath:[NSString stringWithFormat:@"/var/mobile/Library/Configurator/%@/%@.lproj/Cells.strings", bundle, [[NSLocale preferredLanguages] objectAtIndex:0]]]) { 
return text;

}
else{
langDict = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Library/Configurator/%@/%@.lproj/Cells.strings", bundle, [[NSLocale preferredLanguages] objectAtIndex:0]]];

}
if([langDict objectForKey:text]){

return [langDict objectForKey:text];
}
else{
return text;
}
}
}


-(void)showLoadingView{
mainView.hidden = TRUE;
if(!mainLoadingView){
    mainLoadingView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,430)];
    [self.view addSubview:mainLoadingView];
  
    [mainLoadingView release];

loadingLabel = [[UILabel alloc] init];
loadingLabel.textAlignment = UITextAlignmentCenter;
loadingLabel.font = [UIFont boldSystemFontOfSize:12];
loadingLabel.frame=CGRectMake(0, 180, 320, 40);
loadingLabel.backgroundColor = [UIColor clearColor];
loadingLabel.text = @"Initializing...";
loadingLabel.textColor = [UIColor blackColor];

UIImageView * wdLogo = [[UIImageView alloc] initWithFrame:CGRectMake(100,40,120,130)];
wdLogo.image = [UIImage imageWithContentsOfFile:@"/var/mobile/Whited00r/resources/Configurator/WDLogo.png"];
[mainLoadingView addSubview:wdLogo];
[wdLogo release];


[mainLoadingView addSubview:loadingLabel];
[loadingLabel release];

}
loadingIndicator = nil;
loadingIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    loadingIndicator.frame = CGRectMake(145, 225, 30, 30);
[loadingIndicator startAnimating];
    [mainLoadingView addSubview:loadingIndicator];
mainLoadingView.hidden = FALSE;
}

-(void)hideLoadingView{
mainView.hidden = FALSE;
mainLoadingView.hidden = TRUE;
[loadingIndicator removeFromSuperview];
[loadingLabel removeFromSuperview];
[loadingIndicator release];

}


-(void)firstAnimationLoop{

    [UIView beginAnimations:@"First" context:nil];
    [UIView setAnimationDuration:2.0f];
[UIView setAnimationDelegate:self];
[UIView setAnimationDidStopSelector:@selector(secondAnimationLoop)];
loadingUnderlay.frame = CGRectMake(260,235,60,20);
//loadingUnderlay.center = CGPointMake(loadingUnderlay.center.x, loadingUnderlay.center.y);
loadingUnderlay.transform = CGAffineTransformMakeRotation(M_PI * 1.0);
    [UIView commitAnimations];

}

-(void)secondAnimationLoop{

    [UIView beginAnimations:@"Second" context:nil];
    [UIView setAnimationDuration:2.0f];
[UIView setAnimationDelegate:self];
[UIView setAnimationDidStopSelector:@selector(firstAnimationLoop)];
loadingUnderlay.frame = CGRectMake(0,235,60,20);

//loadingUnderlay.center = CGPointMake(loadingUnderlay.center.x, loadingUnderlay.center.y);
loadingUnderlay.transform = CGAffineTransformMakeRotation(M_PI * 2.0);
    [UIView commitAnimations];

}


-(ADVCell *)cellForDict:(NSMutableDictionary *)dict height:(float)height{
ADVCell *cell = [[ADVCell alloc] initWithFrame:CGRectMake(0,height, 320, 50)];

if([dict objectForKey:@"label"]){
//NSLog(@"Found label: %@", [dict objectForKey:@"label"]);
cell.title = [dict objectForKey:@"label"];
}
if([dict objectForKey:@"defaults"]){
//NSLog(@"Found defaults: %@", [dict objectForKey:@"defaults"]);
cell.bundleID = [dict objectForKey:@"defaults"];

}
//NSLog(@"Setting cell type...");
cell.cellType = [dict objectForKey:@"cell"];
if(![dict objectForKey:@"default"] == nil){

cell.enabled = [[dict objectForKey:@"default"] boolValue];

}

if([dict objectForKey:@"key"]){
cell.key = [dict objectForKey:@"key"];

}

if([dict objectForKey:@"popupText"]){
cell.popupText = [dict objectForKey:@"popupText"];

}

if([dict objectForKey:@"textColor"]){
cell.textColor = [dict objectForKey:@"textColor"];

}

if([dict objectForKey:@"cellBackgroundColor"]){
cell.cellBackgroundColor = [dict objectForKey:@"cellBackgroundColor"];

}

if(![dict objectForKey:@"bold"] == nil){
cell.isBold = [[dict objectForKey:@"bold"] boolValue];

}

if(![dict objectForKey:@"localize"] == nil){
cell.localize = [[dict objectForKey:@"localize"] boolValue];

}

if([dict objectForKey:@"action"]){
cell.action = [dict objectForKey:@"action"];

}

if([dict objectForKey:@"script"]){
cell.script = [dict objectForKey:@"script"];

}

if([[dict objectForKey:@"cell"] isEqualToString:@"PSLinkListCell"]){
cell.titles = [dict objectForKey:@"validTitles"];
cell.values = [dict objectForKey:@"validValues"];
}
cell.delegate = self;
[cell baseInit];
return cell;

}

-(void)loadEverything{
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
//NSLog(@"Loading up the configurator plist");
NSMutableDictionary *mainPlist = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/System/Library/PreferenceBundles/Configurator.bundle/Configurator.plist"];
//NSLog(@"Got the items...");
NSArray *items = [mainPlist objectForKey:@"items"];
mainView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0,320,430)];
mainView.contentSize = CGSizeMake(320,0);
mainView.pagingEnabled = TRUE;
UILabel *popupLabel = [[UILabel alloc] init];
popupLabel.textAlignment = UITextAlignmentCenter;
popupLabel.font = [UIFont boldSystemFontOfSize:12];
popupLabel.frame=CGRectMake(5, 180, 310, 40);
popupLabel.backgroundColor = [UIColor clearColor];
popupLabel.text = [self localize:@"TAP_FOR_INFO" forBundle:nil];
popupLabel.textColor = [UIColor blackColor];
popupLabel.numberOfLines = 0;
popupLabel.lineBreakMode = UILineBreakModeWordWrap;
[popupLabel sizeToFit];


categories = [[NSMutableDictionary alloc] init];
NSMutableArray *categoryNames = [[NSMutableArray alloc] init];
UIScrollView *welcomeView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0,320,430)];
[welcomeView addSubview:popupLabel];

UIImageView * wdLogo = [[UIImageView alloc] initWithFrame:CGRectMake(100,30,120,130)];
wdLogo.image = [UIImage imageWithContentsOfFile:@"/var/mobile/Whited00r/resources/Configurator/WDLogo.png"];
[welcomeView addSubview:wdLogo];
[wdLogo release];

UILabel *instructionLabel = [[UILabel alloc] init];
instructionLabel.textAlignment = UITextAlignmentCenter;
instructionLabel.font = [UIFont boldSystemFontOfSize:14];
instructionLabel.frame = CGRectMake(5, 210, 310, 40);
instructionLabel.backgroundColor = [UIColor clearColor];
instructionLabel.text = [self localize:@"INSTRUCTION_LABEL" forBundle:nil];
instructionLabel.textColor = [UIColor blackColor];
instructionLabel.numberOfLines = 0;
instructionLabel.lineBreakMode = UILineBreakModeWordWrap;
[instructionLabel sizeToFit];

[welcomeView addSubview:instructionLabel];

[categories setObject:welcomeView forKey:@"welcomeView"];
[mainView addSubview:welcomeView];

//int height = popupLabel.frame.size.height + 20;
[popupLabel release];

/*
For creating dynamic stuff, add to "items" array more objects from /var/mobile/Library/Configurator/BundleName/MainPlist.plist

*/

NSFileManager *fMgr = [NSFileManager defaultManager]; 

if ([fMgr fileExistsAtPath:@"/var/mobile/Library/Configurator/"]) { 


for(NSString *bundle in [fMgr contentsOfDirectoryAtPath:@"/var/mobile/Library/Configurator" error:nil]){
if([fMgr fileExistsAtPath:[NSString stringWithFormat:@"/var/mobile/Library/Configurator/%@/Cells.plist", bundle]]){	
NSDictionary *infoDict = [[NSDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Library/Configurator/%@/Cells.plist", bundle]];
if([infoDict objectForKey:@"items"]){
for(NSDictionary *dict in [infoDict objectForKey:@"items"]){
	[items addObject:dict];
}
}
else{
	UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"Configurator Module Error"
                             message: [NSString stringWithFormat:@"Module %@ does not have any items!", bundle]
                             delegate: self
                             cancelButtonTitle: @"Okay"
                             otherButtonTitles: nil];
    [alert show];
    [alert release];
}
}
}
}

//Cheaty cheaty cheaty method for subcategory grouping. Ugly, but it works.
NSArray *items2 = [items copy]; //So that we can modify the original plist
NSMutableArray *movedObjects = [[NSMutableArray alloc] init]; //To keep track of the objects that were reorganized to stop infinite looping or something (not likely to happen, but better safe than sorry)
for(NSDictionary *dict in items2){
//Looping through all the items
if([dict valueForKey:@"section"]){
//It found the key for section! Now to loop through again and find it a friend.
    for(NSDictionary *dict2 in items2){
        //Looping through the second time.
        if([dict2 valueForKey:@"section"]){
            //Oh look we found something else that contains the key section. 
            if([[dict2 valueForKey:@"section"] isEqualToString:[dict valueForKey:@"section"]]){
                //We found a matching section, time to make sure it wasn't making a friend with itself.
                if(![dict2 isEqual:dict] && ![movedObjects containsObject:dict2]){
                    //It hasn't been touched yet, and it's not itself! It found a friend :)
                    [items removeObjectAtIndex:[items indexOfObject:dict2]];
                    [items insertObject:dict2 atIndex:[items indexOfObject:dict] + 1];
                    [movedObjects addObject:dict2];
                    [movedObjects addObject:dict];
                }
            }
        }
    }
}

}
[movedObjects release];


for(NSDictionary *dict in items){
//NSLog(@"Loading up items...");
BOOL shouldAdd = TRUE;
if([dict objectForKey:@"requiredCapabilities"]){
for(NSString *required in [dict objectForKey:@"requiredCapabilities"]){
NSDictionary *infoPlist = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Whited00r/resources/Configurator/info.plist"];


NSMutableDictionary *sysPlist = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"/System/Library/CoreServices/SpringBoard.app/%@.plist", [infoPlist objectForKey:@"model"]]];
NSMutableDictionary *capabilities = [sysPlist objectForKey:@"capabilities"];
if([capabilities objectForKey:required]){
if(shouldAdd){
shouldAdd = TRUE;
}
if(![[capabilities objectForKey:required] boolValue]){
shouldAdd = FALSE;
}

}
if(![capabilities objectForKey:required]){

shouldAdd = FALSE;
}
}

}

if([dict objectForKey:@"reverseCapabilities"]){
for(NSString *required in [dict objectForKey:@"reverseCapabilities"]){
NSDictionary *infoPlist = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Whited00r/resources/Configurator/info.plist"];


NSMutableDictionary *sysPlist = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"/System/Library/CoreServices/SpringBoard.app/%@.plist", [infoPlist objectForKey:@"model"]]];
NSMutableDictionary *capabilities = [sysPlist objectForKey:@"capabilities"];
if([capabilities objectForKey:required]){
shouldAdd = FALSE;
if(![[capabilities objectForKey:required] boolValue]){
if(shouldAdd){
shouldAdd = TRUE;
}
}
}
if(![capabilities objectForKey:required]){
if(shouldAdd){
shouldAdd = TRUE;
}
}

}

}






if(shouldAdd){
    UIScrollView *categoryView = nil;
    if([dict objectForKey:@"category"]){
    if([categories objectForKey:[dict objectForKey:@"category"]]){
        categoryView = [categories objectForKey:[dict objectForKey:@"category"]];
    }
    else{
        categoryView = [[UIScrollView alloc] initWithFrame:CGRectMake([categories count] * 320, 0, 320, 430)];
        [mainView addSubview:categoryView];
        [categories setObject:categoryView forKey:[dict objectForKey:@"category"]];
        [categoryNames addObject:[dict objectForKey:@"category"]];
        mainView.contentSize = CGSizeMake([categories count] * 320, 430);
        [categoryView release];

        NSMutableDictionary *applyDict = [[NSMutableDictionary alloc] init];
        [applyDict setObject:@"PSButtonCell" forKey:@"cell"];
        [applyDict setObject:@"APPLY_LABEL" forKey:@"label"];
        [applyDict setObject:@"applyChanges" forKey:@"action"];
        [applyDict setObject:[NSNumber numberWithInt:1] forKey:@"alignment"];
        [applyDict setObject:@"whiteColor" forKey:@"cellBackgroundColor"];
        [applyDict setObject:@"orangeColor" forKey:@"textColor"];
        [applyDict setObject:[NSNumber numberWithBool:TRUE] forKey:@"bold"];
		ADVCell *applyCell = [self cellForDict:applyDict height:categoryView.contentSize.height];
		[categoryView addSubview:applyCell];
		categoryView.contentSize = CGSizeMake(320, categoryView.contentSize.height + applyCell.frame.size.height);
		[applyCell release];
		[applyDict release];

		NSMutableDictionary *spaceDict = [[NSMutableDictionary alloc] init];
        [spaceDict setObject:@"PSGroupCell" forKey:@"cell"];
        [spaceDict setObject:@"" forKey:@"label"];
        [spaceDict setObject:@"clearColor" forKey:@"cellBackgroundColor"];
		ADVCell *spaceCell = [self cellForDict:spaceDict height:categoryView.contentSize.height];
		[categoryView addSubview:spaceCell];
		categoryView.contentSize = CGSizeMake(320, categoryView.contentSize.height + spaceCell.frame.size.height);
		[spaceCell release];
		[spaceDict release];
    }
    }
    int height = categoryView.contentSize.height;
ADVCell *cell = [self cellForDict:dict height:height]; //Smart. Very smart. :)

[categoryView addSubview:cell];
categoryView.contentSize = CGSizeMake(320, categoryView.contentSize.height + cell.frame.size.height);

[cell release];
}
}

for(NSString *category in categories){
    UIScrollView *categoryView = [categories objectForKey:category];
    categoryView.contentSize = CGSizeMake(320, categoryView.contentSize.height + 20);
}

//mainView.contentSize = CGSizeMake(320,height);
int buttonHeight = 0;
for(NSString *category in categoryNames){


    NSString *categoryTitle = [self localize:category forBundle:nil];
    UIButton *categoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    categoryButton.frame = CGRectMake(0,250 + buttonHeight,320, 40);

    [categoryButton setTitle:categoryTitle forState:UIControlStateNormal];  
    [categoryButton setBackgroundImage:nil forState:UIControlStateNormal];
    [categoryButton setTitleColor:[UIColor colorWithRed:42.0/255.0 green:140.0/255.0 blue:246.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [categoryButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    categoryButton.tag = [categoryNames indexOfObject:category] + 1;
    [categoryButton addTarget:self action:@selector(showCategory:) forControlEvents:UIControlEventTouchUpInside];
    [welcomeView addSubview:categoryButton];
    buttonHeight = buttonHeight + 40;

}

welcomeView.contentSize = CGSizeMake(320,480);
[self.view addSubview:mainView];
[categoryNames release];


//Setting up le chooser
chooserShadow = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,430)];
chooserShadow.backgroundColor = [UIColor blackColor];
chooserShadow.alpha = 0.0;
[self.view addSubview:chooserShadow];

chooserButton = [UIButton buttonWithType:UIButtonTypeCustom];
chooserButton.frame = CGRectMake(0,0,320, 430);

[chooserButton setTitle:nil forState:UIControlStateNormal];  
[chooserButton setBackgroundImage:nil forState:UIControlStateNormal];
 [chooserButton addTarget:self action:@selector(hideChooser) forControlEvents:UIControlEventTouchUpInside];
chooserButton.hidden = TRUE;
[chooserShadow addSubview:chooserButton];
[chooserShadow release];
chooser = [[UIScrollView alloc] initWithFrame:CGRectMake(320,0,320,4340)];
//chooser.hidden = TRUE;
chooser.backgroundColor = [UIColor whiteColor];
[self.view addSubview:chooser];
[chooser release];
[pool drain];
[self hideLoadingView];
}

-(void)showCategory:(UIButton *)button{
    int offset = 320 * button.tag;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.3f];
    [UIView setAnimationDidStopSelector:nil];
    mainView.contentOffset = CGPointMake(offset, 0);
    [UIView commitAnimations];

}

-(void)applyChanges{
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
[UIApplication sharedApplication].idleTimerDisabled = YES; //Don't want the device falling asleep now do we? :P
containerWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    containerWindow.windowLevel = [[UIApplication sharedApplication] keyWindow].windowLevel + 1;
    containerWindow.backgroundColor = [UIColor clearColor];
    [containerWindow makeKeyAndVisible];

UIImageView *leftUnderView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,10,480)];
leftUnderView.image = [UIImage imageWithContentsOfFile:@"/var/mobile/Whited00r/resources/Configurator/LeftUnder.png"];
[containerWindow addSubview:leftUnderView];
[leftUnderView release];

UIImageView *rightUnderView = [[UIImageView alloc] initWithFrame:CGRectMake(310,0,10,480)];
rightUnderView.image = [UIImage imageWithContentsOfFile:@"/var/mobile/Whited00r/resources/Configurator/RightUnder.png"];
[containerWindow addSubview:rightUnderView];
[rightUnderView release];

UIImageView *leftView = [[UIImageView alloc] initWithFrame:CGRectMake(-160,0,160,480)];
leftView.image = [UIImage imageWithContentsOfFile:@"/var/mobile/Whited00r/resources/Configurator/Left.png"];
[containerWindow addSubview:leftView];
[leftView release];

UIImageView *rightView = [[UIImageView alloc] initWithFrame:CGRectMake(320,0,160,480)];
rightView.image = [UIImage imageWithContentsOfFile:@"/var/mobile/Whited00r/resources/Configurator/Right.png"];
[containerWindow addSubview:rightView];
[rightView release];


/*
UIImageView *loadingOverlay = [[UIImageView alloc] initWithFrame:CGRectMake(0,225,320,30)];
loadingOverlay.image = [UIImage imageWithContentsOfFile:@"/var/mobile/Whited00r/resources/Configurator/LoadingOverlay.png"];
[containerWindow addSubview:loadingOverlay];
[loadingOverlay release];
*/
loadingUnderlay = [[UIImageView alloc] initWithFrame:CGRectMake(-30,235,30,10)];
loadingUnderlay.image = [UIImage imageWithContentsOfFile:@"/var/mobile/Whited00r/resources/Configurator/LoadingUnder.png"];
[containerWindow addSubview:loadingUnderlay];
[loadingUnderlay release];

UIView *centerView = [[UIView alloc] initWithFrame:CGRectMake(0,480,320,480)];
centerView.backgroundColor = [UIColor clearColor];
[containerWindow addSubview:centerView];

/*
workingLabel = [[UILabel alloc] init];
workingLabel.textAlignment = UITextAlignmentCenter;
workingLabel.font = [UIFont boldSystemFontOfSize:24];
workingLabel.frame=CGRectMake(0, 140, 320, 40);
workingLabel.backgroundColor = [UIColor clearColor];
workingLabel.text = @"Whited00r";
workingLabel.textColor = [UIColor blackColor];
*/
UIImageView * wdLogo = [[UIImageView alloc] initWithFrame:CGRectMake(100,80,120,130)];
wdLogo.image = [UIImage imageWithContentsOfFile:@"/var/mobile/Whited00r/resources/Configurator/WDLogo.png"];
wdLogo.alpha = 0.0;
[containerWindow addSubview:wdLogo];
[wdLogo release];

[centerView addSubview:workingLabel];
[workingLabel release];

UILabel *infoLabel = [[UILabel alloc] init];
infoLabel.textAlignment = UITextAlignmentCenter;
infoLabel.font = [UIFont boldSystemFontOfSize:12];
infoLabel.frame=CGRectMake(0, 280, 320, 40);
infoLabel.backgroundColor = [UIColor clearColor];
infoLabel.text = [self localize:@"LOADING_LABEL" forBundle:nil];
infoLabel.textColor = [UIColor blackColor];


[centerView addSubview:infoLabel];
[infoLabel release];
/*
UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	activityIndicator.frame = CGRectMake(145, 340, 30, 30);
[activityIndicator startAnimating];
	[centerView addSubview:activityIndicator];
*/
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.6f];
    [UIView setAnimationDidStopSelector:nil];

    centerView.frame = CGRectMake(0,0,320,480);
    leftView.frame = CGRectMake(0,0,160,480);
    rightView.frame = CGRectMake(160,0,160,480);
    leftUnderView.frame = CGRectMake(0,0,10,480);
    rightUnderView.frame = CGRectMake(160,0,10,480);
    wdLogo.alpha = 1.0;
    [UIView commitAnimations];

[self performSelectorInBackground:@selector(firstAnimationLoop) withObject:nil];

[self performSelectorInBackground:@selector(runShellScript) withObject:nil]; //FIXME
[centerView release];



[pool drain];


}




-(void)runShellScript{
system("/var/mobile/Whited00r/bin/configuratorRoot");

}

-(void)activateAdvanced{

[self performSelectorInBackground:@selector(showLoadingView) withObject:nil];
system("/var/mobile/Whited00r/bin/activateAdvancedRoot");
 [[mainView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
mainView.contentSize = CGSizeMake(320,0);
[self performSelectorInBackground:@selector(loadEverything) withObject:nil];


}

-(void)hideAdvanced{

[self performSelectorInBackground:@selector(showLoadingView) withObject:nil];
NSString *executable = [NSString stringWithFormat:@"/var/mobile/Whited00r/bin/hideAdvanced"];
NSPipe *resultPipe = [[NSPipe alloc] init];
NSTask *taskScript = [[NSTask alloc] init];
NSArray *argsScript = [NSArray arrayWithObjects:@"-e", executable, nil];
[taskScript setStandardOutput:resultPipe];

[taskScript setLaunchPath:@"/var/mobile/Whited00r/bin/rootthis"];
[taskScript setArguments:argsScript];
[taskScript launch];    // Run
[taskScript waitUntilExit]; // Wait
NSData *result = [[resultPipe fileHandleForReading] readDataToEndOfFile];
// [result writeToFile:@"/var/mobile/ResultPipe" atomically:YES];

[taskScript release];
[resultPipe release];
 [[mainView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
mainView.contentSize = CGSizeMake(320,0);
[self performSelectorInBackground:@selector(loadEverything) withObject:nil];


}

-(UIScrollView *)chooserView{
if(!chooser){
chooser = [[UIScrollView alloc] initWithFrame:CGRectMake(320,0,320,430)];
chooser.hidden = TRUE;
[self.view addSubview:chooser];
}
return chooser;

}

-(void)hideChooser{

chooserButton.hidden = TRUE;
[UIView beginAnimations:@"HideChooser" context:nil];
    [UIView setAnimationDuration:.5f];

chooser.frame=CGRectMake(320, 0, 320, 430);
chooserShadow.frame=CGRectMake(0, 0, 320, 430);
mainView.frame=CGRectMake(0, 0, 320, 430);
chooserShadow.alpha = 0.0;
    [UIView commitAnimations];


}

-(void)showChooser{
chooserButton.hidden = FALSE;
[UIView beginAnimations:@"ShowChooser" context:nil];
    [UIView setAnimationDuration:.5f];

chooser.frame=CGRectMake(60, 0, 320, 430);
chooserShadow.frame=CGRectMake(-260, 0, 320, 430);
mainView.frame=CGRectMake(-260, 0, 320, 430);
chooserShadow.alpha = 0.7;
    [UIView commitAnimations];

}


-(void)showModuleList{

[self performSelectorInBackground:@selector(showLoadingView) withObject:nil];

[self performSelectorInBackground:@selector(loadModules) withObject:nil];


}

-(void)loadModules{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
moduleList = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0,320,430)];
moduleList.contentSize = CGSizeMake(320,0);
moduleList.backgroundColor = [UIColor whiteColor];


UIButton *addButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
addButton.frame = CGRectMake(210, 5, 100, 30.0);

[addButton setTitle:@"Add Module" forState:UIControlStateNormal];  
[addButton setBackgroundImage:nil forState:UIControlStateNormal];
 [addButton addTarget:self action:@selector(addModule) forControlEvents:UIControlEventTouchUpInside];
  
[moduleList addSubview:addButton];


UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
closeButton.frame = CGRectMake(10, 5, 100, 30.0);

[closeButton setTitle:@"Close" forState:UIControlStateNormal];  
[closeButton setBackgroundImage:nil forState:UIControlStateNormal];
 [closeButton addTarget:self action:@selector(closeModuleList) forControlEvents:UIControlEventTouchUpInside];
  
[moduleList addSubview:closeButton];

NSFileManager *fMgr = [NSFileManager defaultManager]; 
int height = 50;
if ([fMgr fileExistsAtPath:@"/var/mobile/Library/OTAModules"]) { 


for(NSString *bundle in [fMgr contentsOfDirectoryAtPath:@"/var/mobile/Library/OTAModules" error:nil]){
NSDictionary *infoDict = [[NSDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Library/OTAModules/%@/Info.plist", bundle]];
ADVCell *cell = [[ADVCell alloc] initWithFrame:CGRectMake(0,height, 300, 50)];
cell.bundleID = bundle;
if(isWhited00r){
cell.title = [infoDict objectForKey:@"Title"];
}
else{
cell.title = @"Use whited00r";
}
cell.script = @"moduleThis";
cell.textColor = @"blueColor";
cell.delegate = self;
[cell baseInit];
[moduleList addSubview:cell];

height = height + cell.frame.size.height;
[cell release];


}

}
moduleList.contentSize = CGSizeMake(320,height);
[self.view addSubview:moduleList];
[self hideLoadingView];
[pool drain];
}


-(void)closeModuleList{
[moduleList removeFromSuperview];
showingAddModule = FALSE;  
//[[UIApplication sharedApplication] keyWindow] resignFirstResponder];

}

-(void)loadModuleUp:(NSString *)bundle{
//[keyboardView removeFromSuperview];
OTAModule *module = [[OTAModule alloc] initWithFrame:CGRectMake(0,0,320,430)];
module.moduleBundleID = bundle;
[module baseInit];
[self.view addSubview:module];
[module release];

}

-(void)addModule{
//moduleList.backgroundColor = [UIColor clearColor];

if(!showingAddModule){


UITextField *urlBar = [[UITextField alloc] initWithFrame:CGRectMake(10, 60, 300, 25.0)];
urlBar.placeholder= @"URL";
[urlBar setBackgroundColor:[UIColor lightGrayColor]];
urlBar.textAlignment=UITextAlignmentLeft;
urlBar.layer.cornerRadius=7.0;
urlBar.layer.masksToBounds = YES;
urlBar.delegate = self;

//urlBar.backgroundColor = [UIColor clearColor];

[moduleList addSubview:urlBar];
[urlBar release];
[urlBar becomeFirstResponder];

moduleList.contentSize = CGSizeMake(320,100);

showingAddModule = TRUE;
}
}


-(void)scriptPressed:(NSString *)script withID:(NSString *)bundle{
if([script isEqualToString:@"moduleThis"]){
[self loadModuleUp:bundle];
return;
}
NSString *executable = [NSString stringWithFormat:@"%@", script];
NSPipe *resultPipe = [[NSPipe alloc] init];
NSTask *taskScript = [[NSTask alloc] init];
NSArray *argsScript = [NSArray arrayWithObjects:@"-e", executable, nil];
[taskScript setStandardOutput:resultPipe];

[taskScript setLaunchPath:@"/var/mobile/Whited00r/bin/rootthis"];
[taskScript setArguments:argsScript];
[taskScript launch];    // Run
[taskScript waitUntilExit]; // Wait
NSData *result = [[resultPipe fileHandleForReading] readDataToEndOfFile];
// [result writeToFile:@"/var/mobile/ResultPipe" atomically:YES];

[taskScript release];
[resultPipe release];
}



- (void)textFieldDidBeginEditing:(UITextField *)textField{
//[self bringKeyboardToFront];

}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {






   //[textField resignFirstResponder];
if([textField.text isEqualToString:@""]){
UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"OTAModule Error"
                             message: @"Please enter a URL"
                             delegate: self
                             cancelButtonTitle: @"Okay"
                             otherButtonTitles: nil];
    [alert show];
    [alert release];

return NO;
}
//[keyboardView removeFromSuperview];   
showingAddModule = FALSE;  

OTAModule *module = [[OTAModule alloc] initWithFrame:CGRectMake(0,0,320,430)];
//NSLog(@"Setting module URL");
module.url = [NSString stringWithFormat:@"%@",textField.text];

//NSLog(@"Adding module to view");
[self.view addSubview:module];
//NSLog(@"Added module to view, setting up module");
[module newModuleSetup];
//NSLog(@"Setup module and stuff");
[module release];
[textField removeFromSuperview];
        return NO;

}
@end

// vim:ft=objc
