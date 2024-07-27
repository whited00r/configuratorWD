#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "OTAModule.h"
#import <stdio.h>
#import <string.h>
#import <stdlib.h>
#import <notify.h>
#import <Foundation/NSTask.h>
#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <Preferences/Preferences.h>

#import "ADVCell.h"



@implementation OTAModule

@synthesize  moduleTitle, moduleBundleID, version, url, password, moduleInfo, plistName, executable, developer, delegate;

-(id)initWithFrame:(CGRect)frame
{

self = [super initWithFrame:frame];
if (self) {

//self.backgroundColor = [UIColor colorWithRed:229/255.0f green:229/255.0f blue:229/255.0f alpha:1.0f];
self.backgroundColor = [UIColor whiteColor];
self.userInteractionEnabled = TRUE;
//NSLog(@"Returning self?");
}
return self;
}


-(void)baseInit{
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
NSFileManager *fMgr = [NSFileManager defaultManager]; 
if (![fMgr fileExistsAtPath:@"/var/mobile/Library/OTAModules"]) { 
[fMgr createDirectoryAtPath:@"/var/mobile/Library/OTAModules" attributes:nil];
}


if (![fMgr fileExistsAtPath:[NSString stringWithFormat:@"/var/mobile/Library/OTAModules/%@", self.moduleBundleID]]) { 
//[fMgr createDirectoryAtPath:[NSString stringWithFormat:@"/var/mobile/Library/OTAModules/%@", self.moduleBundleID] attributes:nil];
[self initSetup];
}
else{
[self performSelectorInBackground:@selector(showLoadingView) withObject:nil];
NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Library/OTAModules/%@/Info.plist", self.moduleBundleID]];

self.moduleTitle = [tempDict objectForKey:@"Title"];
if([tempDict objectForKey:@"Password"]){
self.password = [tempDict objectForKey:@"Password"];
}
self.version = [tempDict objectForKey:@"Version"];
self.plistName = [tempDict objectForKey:@"PlistName"];
self.moduleBundleID = [tempDict objectForKey:@"BundleID"];
if([tempDict objectForKey:@"Executable"]){
self.executable = [tempDict objectForKey:@"Executable"];
}
self.developer = [tempDict objectForKey:@"Developer"];
self.url = [tempDict objectForKey:@"URL"];
[tempDict release];

[self performSelectorInBackground:@selector(loadPlistUp) withObject:nil];



}
[pool drain];
}


-(void)initSetup{
[self performSelectorInBackground:@selector(showLoadingView) withObject:nil];

[self performSelectorInBackground:@selector(newModuleSetup) withObject:nil];
}

-(void)newModuleSetup{
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
NSLog(@"New module setup setting up");
NSFileManager *fMgr = [NSFileManager defaultManager]; 
if (![fMgr fileExistsAtPath:@"/var/mobile/Library/OTAModules"]) { 
[fMgr createDirectoryAtPath:@"/var/mobile/Library/OTAModules" attributes:nil];
NSLog(@"Creating modules folder");
}
NSLog(@"Hiding mainView");
mainView.hidden = TRUE;
NSLog(@"Hid mainView");
NSLog(@"Allocating moduleLoader");
moduleLoader = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,430)];
moduleLoader.backgroundColor = [UIColor whiteColor];
[self addSubview:moduleLoader];
UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
closeButton.frame = CGRectMake(210, 10, 100, 40.0);

[closeButton setTitle:@"Close" forState:UIControlStateNormal];  
[closeButton setBackgroundImage:nil forState:UIControlStateNormal];
 [closeButton addTarget:self action:@selector(closeModule) forControlEvents:UIControlEventTouchUpInside];
  
[moduleLoader addSubview:closeButton];

