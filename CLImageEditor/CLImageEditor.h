//
//  CLImageEditor.h
//  Danish 
//  Created by sho yakushiji on 2013/10/17.
//  Copyright (c) 2013年 CALACULU. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CLImageToolInfo.h"
#import "CLImageEditorTheme.h"

@protocol CLImageEditorDelegate;
@protocol CLImageEditorTransitionDelegate;


@interface CLImageEditor : UIViewController
{

}

extern NSString * const CROP;
extern NSString * const ROTATE;

extern NSString * const CROPRECT;
extern NSString * const ANGLE;
extern NSString * const FONT;
extern NSString * const BOLDFONT;
extern NSString * const ASPECTRATIO;
extern NSString * const CONTENTMODE;
extern NSString * const BLEEDAREAX;
extern NSString * const BLEEDAREAY;


@property (nonatomic, weak) id<CLImageEditorDelegate> delegate;
@property (nonatomic, readonly) CLImageEditorTheme *theme;
@property (nonatomic, readonly) CLImageToolInfo *toolInfo;

- (id)initWithImage:(UIImage*)image;
- (id)initWithImage:(UIImage*)image delegate:(id<CLImageEditorDelegate>)delegate;
- (id)initWithDelegate:(id<CLImageEditorDelegate>)delegate;
- (void)showInViewController:(UIViewController<CLImageEditorTransitionDelegate>*)controller withImageView:(UIImageView*)imageView;

//-- Danish
-(void)showOptions:(NSDictionary*)dic withToolInfo:(NSArray*)subtool;
- (id)initWithImage:(UIImage*)image delegate:(id<CLImageEditorDelegate>)delegate withOptions:(NSDictionary*)imageProperty;


@end



@protocol CLImageEditorDelegate <NSObject>
@optional
- (void)imageEditor:(CLImageEditor*)editor didFinishEdittingWithImage:(UIImage*)image __attribute__ ((deprecated));
- (void)imageEditor:(CLImageEditor*)editor didFinishEditingWithImage:(UIImage*)image;
- (void)imageEditorDidCancel:(CLImageEditor*)editor;

// --Danish
- (void)imageEditor:(CLImageEditor*)editor didFinishEditingWithImage:(UIImage*)image withImageOptions:(NSDictionary*)imageProperty;

@end


@protocol CLImageEditorTransitionDelegate <CLImageEditorDelegate>
@optional
- (void)imageEditor:(CLImageEditor*)editor willDismissWithImageView:(UIImageView*)imageView canceled:(BOOL)canceled;
- (void)imageEditor:(CLImageEditor*)editor didDismissWithImageView:(UIImageView*)imageView canceled:(BOOL)canceled;

@end

