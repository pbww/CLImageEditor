//
//  CLImageEditorTheme.m
//
//  Created by sho yakushiji on 2013/12/05.
//  Copyright (c) 2013年 CALACULU. All rights reserved.
//

#import "CLImageEditorTheme.h"

@implementation CLImageEditorTheme

#pragma mark - singleton pattern

static CLImageEditorTheme *_sharedInstance = nil;

+ (CLImageEditorTheme*)theme
{
    static dispatch_once_t  onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[CLImageEditorTheme alloc] init];
    });
    return _sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (_sharedInstance == nil) {
            _sharedInstance = [super allocWithZone:zone];
            return _sharedInstance;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.bundleName                     = @"CLImageEditor";
        self.backgroundColor                = [UIColor whiteColor];
        self.toolbarColor                   = [UIColor colorWithWhite:1 alpha:0.8];
		self.toolIconColor                  = @"black";
        self.toolbarTextColor               = [UIColor colorWithRed:68.0/255.0 green:128.0/255.0 blue:170.0/255.0 alpha:1.0];
        self.toolbarSelectedButtonColor     = [UIColor colorWithRed:236.0/255.0 green:242.0/255.0 blue:246.0/255.0 alpha:1.0];
        self.toolbarTextFont                = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10];
        self.statusBarHidden                = NO;
        self.statusBarStyle                 = UIStatusBarStyleDefault;
    }
    return self;
}

-(void)setFont:(UIFont*)font
{
    self.toolbarTextFont = [font fontWithSize:10.0];
}

@end