NSLog(@"Grabbing module info");
moduleInfo = [[NSMutableDictionary alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/Module.plist", self.url]]];

if(!moduleInfo){
UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"OTAModule Error"
                             message: @"Looks like there was no response."
                             delegate: self
                             cancelButtonTitle: @"Okay"
                             otherButtonTitles: nil];
    [alert show];
    [alert release];
[pool drain];
return;

}

BOOL passwordEnabled = FALSE;

if([moduleInfo objectForKey:@"PasswordProtected"]){
passwordEnabled = TRUE;
if(![[moduleInfo objectForKey:@"PasswordProtected"] boolValue]){
passwordEnabled = FALSE;
}
}
if(![moduleInfo objectForKey:@"PasswordProtected"]){
passwordEnabled = FALSE;
}


if([moduleInfo objectForKey:@"Version"]){
self.version = [moduleInfo objectForKey:@"Version"];

}
else{
self.version = @"N/A";
}

if([moduleInfo objectForKey:@"Name"]){
self.moduleTitle = [moduleInfo objectForKey:@"Name"];

}
else{
self.moduleTitle = @"N/A";
}

if([moduleInfo objectForKey:@"Developer"]){
self.developer = [moduleInfo objectForKey:@"Developer"];

}
else{
self.developer = @"N/A";
}

if([moduleInfo objectForKey:@"PlistName"]){
self.plistName = [moduleInfo objectForKey:@"PlistName"];

}
else{
UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"OTAModule Error"
                             message: @"Sadly, there is no plist name set server side."
                             delegate: self
                             cancelButtonTitle: @"Okay"
                             otherButtonTitles: nil];
    [alert show];
    [alert release];
[pool drain];
return;
}


if([moduleInfo objectForKey:@"BundleID"]){
self.moduleBundleID = [moduleInfo objectForKey:@"BundleID"];

}
else{
UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"OTAModule Error"
                             message: @"No bundle ID server side, cannot continue."
                             delegate: self
                             cancelButtonTitle: @"Okay"
                             otherButtonTitles: nil];
    [alert show];
    [alert release];
[pool drain];
return;
}





NSLog(@"Adding labels...");
UILabel *moduleTitle = [[UILabel alloc] init];
moduleTitle.textAlignment = UITextAlignmentLeft;
moduleTitle.font = [UIFont boldSystemFontOfSize:18];
moduleTitle.frame=CGRectMake(10, 5, 200, 30);
moduleTitle.backgroundColor = [UIColor clearColor];
moduleTitle.text = self.moduleTitle;
moduleTitle.textColor = [UIColor blackColor];

[moduleLoader addSubview:moduleTitle];
[moduleTitle release];


NSLog(@"Added title, adding developer");
UILabel *moduleDeveloper = [[UILabel alloc] init];
moduleDeveloper.textAlignment = UITextAlignmentLeft;
moduleDeveloper.font = [UIFont systemFontOfSize:14];
moduleDeveloper.frame=CGRectMake(10, 40, 200, 50);
moduleDeveloper.backgroundColor = [UIColor clearColor];
moduleDeveloper.text = [NSString stringWithFormat:@"Developer:\n%@", self.developer];
moduleDeveloper.textColor = [UIColor blackColor];
moduleDeveloper.numberOfLines = 2;
[moduleLoader addSubview:moduleDeveloper];
[moduleDeveloper sizeToFit];

NSLog(@"Added developer, adding version");
UILabel *moduleVersion = [[UILabel alloc] init];
moduleVersion.textAlignment = UITextAlignmentLeft;
moduleVersion.font = [UIFont systemFontOfSize:14];
moduleVersion.frame=CGRectMake(moduleDeveloper.frame.size.width + 20, 40, 100, 50);
moduleVersion.backgroundColor = [UIColor clearColor];
moduleVersion.text = [NSString stringWithFormat:@"Version:\n%@", self.version];
moduleVersion.textColor = [UIColor blackColor];
moduleVersion.numberOfLines = 2;
[moduleLoader addSubview:moduleVersion];
[moduleVersion sizeToFit];
[moduleVersion release];
[moduleDeveloper release];


