//
//  _CLImageEditorViewController.h
//
//  Created by sho yakushiji on 2013/11/05.
//  Copyright (c) 2013年 CALACULU. All rights reserved.
//

#import "CLImageEditor.h"

@interface _CLImageEditorViewController : CLImageEditor
<UIScrollViewDelegate, UIBarPositioningDelegate>
{
    IBOutlet __weak UINavigationBar *_navigationBar;
    IBOutlet __weak UIScrollView *_scrollView;
}
@property (nonatomic, strong) UIImageView  *imageView;
@property (nonatomic, weak) IBOutlet UIScrollView *menuView;
@property (nonatomic, readonly) UIScrollView *scrollView;

// -- Danish : orignal Image width and image frame
@property (nonatomic, assign) float imageWidth;
@property (nonatomic, assign) CGRect imageFrame;

// Crop Rect and angle
@property (nonatomic, assign) CGRect cropRect;
@property (nonatomic, assign) double angle;

// font
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIFont *boldFont;

- (IBAction)pushedCloseBtn:(id)sender;
- (IBAction)pushedFinishBtn:(id)sender;


- (id)initWithImage:(UIImage*)image;


- (void)fixZoomScaleWithAnimated:(BOOL)animated;
- (void)resetZoomScaleWithAnimated:(BOOL)animated;

@end
