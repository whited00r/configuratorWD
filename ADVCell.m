#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "ADVCell.h"
//#import "RootViewController.h"

@implementation ADVCell

@synthesize localize, title, bundleID, key, altText, cellType, subText, action, enabled, defaultValue, titles, values, delegate, isBold, textColor, cellBackgroundColor, popupText, script;


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

 -(UIColor *)getColor:(NSString*)col

  {

  SEL selColor = NSSelectorFromString(col);
  UIColor *color = nil;
  if ( [UIColor respondsToSelector:selColor] == YES) {

    color = [UIColor performSelector:selColor];
   }  
    return color;
  }



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
if(!self.defaultValue){
self.defaultValue = @"Error";

}

NSFileManager *fMgr = [NSFileManager defaultManager]; 
if(self.bundleID){
if (![fMgr fileExistsAtPath:[NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", self.bundleID]]) { 
NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
if([self.cellType isEqualToString:@"PSSwitchCell"]){
[tempDict setObject:[NSNumber numberWithBool:self.enabled] forKey:self.key];
}
if([self.cellType isEqualToString:@"PSLinkListCell"]){
[tempDict setObject:self.defaultValue forKey:self.key];
}
[tempDict writeToFile:[NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", self.bundleID] atomically:YES];
[tempDict release];
}

NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", self.bundleID]];
if([self.cellType isEqualToString:@"PSSwitchCell"]){
self.enabled = [[prefs objectForKey:self.key] boolValue];
}
if([self.cellType isEqualToString:@"PSLinkListCell"]){
if([prefs objectForKey:self.key]){
self.defaultValue = [self.titles objectAtIndex:[self.values indexOfObject:[prefs objectForKey:self.key]]];
}
}
}

if(!self.title){
self.title = @" ";
if([self.cellType isEqualToString:@"PSGroupCell"]){
self.frame = CGRectMake(0,0,320, 20);
}

}
UILabel *cellTitle = [[UILabel alloc] init];
cellTitle.textAlignment = UITextAlignmentLeft;
if(self.isBold){
cellTitle.font = [UIFont boldSystemFontOfSize:18];
}
else{
cellTitle.font = [UIFont systemFontOfSize:18];
}
cellTitle.frame=CGRectMake(20, 5, 200, 40);
cellTitle.backgroundColor = [UIColor clearColor];
if(self.localize && self.bundleID){
cellTitle.text = [self localize:self.title forBundle:self.bundleID];
}
else{
cellTitle.text = [self localize:self.title forBundle:nil];
}

if(!self.textColor){
cellTitle.textColor = [UIColor blackColor];
}
else{
cellTitle.textColor = [self getColor:self.textColor];

}

if([self.cellType isEqualToString:@"PSButtonCell"]){
cellTitle.frame=CGRectMake(20, 5, 300, 40);
cellTitle.textAlignment = UITextAlignmentCenter;

}
if([self.cellType isEqualToString:@"PSGroupCell"]){
cellTitle.frame=CGRectMake(20, 5, 300, 40);
cellTitle.textAlignment = UITextAlignmentCenter;

cellTitle.numberOfLines = 0;
cellTitle.lineBreakMode = UILineBreakModeWordWrap;
[cellTitle sizeToFit];
self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, cellTitle.frame.size.height + 20);

}

[self addSubview:cellTitle];
[cellTitle release];

if([self.cellType isEqualToString:@"PSLinkListCell"]){
defaultTitle = [[UILabel alloc] init];
defaultTitle.textAlignment = UITextAlignmentRight;
defaultTitle.font = [UIFont systemFontOfSize:14];
defaultTitle.frame=CGRectMake(180, 3, 125, 50);
defaultTitle.backgroundColor = [UIColor clearColor];
defaultTitle.text = self.defaultValue;
defaultTitle.textColor = [UIColor blackColor];

[self addSubview:defaultTitle];
[defaultTitle release];


UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
button.frame = CGRectMake(0,0,300, self.frame.size.height);

[button setTitle:nil forState:UIControlStateNormal];  
[button setBackgroundImage:nil forState:UIControlStateNormal];
 [button addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
  
[self addSubview:button];

}

if(self.popupText){
UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
button.frame = CGRectMake(0,0,200, self.frame.size.height);

[button setTitle:nil forState:UIControlStateNormal];  
[button setBackgroundImage:nil forState:UIControlStateNormal];
 [button addTarget:self action:@selector(showPopup) forControlEvents:UIControlEventTouchUpInside];
  
[self addSubview:button];

}

if(self.cellBackgroundColor){
self.backgroundColor = [self getColor:self.cellBackgroundColor];

}
else{
UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(20, self.frame.size.height - 1, self.frame.size.width - 10, 1)];
lineView.backgroundColor = [UIColor colorWithRed:229/255.0f green:229/255.0f blue:229/255.0f alpha:1.0f];
[self addSubview:lineView];
[lineView release];
}


if(self.action){
UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
button.frame = CGRectMake(0,0,300, self.frame.size.height);

[button setTitle:nil forState:UIControlStateNormal];  
[button setBackgroundImage:nil forState:UIControlStateNormal];
 [button addTarget:self.delegate action:NSSelectorFromString(self.action) forControlEvents:UIControlEventTouchUpInside];
  
[self addSubview:button];


}


if(self.script){
UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
button.frame = CGRectMake(0,0,300, self.frame.size.height);

[button setTitle:nil forState:UIControlStateNormal];  
[button setBackgroundImage:nil forState:UIControlStateNormal];
 [button addTarget:self action:@selector(scriptPressed) forControlEvents:UIControlEventTouchUpInside];
  
[self addSubview:button];


}



if([self.cellType isEqualToString:@"PSSwitchCell"]){
UISwitch *switchy = [[UISwitch alloc] initWithFrame:CGRectMake(220, 10, 60,25)];
[switchy addTarget: self action: @selector(switchFlipped:) forControlEvents:UIControlEventValueChanged];
[switchy setOn:self.enabled];
[self addSubview:switchy];
[switchy release];

}
[pool drain];
}


-(void)switchFlipped:(UISwitch *)flipped{
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", self.bundleID]];


if(flipped.on){

[prefs setObject:[NSNumber numberWithBool:TRUE] forKey:self.key];
enabled = TRUE;
}
else{
[prefs setObject:[NSNumber numberWithBool:FALSE] forKey:self.key];
enabled = FALSE;

}
[prefs writeToFile:[NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", self.bundleID] atomically:YES];

if(self.script){
[self scriptPressed];

}
[pool drain];
}

-(void)buttonPressed{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
[[[self.delegate chooserView] subviews]
 makeObjectsPerformSelector:@selector(removeFromSuperview)];
[self.delegate chooserView].contentSize = CGSizeMake(320, 0);
int height = 0;
for(NSString *title in self.titles){
UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
button.frame = CGRectMake(5,height,260, 40);

[button setTitle:title forState:UIControlStateNormal];  
[button setBackgroundImage:nil forState:UIControlStateNormal];
 [button addTarget:self action:@selector(titlePressed:) forControlEvents:UIControlEventTouchUpInside];
  button.tag = [self.titles indexOfObject:title];
[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
[[self.delegate chooserView] addSubview:button];

height = height + 50;

}

[self.delegate chooserView].contentSize = CGSizeMake(320, height);
[self.delegate showChooser];
[pool drain];
}

-(void)titlePressed:(UIButton *)button{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
[self.delegate hideChooser];
NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", self.bundleID]];

defaultTitle.text = [self.titles objectAtIndex:button.tag];

[prefs setObject:[self.values objectAtIndex:button.tag] forKey:self.key];
[prefs writeToFile:[NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", self.bundleID] atomically:YES];

if(self.script){
[self scriptPressed];

}
[pool drain];
}

-(void)showPopup{
if(self.localize && self.bundleID){
UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: [self localize:self.title forBundle:self.bundleID]
                             message: [self localize:self.popupText forBundle:self.bundleID]
                             delegate: self
                             cancelButtonTitle: [self localize:@"OKAY_BUTTON" forBundle:nil]
                             otherButtonTitles: nil];
    [alert show];
    [alert release];
}
else{
UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: [self localize:self.title forBundle:nil]
                             message: [self localize:self.popupText forBundle:nil]
                             delegate: self
                             cancelButtonTitle: [self localize:@"OKAY_BUTTON" forBundle:nil]
                             otherButtonTitles: nil];
    [alert show];
    [alert release];
}
}


-(void)scriptPressed{

[self.delegate scriptPressed:self.script withID:self.bundleID];

}
@end