if(passwordEnabled){

UILabel *passwordLabel = [[UILabel alloc] init];
passwordLabel.textAlignment = UITextAlignmentLeft;
passwordLabel.font = [UIFont systemFontOfSize:14];
passwordLabel.frame=CGRectMake(10, 80, 100, 50);
passwordLabel.backgroundColor = [UIColor clearColor];
passwordLabel.text = @"Password";
passwordLabel.textColor = [UIColor blackColor];

[moduleLoader addSubview:passwordLabel];
[passwordLabel release];

passwordBar = [[UITextField alloc] initWithFrame:CGRectMake(40, 120, 260, 25.0)];
passwordBar.placeholder= nil;
[passwordBar setBackgroundColor:[UIColor lightGrayColor]];
passwordBar.textAlignment=UITextAlignmentLeft;
passwordBar.layer.cornerRadius=7.0;
passwordBar.layer.masksToBounds = YES;
passwordBar.delegate = self;
//passwordBar.backgroundColor = [UIColor clearColor];

[moduleLoader addSubview:passwordBar];
[passwordBar becomeFirstResponder];
[passwordBar release];
 //UIKeyboardEnableAutomaticAppearance();



}
else{
UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
button.frame = CGRectMake(30, 120, 260, 40.0);

[button setTitle:@"Install Module" forState:UIControlStateNormal];  
[button setBackgroundImage:nil forState:UIControlStateNormal];
 [button addTarget:self action:@selector(preInstall) forControlEvents:UIControlEventTouchUpInside];
  
[moduleLoader addSubview:button];

}
[self hideLoadingView];
[pool drain];
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField {



        [textField resignFirstResponder];
self.password = textField.text;


 
if([textField.text isEqualToString:@""]){
UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"OTAModule Error"
                             message: @"Please enter the password."
                             delegate: self
                             cancelButtonTitle: @"Okay"
                             otherButtonTitles: nil];
    [alert show];
    [alert release];

return NO;
}

[self performSelectorInBackground:@selector(showLoadingView) withObject:nil];
[self performSelectorInBackground:@selector(checkPassword) withObject:nil];
        return NO;

}


-(void)checkPassword{
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
NSString *encrypted;
NSString *unEncrypted;
if(![moduleInfo objectForKey:@"Encrypted"]){

UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"OTAModule Error"
                             message: @"Server side error, no encrypted key."
                             delegate: self
                             cancelButtonTitle: @"Okay"
                             otherButtonTitles: nil];
    [alert show];
    [alert release];
[pool drain];

return;
}
else{
encrypted = [moduleInfo objectForKey:@"Encrypted"];

}

if(![moduleInfo objectForKey:@"UnEncrypted"]){

UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"OTAModule Error"
                             message: @"Server side error, no unencrypted key."
                             delegate: self
                             cancelButtonTitle: @"Okay"
                             otherButtonTitles: nil];
    [alert show];
    [alert release];
[pool drain];
return;
}
else{
unEncrypted = [moduleInfo objectForKey:@"UnEncrypted"];
}


NSString *firstLevel = [NSString stringWithFormat:@"%@-%@", self.password, unEncrypted];
NSString *arguments = [NSString stringWithFormat:@"echo %@ | openssl dgst -sha1 -hmac \"WhatNow\"", firstLevel];
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

if (![licenseKey isEqualToString:encrypted]) { 

UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"OTAModule Error"
                             message: @"Incorrect password."
                             delegate: self
                             cancelButtonTitle: @"Okay"
                             otherButtonTitles: nil];
    [alert show];
    [alert release];
[taskCrypt release];
//[result release];
//[licenseKey release];
[resultPipe release];
[pool drain];
return;
}
[taskCrypt release];
//[result release];
//[licenseKey release];
[resultPipe release];

[passwordBar removeFromSuperview];

UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
button.frame = CGRectMake(30, 120, 260, 40.0);

[button setTitle:@"Install Module" forState:UIControlStateNormal];  
[button setBackgroundImage:nil forState:UIControlStateNormal];
 [button addTarget:self action:@selector(preInstall) forControlEvents:UIControlEventTouchUpInside];
  
