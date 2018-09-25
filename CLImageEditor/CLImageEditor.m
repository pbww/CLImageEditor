//
//  CLImageEditor.m
//
//  Created by sho yakushiji on 2013/10/17.
//  Copyright (c) 2013年 CALACULU. All rights reserved.
//

#import "CLImageEditor.h"

#import "_CLImageEditorViewController.h"

@interface CLImageEditor ()

@end

@implementation CLImageEditor

// Danish : Constant for image
NSString * const CROP = @"CROP";
NSString * const ROTATE = @"ROTATE";

// Danish : Const for Image property
NSString * const CROPRECT = @"cropRect";
NSString * const ANGLE = @"angle";
NSString * const FONT = @"font";
NSString * const BOLDFONT = @"boldFont";
NSString * const ASPECTRATIO = @"aspectRatio";
NSString * const CONTENTMODE = @"contentMode";
NSString * const BLEEDAREAX = @"bleedAreaX";
NSString * const BLEEDAREAY = @"bleedAreaY";
NSString * const BLEEDCROPRECT = @"bleedCropRect";
NSString * const MINRECTSIZE = @"minRectSize";

- (id)init
{
    return [_CLImageEditorViewController new];
}

- (id)initWithImage:(UIImage*)image
{
    return [self initWithImage:image delegate:nil];
}

- (id)initWithImage:(UIImage*)image delegate:(id<CLImageEditorDelegate>)delegate
{
    return [[_CLImageEditorViewController alloc] initWithImage:image delegate:delegate];
}

//-- Danish
- (id)initWithImage:(UIImage*)image delegate:(id<CLImageEditorDelegate>)delegate withOptions:(NSDictionary*)imageProperty
{
    return [[_CLImageEditorViewController alloc] initWithImage:image delegate:delegate withOptions:imageProperty];
}

- (id)initWithImage:(UIImage*)image delegate:(id<CLImageEditorDelegate>)delegate withOptions:(NSDictionary*)imageProperty withBleedArea:(CLBleedArea*)bleedArea {
    return [[_CLImageEditorViewController alloc] initWithImage:image delegate:delegate withOptions:imageProperty withBleedArea:bleedArea];
}

- (id)initWithDelegate:(id<CLImageEditorDelegate>)delegate
{
    return [[_CLImageEditorViewController alloc] initWithDelegate:delegate];
}

- (void)showInViewController:(UIViewController*)controller withImageView:(UIImageView*)imageView;
{
    
}

- (void)refreshToolSettings
{
    
}

- (CLImageEditorTheme*)theme
{
    return [CLImageEditorTheme theme];
}

-(void)showOptions:(NSDictionary*)dic withToolInfo:(NSArray*)subtool
{
   NSArray *keys = dic.allKeys;
    for (CLImageToolInfo *tool in subtool){

        if([keys containsObject:tool.title]){
            [tool setAvailable:YES];
            tool.dockedNumber = [[dic objectForKey:tool.title] floatValue];
        }
        else{
             [tool setAvailable:NO];
        }
    }
}

@end