[moduleLoader addSubview:button];
[pool drain];
}
-(void)preInstall{
[self performSelectorInBackground:@selector(showLoadingView) withObject:nil];
[self performSelectorInBackground:@selector(installModule) withObject:nil];

}

//Installing a module
-(void)installModule{
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
NSLog(@"Starting to install the module from online");
[moduleLoader removeFromSuperview];
[moduleLoader release];
NSLog(@"Removed and released the moduleLoader");
NSFileManager *fMgr = [NSFileManager defaultManager]; 

if(![fMgr fileExistsAtPath:[NSString stringWithFormat:@"/var/mobile/Library/OTAModules/%@", self.moduleBundleID]]){
[fMgr createDirectoryAtPath:[NSString stringWithFormat:@"/var/mobile/Library/OTAModules/%@", self.moduleBundleID] attributes:nil];
}
NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];

[tempDict setObject:self.moduleTitle forKey:@"Title"];
if(!self.password == nil){
[tempDict setObject:self.password forKey:@"Password"];
}
[tempDict setObject:self.version forKey:@"Version"];
[tempDict setObject:self.plistName forKey:@"PlistName"];
[tempDict setObject:self.moduleBundleID forKey:@"BundleID"];
[tempDict setObject:self.url forKey:@"URL"];
[tempDict setObject:self.developer forKey:@"Developer"];
[tempDict writeToFile:[NSString stringWithFormat:@"/var/mobile/Library/OTAModules/%@/Info.plist", self.moduleBundleID] atomically:YES];
[tempDict release];

loadingLabel.text = [NSString stringWithFormat:@"Downloading main GUI file..."];
NSDictionary *onlineDict = [[NSDictionary alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", self.url, self.plistName]]];
[onlineDict writeToFile:[NSString stringWithFormat:@"/var/mobile/Library/OTAModules/%@/Module.plist", self.moduleBundleID] atomically:YES];


if([moduleInfo objectForKey:@"Files"]){
NSLog(@"Had Files");
for(NSString *file in [moduleInfo objectForKey:@"Files"]){
NSLog(@"File is: %@", file);
NSString *stringURL = [NSString stringWithFormat:@"%@/%@", self.url, file];
NSLog(@"StringURL is: %@", stringURL);
NSURL  *url = [NSURL URLWithString:stringURL];
NSData *urlData = [NSData dataWithContentsOfURL:url];
if ( urlData )
{
NSLog(@"Had URLData for: %@", file);
loadingLabel.text = [NSString stringWithFormat:@"Downloading: %@...", file];
  [urlData writeToFile:[NSString stringWithFormat:@"/var/mobile/Library/OTAModules/%@/%@", self.moduleBundleID, file] atomically:YES];
NSLog(@"Downloaded %@", file);
}


}



}
[onlineDict release];
loadingLabel.text = [NSString stringWithFormat:@"Working..."];
[self loadPlistUp];
[pool drain];
}


-(void)showLoadingView{
mainView.hidden = TRUE;
loadingLabel = [[UILabel alloc] init];
loadingLabel.textAlignment = UITextAlignmentCenter;
loadingLabel.font = [UIFont boldSystemFontOfSize:12];
loadingLabel.frame=CGRectMake(0, 180, 320, 40);
loadingLabel.backgroundColor = [UIColor clearColor];
loadingLabel.text = @"Initializing...";
loadingLabel.textColor = [UIColor blackColor];


[self addSubview:loadingLabel];
[loadingLabel release];

loadingIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	loadingIndicator.frame = CGRectMake(145, 225, 30, 30);
[loadingIndicator startAnimating];
	[self addSubview:loadingIndicator];


}

-(void)hideLoadingView{
mainView.hidden = FALSE;
if(loadingIndicator){
[loadingIndicator removeFromSuperview];
[loadingIndicator release];
loadingIndicator = nil;
}
if(loadingLabel){
[loadingLabel removeFromSuperview];
loadingLabel = nil;
}

}

-(void)loadPlistUp{
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
NSMutableDictionary *mainPlist = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Library/OTAModules/%@/Module.plist", self.moduleBundleID]];
NSLog(@"Got the items...");
NSArray *items = [mainPlist objectForKey:@"items"];
mainView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,100,320,320)];
mainView.contentSize = CGSizeMake(320,0);
headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,100)];
[self addSubview:headerView];

NSLog(@"Adding labels...");
UILabel *moduleTitle = [[UILabel alloc] init];
moduleTitle.textAlignment = UITextAlignmentLeft;
moduleTitle.font = [UIFont boldSystemFontOfSize:18];
moduleTitle.frame=CGRectMake(10, 5, 200, 30);
moduleTitle.backgroundColor = [UIColor clearColor];
moduleTitle.text = self.moduleTitle;
moduleTitle.textColor = [UIColor blackColor];

[headerView addSubview:moduleTitle];
[moduleTitle release];


NSLog(@"Added verison, adding developer");
UILabel *moduleDeveloper = [[UILabel alloc] init];
moduleDeveloper.textAlignment = UITextAlignmentLeft;
moduleDeveloper.font = [UIFont systemFontOfSize:14];
moduleDeveloper.frame=CGRectMake(10, 40, 200, 50);
moduleDeveloper.backgroundColor = [UIColor clearColor];
moduleDeveloper.text = [NSString stringWithFormat:@"Developer:\n%@", self.developer];
moduleDeveloper.textColor = [UIColor blackColor];
moduleDeveloper.numberOfLines = 2;
[headerView addSubview:moduleDeveloper];
[moduleDeveloper sizeToFit];

NSLog(@"Added title, adding version");
UILabel *moduleVersion = [[UILabel alloc] init];
moduleVersion.textAlignment = UITextAlignmentLeft;
moduleVersion.font = [UIFont systemFontOfSize:14];
moduleVersion.frame=CGRectMake(moduleDeveloper.frame.size.width + 20, 40, 100, 50);
moduleVersion.backgroundColor = [UIColor clearColor];
moduleVersion.text = [NSString stringWithFormat:@"Version:\n%@", self.version];
moduleVersion.textColor = [UIColor blackColor];
moduleVersion.numberOfLines = 2;
[headerView addSubview:moduleVersion];
[moduleVersion sizeToFit];
[moduleVersion release];
[moduleDeveloper release];

UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
button.frame = CGRectMake(210, 10, 80, 30.0);

[button setTitle:@"Update" forState:UIControlStateNormal];  
[button setBackgroundImage:nil forState:UIControlStateNormal];
 [button addTarget:self action:@selector(checkForUpdate) forControlEvents:UIControlEventTouchUpInside];
  
[headerView addSubview:button];

UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
closeButton.frame = CGRectMake(210, 50, 80, 30.0);

[closeButton setTitle:@"Close" forState:UIControlStateNormal];  
[closeButton setBackgroundImage:nil forState:UIControlStateNormal];
 [closeButton addTarget:self action:@selector(closeModule) forControlEvents:UIControlEventTouchUpInside];
  
[headerView addSubview:closeButton];
[headerView release];

int height = 0;

for(NSDictionary *dict in items){
NSLog(@"Loading up items...");
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
ADVCell *cell = [[ADVCell alloc] initWithFrame:CGRectMake(0,height, 320, 50)];

if([dict objectForKey:@"label"]){
NSLog(@"Found label: %@", [dict objectForKey:@"label"]);
cell.title = [dict objectForKey:@"label"];
}
if([dict objectForKey:@"defaults"]){
NSLog(@"Found defaults: %@", [dict objectForKey:@"defaults"]);
cell.bundleID = [dict objectForKey:@"defaults"];

}
NSLog(@"Setting cell type...");
cell.cellType = [dict objectForKey:@"cell"];
if(![dict objectForKey:@"default"] == nil){

cell.enabled = [[dict objectForKey:@"default"] boolValue];

}

if([dict objectForKey:@"key"]){
cell.key = [dict objectForKey:@"key"];

}

if([dict objectForKey:@"script"]){
cell.script = [dict objectForKey:@"script"];

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

if([dict objectForKey:@"action"]){
cell.action = [dict objectForKey:@"action"];

}

if([[dict objectForKey:@"cell"] isEqualToString:@"PSLinkListCell"]){
cell.titles = [dict objectForKey:@"validTitles"];
cell.values = [dict objectForKey:@"validValues"];
}
cell.delegate = self;
[cell baseInit];
[mainView addSubview:cell];

height = height + cell.frame.size.height;
[cell release];
}
}

mainView.contentSize = CGSizeMake(320,height);

[self addSubview:mainView];


//Setting up le chooser
chooserShadow = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,430)];
chooserShadow.backgroundColor = [UIColor blackColor];
chooserShadow.alpha = 0.0;
[self addSubview:chooserShadow];

chooserButton = [UIButton buttonWithType:UIButtonTypeCustom];
chooserButton.frame = CGRectMake(0,0,320, 430);

[chooserButton setTitle:nil forState:UIControlStateNormal];  
[chooserButton setBackgroundImage:nil forState:UIControlStateNormal];
 [chooserButton addTarget:self action:@selector(hideChooser) forControlEvents:UIControlEventTouchUpInside];
chooserButton.hidden = TRUE;
[chooserShadow addSubview:chooserButton];
[chooserShadow release];
chooser = [[UIScrollView alloc] initWithFrame:CGRectMake(320,0,320,340)];
//chooser.hidden = TRUE;
chooser.backgroundColor = [UIColor whiteColor];
[self addSubview:chooser];
[chooser release];

[self hideLoadingView];
[pool drain];
}




-(UIScrollView *)chooserView{
if(!chooser){
chooser = [[UIScrollView alloc] initWithFrame:CGRectMake(320,0,320,430)];
chooser.hidden = TRUE;
[self addSubview:chooser];
}
return chooser;

}

-(void)hideChooser{

chooserButton.hidden = TRUE;
[UIView beginAnimations:@"HideChooser" context:nil];
    [UIView setAnimationDuration:.5f];

chooser.frame=CGRectMake(320, 0, 320, 430);
chooserShadow.frame=CGRectMake(0, 0, 320, 430);
headerView.frame=CGRectMake(0, 0, 320, 100);
mainView.frame=CGRectMake(0, 100, 320, 320);
chooserShadow.alpha = 0.0;
    [UIView commitAnimations];


}

-(void)showChooser{
chooserButton.hidden = FALSE;
[UIView beginAnimations:@"ShowChooser" context:nil];
    [UIView setAnimationDuration:.5f];

chooser.frame=CGRectMake(60, 0, 320, 430);
chooserShadow.frame=CGRectMake(-260, 0, 320, 430);
headerView.frame=CGRectMake(-260, 0, 320, 100);
mainView.frame=CGRectMake(-260, 100, 320, 320);
chooserShadow.alpha = 0.7;
    [UIView commitAnimations];

}


-(void)scriptPressed:(NSString *)script withID:(NSString *)bundle{


NSString *executable = [NSString stringWithFormat:@"/var/mobile/Library/OTAModules/%@/%@", self.moduleBundleID, script];
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


-(void)checkForUpdate{
NSDictionary *onlineDict = [[NSDictionary alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/Module.plist", self.url]]];

if(!onlineDict){
UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"OTAModule Error"
                             message: @"Unable to get Module info from online."
                             delegate: self
                             cancelButtonTitle: @"Okay"
                             otherButtonTitles: nil];
    [alert show];
    [alert release];
return;
}

if([[onlineDict objectForKey:@"Version"] intValue] > [self.version intValue]){
headerView.hidden = TRUE;
mainView.hidden = TRUE;
[self initSetup];


}
else{
UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"OTAModule Error"
                             message: @"You are running the current version of this module."
                             delegate: self
                             cancelButtonTitle: @"Okay"
                             otherButtonTitles: nil];
    [alert show];
    [alert release];
return;

}

}

-(void)closeModule{
[self removeFromSuperview];
}

@end
