//
//  CLClippingTool.m
//
//  Created by sho yakushiji on 2013/10/18.
//  Copyright (c) 2013年 CALACULU. All rights reserved.
//

#import "CLClippingTool.h"
#import "Utilities.h"

static NSString* const kCLClippingToolRatios = @"ratios";
static NSString* const kCLClippingToolSwapButtonHidden = @"swapButtonHidden";
static NSString* const kCLClippingToolRotateIconName = @"rotateIconAssetsName";

static NSString* const kCLClippingToolRatioValue1 = @"value1";
static NSString* const kCLClippingToolRatioValue2 = @"value2";
static NSString* const kCLClippingToolRatioTitleFormat = @"titleFormat";


@interface CLRatio : NSObject
@property (nonatomic, assign) BOOL isLandscape;
@property (nonatomic, readonly) CGFloat ratio;
@property (nonatomic, strong) NSString *titleFormat;

- (id)initWithValue1:(CGFloat)value1 value2:(CGFloat)value2;

@end


@interface CLRatioMenuItem : CLToolbarMenuItem
@property (nonatomic, strong) CLRatio *ratio;
- (void)changeOrientation;
@end


@interface CLClippingPanel : UIView
@property (nonatomic, assign) CGRect clippingRect;
@property (nonatomic, weak) _CLImageEditorViewController *editor;
@property (nonatomic, strong) CLRatio *clippingRatio;
@property (nonatomic, assign) CGSize minRectSize;
- (id)initWithSuperview:(UIView*)superview frame:(CGRect)frame;
- (void)setNewGridFrame:(UIView*)superview frame:(CGRect)frame;
- (void)setBgColor:(UIColor*)bgColor;
- (void)setGridColor:(UIColor*)gridColor;
- (void)clippingRatioDidChange;
-(void)setAllViewHidden:(BOOL)hidden;
- (void)setBleedArea:(double)bleedAreaTop withBleedAreaBottom:(double)bleedAreaBottom withBleedAreaLeft:(double)bleedAreaLeft withBleedAreaRight:(double)bleedAreaRight;
-(void)setMinSize:(CGSize)minSize;
@end


#pragma mark- CLClippintTool

@interface CLClippingTool()
@property (nonatomic, strong) CLRatioMenuItem *selectedMenu;
@end

@implementation CLClippingTool
{
    CLClippingPanel *_gridView;
    
    UIView *_menuContainer;
    UIScrollView *_menuScroll;
}

+ (NSString*)defaultTitle
{
    return [CLImageEditorTheme localizedString:@"CLClippingTool_DefaultTitle" withDefault:@"Crop"];
}

+ (BOOL)isAvailable
{
    return YES;
}

#pragma mark- optional info

+ (NSArray*)defaultPresetRatios
{
    return @[
             @{kCLClippingToolRatioValue1:@0, kCLClippingToolRatioValue2:@0, kCLClippingToolRatioTitleFormat:[CLImageEditorTheme localizedString:@"CLClippingTool_ItemMenuCustom" withDefault:@"Custom"]},
             @{kCLClippingToolRatioValue1:@1, kCLClippingToolRatioValue2:@1, kCLClippingToolRatioTitleFormat:@"%g : %g"},
             @{kCLClippingToolRatioValue1:@4, kCLClippingToolRatioValue2:@3, kCLClippingToolRatioTitleFormat:@"%g : %g"},
             @{kCLClippingToolRatioValue1:@3, kCLClippingToolRatioValue2:@2, kCLClippingToolRatioTitleFormat:@"%g : %g"},
             @{kCLClippingToolRatioValue1:@16, kCLClippingToolRatioValue2:@9, kCLClippingToolRatioTitleFormat:@"%g : %g"},
              @{kCLClippingToolRatioValue1:@1280, kCLClippingToolRatioValue2:@2000, kCLClippingToolRatioTitleFormat:@"%g : %g"},
             ];
}

+ (NSValue*)defaultSwapButtonHidden
{
    return @(NO);
}

+ (NSDictionary*)optionalInfo
{
    return @{
             kCLClippingToolRatios:[self defaultPresetRatios],
             kCLClippingToolSwapButtonHidden:[self defaultSwapButtonHidden],
             kCLClippingToolRotateIconName:@""
             };
}

#pragma mark- implementation

- (void)setup
{
    //[self.editor fixZoomScaleWithAnimated:NO];

    if(self.editor.cropRect.size.width == self.editor.imageView.image.size.width && self.editor.cropRect.size.height == self.editor.imageView.image.size.height) {
        self.toolInfo.optionalInfo[kCLClippingToolRatios] = @[@{kCLClippingToolRatioValue1:@(self.editor.aspectRatio.width), kCLClippingToolRatioValue2:@(self.editor.aspectRatio.height), kCLClippingToolRatioTitleFormat:@"%g : %g"},];
    }
    else{
        self.toolInfo.optionalInfo[kCLClippingToolRatios] = @[@{kCLClippingToolRatioValue1:@(self.editor.cropRect.size.width), kCLClippingToolRatioValue2:@(self.editor.cropRect.size.height), kCLClippingToolRatioTitleFormat:@"%g : %g"},];
    }


//
//    self.toolInfo.optionalInfo[kCLClippingToolRatios] = @[                                                         @{kCLClippingToolRatioValue1:@0, kCLClippingToolRatioValue2:@0, kCLClippingToolRatioTitleFormat:[CLImageEditorTheme localizedString:@"CLClippingTool_ItemMenuCustom" withDefault:@"Custom"]},
//       @{kCLClippingToolRatioValue1:@(self.editor.aspectRatio.width), kCLClippingToolRatioValue2:@(self.editor.aspectRatio.height), kCLClippingToolRatioTitleFormat:@"%g : %g"},];

    if(!self.toolInfo.optionalInfo){
        self.toolInfo.optionalInfo = [[self.class optionalInfo] mutableCopy];
    }
    
    BOOL swapBtnHidden = [self.toolInfo.optionalInfo[kCLClippingToolSwapButtonHidden] boolValue];
    CGFloat buttonWidth = (swapBtnHidden) ? 0 : 70;
    
    _menuContainer = [[UIView alloc] initWithFrame:self.editor.menuView.frame];
    _menuContainer.backgroundColor = self.editor.menuView.backgroundColor;
    [self.editor.view addSubview:_menuContainer];

    // -- Danish
    _menuScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(buttonWidth+15, 0, _menuContainer.width - (buttonWidth+15), _menuContainer.height)];
    _menuScroll.backgroundColor = [UIColor clearColor];
    _menuScroll.showsHorizontalScrollIndicator = NO;
    _menuScroll.clipsToBounds = NO;
    _menuScroll.hidden = YES;
    _menuContainer.hidden = YES;
    [_menuContainer addSubview:_menuScroll];
    
    if(!swapBtnHidden){
        UIView *btnPanel = [[UIView alloc] initWithFrame:CGRectMake(5, 0.5, buttonWidth+10, _menuContainer.height)];
        btnPanel.backgroundColor = [_menuContainer.backgroundColor colorWithAlphaComponent:1.0];
        [_menuContainer addSubview:btnPanel];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 40, 40);
        btn.center = CGPointMake(btnPanel.width/2, btnPanel.height/2 - 10);
        [btn addTarget:self action:@selector(pushedRotateBtn:) forControlEvents:UIControlEventTouchUpInside];
        [btn setImage:[self imageForKey:kCLClippingToolRotateIconName defaultImageName:@"btn_rotate.png"] forState:UIControlStateNormal];
        btn.adjustsImageWhenHighlighted = YES;

        UILabel* _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, btn.bottom, buttonWidth, 15)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [CLImageEditorTheme toolbarTextColor];
        _titleLabel.font = [self.editor.boldFont fontWithSize:10.0];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = @"ORIENTATION";
        [btnPanel addSubview:btn];
        [btnPanel addSubview:_titleLabel];
    }

//    if ([self.editor.imageView subviews].count > 0) {
//        _gridView = [[self.editor.imageView subviews] objectAtIndex:0];
//        [_gridView setHidden:NO];
//
//        [_gridView setNewGridFrame:self.editor.imageView frame:self.editor.imageView.bounds];
//    }
//    else{
        _gridView = [[CLClippingPanel alloc] initWithSuperview:self.editor.imageView frame:self.editor.imageView.bounds];
        _gridView.editor = self.editor;
   // }

    _gridView.backgroundColor = [UIColor clearColor];
    _gridView.bgColor = [self.editor.view.backgroundColor colorWithAlphaComponent:0.7];
    // -- Danish
    _gridView.gridColor = [UIColor colorWithRed:236.0/255.0 green:242.0/255.0 blue:246.0/255.0 alpha:0.7];

    _gridView.clipsToBounds = YES;
    [_gridView setAllViewHidden:YES];

    if (self.editor.isBleedAreaShow) {
      //  CGFloat zoomScale = self.editor.imageWidth / self.editor.imageView.image.size.width;
      //  [_gridView setBleedArea:(self.editor.bleedAreaX * zoomScale) withBleedAreaY:(self.editor.bleedAreaY * zoomScale)];
       // [_gridView setBleedArea:(self.editor.clBleedArea.bleedAreaTop * zoomScale) withBleedAreaBottom:(self.editor.clBleedArea.bleedAreaBottom * zoomScale) withBleedAreaLeft:(self.editor.clBleedArea.bleedAreaLeft * zoomScale) withBleedAreaRight:(self.editor.clBleedArea.bleedAreaRight * zoomScale)];

         [_gridView setBleedArea:(self.editor.clBleedArea.bleedAreaTop) withBleedAreaBottom:(self.editor.clBleedArea.bleedAreaBottom) withBleedAreaLeft:(self.editor.clBleedArea.bleedAreaLeft) withBleedAreaRight:(self.editor.clBleedArea.bleedAreaRight)];
    }

    [_gridView setMinSize: CGSizeMake(self.editor.minRectSize.width, self.editor.minRectSize.height)];

   // _gridView.hidden = YES;
    [self setCropMenu];

    _menuContainer.transform = CGAffineTransformMakeTranslation(0, self.editor.view.height-_menuScroll.top);
    [UIView animateWithDuration:kCLImageToolAnimationDuration
                     animations:^{
                         _menuContainer.transform = CGAffineTransformIdentity;
                     }];

    [UIView animateWithDuration:kCLImageToolAnimationDuration
                     animations:^{
                         if(self.editor.cropRect.size.width != self.editor.imageView.image.size.width || self.editor.cropRect.size.height != self.editor.imageView.image.size.height) {
                              [self setCropRect];
                         }
                         [self performSelector:@selector(showGridView) withObject:nil afterDelay:0.2];
                     }];


}

-(void) showGridView {
//     _gridView.hidden = NO;
//    _gridView.clippingRect
    [_gridView setAllViewHidden:NO];
}

- (void)setCropRect
{
    CGFloat zoomScale = self.editor.imageWidth / self.editor.imageView.image.size.width; //self.editor.imageView.width
    CGRect rct = self.editor.cropRect;//utilities.cropRect;

    rct.size.width  *= zoomScale;
    rct.size.height *= zoomScale;
    rct.origin.x    *= zoomScale;
    rct.origin.y    *= zoomScale;

    if (self.editor.isBleedAreaShow) {
        if (!self.editor.isCropingFirstTime) {

            //Right
            rct.size.width += (self.editor.bleedAreaRightByPercentage / 1);
            rct.size.width += (self.editor.bleedAreaLeftByPercentage / 1);

            //Bottom
            rct.size.height += (self.editor.bleedAreaTopByPercentage / 1);
            rct.size.height += (self.editor.bleedAreaBottomByPercentage / 1);

            //Left
            rct.origin.x -= (self.editor.bleedAreaLeftByPercentage / 1);

            //Top
            rct.origin.y -= (self.editor.bleedAreaTopByPercentage / 1);
        }
    }

    [_gridView setClippingRect:rct];

}

- (void)executeWithCompletionBlock:(void (^)(UIImage *, NSError *, NSDictionary *))completionBlock
{
    CGFloat zoomScale = self.editor.imageWidth / self.editor.imageView.image.size.width;
    CGRect rct = _gridView.clippingRect;
    self.editor.isCropingFirstTime = NO;
    if (self.editor.isBleedAreaShow) {

        self.editor.bleedAreaLeftByPercentage = (rct.size.width * self.editor.clBleedArea.bleedAreaLeft);
        self.editor.bleedAreaRightByPercentage = (rct.size.width * self.editor.clBleedArea.bleedAreaRight);
        self.editor.bleedAreaTopByPercentage = (rct.size.height * self.editor.clBleedArea.bleedAreaTop);
        self.editor.bleedAreaBottomByPercentage = (rct.size.height * self.editor.clBleedArea.bleedAreaBottom);

        //Right Bleed
        rct.size.width -= (self.editor.bleedAreaRightByPercentage / 1);
        rct.size.width -= (self.editor.bleedAreaLeftByPercentage / 1);

        //Bottom Bleed
        rct.size.height -= (self.editor.bleedAreaTopByPercentage / 1);
        rct.size.height -= (self.editor.bleedAreaBottomByPercentage / 1);

        //Left
        rct.origin.x += (self.editor.bleedAreaLeftByPercentage / 1);

        //Top
        rct.origin.y += (self.editor.bleedAreaTopByPercentage / 1);

    }
    rct.size.width  /= zoomScale;
    rct.size.height /= zoomScale;
    rct.origin.x    /= zoomScale;
    rct.origin.y    /= zoomScale;

    self.editor.cropRect = rct;
    
    UIImage *result = [self.editor.imageView.image crop:rct];

    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:[NSNumber numberWithBool:YES] forKey:@"Crop"];

    self.editor.imageView.contentMode = UIViewContentModeScaleAspectFit;

    completionBlock(result, nil, dic);
}

- (void)cleanup
{
    // [self.editor resetZoomScaleWithAnimated:YES];
    [_gridView removeFromSuperview];
    //   [_gridView setHidden:YES];
    [UIView animateWithDuration:kCLImageToolAnimationDuration
                     animations:^{
                         _menuContainer.transform = CGAffineTransformMakeTranslation(0, self.editor.view.height-_menuScroll.top);
                     }
                     completion:^(BOOL finished) {
                         [_menuContainer removeFromSuperview];
                     }];
}

#pragma mark-

- (void)setCropMenu
{
    CGFloat W = 70;
    CGFloat x = 0;

    NSArray *ratios = self.toolInfo.optionalInfo[kCLClippingToolRatios];
    BOOL swapBtnHidden = [self.toolInfo.optionalInfo[kCLClippingToolSwapButtonHidden] boolValue];
    
    CGSize  imgSize = self.editor.imageView.image.size;
    CGFloat maxW = MIN(imgSize.width, imgSize.height);
    UIImage *iconImage = [self.editor.imageView.image resize:CGSizeMake(W * imgSize.width/maxW, W * imgSize.height/maxW)];
    
    for(NSDictionary *info in ratios){
        CGFloat val1 = [info[kCLClippingToolRatioValue1] floatValue];
        CGFloat val2 = [info[kCLClippingToolRatioValue2] floatValue];
        
        CLRatio *ratio = [[CLRatio alloc] initWithValue1:val1 value2:val2];
        ratio.titleFormat = info[kCLClippingToolRatioTitleFormat];
        
        if(swapBtnHidden){
            ratio.isLandscape = (val1 > val2);
        }
        else{
            ratio.isLandscape = (imgSize.width > imgSize.height);
        }
        
        CLRatioMenuItem *view = [[CLRatioMenuItem alloc] initWithFrame:CGRectMake(x, 0, W, _menuScroll.height) target:self action:@selector(tappedMenu:) toolInfo:nil];

        view.iconImage = iconImage;
        view.ratio = ratio;
        [view setTitleFrame:CGRectMake(view.getTitleFrame.origin.x, view.getTitleFrame.origin.y+12, view.getTitleFrame.size.width, view.getTitleFrame.size.height)];
        
        if(ratios.count>1 || !swapBtnHidden){
            [_menuScroll addSubview:view];
            x += W;
        }
        
        if(self.selectedMenu==nil){
            self.selectedMenu = view;
        }
    }
    _menuScroll.contentSize = CGSizeMake(MAX(x, _menuScroll.frame.size.width+1), 0);
}

- (void)tappedMenu:(UITapGestureRecognizer*)sender
{
    CLRatioMenuItem *view = (CLRatioMenuItem*)sender.view;
    
    view.alpha = 0.2;
    [UIView animateWithDuration:kCLImageToolAnimationDuration
                     animations:^{
                         view.alpha = 1;
                     }
     ];
    
    self.selectedMenu = view;
}

- (void)setSelectedMenu:(CLRatioMenuItem *)selectedMenu
{
    if(selectedMenu != _selectedMenu){
        _selectedMenu.backgroundColor = [UIColor clearColor];
        _selectedMenu = selectedMenu;
        _selectedMenu.backgroundColor = [CLImageEditorTheme toolbarSelectedButtonColor];
        
        if(selectedMenu.ratio.ratio==0){
            _gridView.clippingRatio = nil;
        }
        else{
            _gridView.clippingRatio = selectedMenu.ratio;
        }
    }
}

- (void)pushedRotateBtn:(UIButton*)sender
{
    for(CLRatioMenuItem *item in _menuScroll.subviews){
        if([item isKindOfClass:[CLRatioMenuItem class]]){
            [item changeOrientation];
        }
    }
    
    if(_gridView.clippingRatio.ratio!=0 && _gridView.clippingRatio.ratio!=1){
        [_gridView clippingRatioDidChange];
    }
}

@end


#pragma mark- UI components

@interface CLClippingCircle : UIView

@property (nonatomic, strong) UIColor *bgColor;

@end

@implementation CLClippingCircle

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect rct = self.bounds;
    rct.origin.x = rct.size.width/2-rct.size.width/6;
    rct.origin.y = rct.size.height/2-rct.size.height/6;
    rct.size.width /= 3;
    rct.size.height /= 3;
    
    CGContextSetFillColorWithColor(context, self.bgColor.CGColor);
    CGContextFillEllipseInRect(context, rct);
}

@end

@interface CLGridLayar : CALayer
@property (nonatomic, assign) CGRect clippingRect;
@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, strong) UIColor *gridColor;
@property (nonatomic, assign) double bleedAreaTop;
@property (nonatomic, assign) double bleedAreaBottom;
@property (nonatomic, assign) double bleedAreaLeft;
@property (nonatomic, assign) double bleedAreaRight;
@property (nonatomic, assign) bool isBleedAreaShow;
@end

@implementation CLGridLayar

+ (BOOL)needsDisplayForKey:(NSString*)key
{
    if ([key isEqualToString:@"clippingRect"]) {
        return YES;
    }
    return [super needsDisplayForKey:key];
}

- (id)initWithLayer:(id)layer
{
    self = [super initWithLayer:layer];
    if(self && [layer isKindOfClass:[CLGridLayar class]]){
        self.bgColor   = ((CLGridLayar*)layer).bgColor;
        self.gridColor = ((CLGridLayar*)layer).gridColor;
        self.clippingRect = ((CLGridLayar*)layer).clippingRect;
        self.bleedAreaTop = 0.0;
        self.bleedAreaBottom = 0.0;
        self.bleedAreaRight = 0.0;
        self.bleedAreaLeft = 0.0;
        self.isBleedAreaShow = NO;
    }
    return self;
}

- (void)drawInContext:(CGContextRef)context
{
    CGRect rct = self.bounds;
    CGContextSetFillColorWithColor(context, self.bgColor.CGColor);
    CGContextFillRect(context, rct);
    
    CGContextClearRect(context, _clippingRect);
    
    CGContextSetStrokeColorWithColor(context, self.gridColor.CGColor);
    CGContextSetLineWidth(context, 1);

    rct = self.clippingRect;
    
    CGContextBeginPath(context);
    CGFloat dW = 0;
    for(int i=0;i<4;++i){
        CGContextMoveToPoint(context, rct.origin.x+dW, rct.origin.y);
        CGContextAddLineToPoint(context, rct.origin.x+dW, rct.origin.y+rct.size.height);
        dW += _clippingRect.size.width/3;
    }
    
    dW = 0;
    for(int i=0;i<4;++i){
        CGContextMoveToPoint(context, rct.origin.x, rct.origin.y+dW);
        CGContextAddLineToPoint(context, rct.origin.x+rct.size.width, rct.origin.y+dW);
        dW += rct.size.height/3;
    }
    CGContextStrokePath(context);


// TODO - Danish - Bleed Image

    if (self.isBleedAreaShow) {
        rct = self.bounds;
        CGContextSetFillColorWithColor(context, self.bgColor.CGColor);
        CGContextFillRect(context, rct);

        CGContextClearRect(context, _clippingRect);

        CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:217.0/255.0 green:83.0/255.0 blue:79.0/255.0 alpha:0.7].CGColor);
        CGContextSetBlendMode(context, kCGBlendModeOverlay);
       // CGContextSetGrayStrokeColor(context, 1.0, 0.5);
        rct = self.clippingRect;

        // For X Bleed Area = LEFT and RIGHT

        double bleedAreaLeftByPercentage = (rct.size.width * self.bleedAreaLeft);
        double bleedAreaRightByPercentage = (rct.size.width * self.bleedAreaRight);

        //CGContextSetLineWidth(context, (self.bleedAreaLeft / 2));
        CGContextSetLineWidth(context, (bleedAreaLeftByPercentage / 1));
        CGContextBeginPath(context);
        dW = 0;
        //LEFT
        if (self.bleedAreaLeft > 0.0) {
          //  CGContextMoveToPoint(context, rct.origin.x+dW  + (self.bleedAreaLeft/4), rct.origin.y);
          //  CGContextAddLineToPoint(context, rct.origin.x+dW  + (self.bleedAreaLeft/4), rct.origin.y+rct.size.height);

            CGContextMoveToPoint(context, rct.origin.x+dW  + (bleedAreaLeftByPercentage/2), rct.origin.y);
            CGContextAddLineToPoint(context, rct.origin.x+dW  + (bleedAreaLeftByPercentage/2), rct.origin.y+rct.size.height);
        }
        CGContextStrokePath(context);
        CGContextClosePath(context);


         //RIGHT
        CGContextSetLineWidth(context, (bleedAreaRightByPercentage / 1));
        CGContextBeginPath(context);

        if (self.bleedAreaRight > 0.0) {
            for(int i=0;i<3;++i){
                dW += _clippingRect.size.width/3;
            }
            CGContextMoveToPoint(context, rct.origin.x+dW - (bleedAreaRightByPercentage/2), rct.origin.y);
            CGContextAddLineToPoint(context, rct.origin.x+dW - (bleedAreaRightByPercentage/2), rct.origin.y+rct.size.height);
        }

        CGContextStrokePath(context);
        CGContextClosePath(context);


        // For Y Bleed Area = TOP and BOTTOM

        // TOP

        double bleedAreaTopByPercentage = (rct.size.height * self.bleedAreaTop);
        double bleedAreaBottomByPercentage = (rct.size.height * self.bleedAreaBottom);

         CGContextSetLineWidth(context, (bleedAreaTopByPercentage / 1));
       // CGContextSetLineWidth(context, (self.bleedAreaTop / 2));
        CGContextBeginPath(context);
        dW = 0;
        if (self.bleedAreaTop > 0.0) {
//            CGContextMoveToPoint(context, rct.origin.x, rct.origin.y+dW + (self.bleedAreaTop/4));
//            CGContextAddLineToPoint(context, rct.origin.x+rct.size.width, rct.origin.y+dW +(self.bleedAreaTop/4));

            CGContextMoveToPoint(context, rct.origin.x, rct.origin.y+dW + (bleedAreaTopByPercentage/2));
            CGContextAddLineToPoint(context, rct.origin.x+rct.size.width, rct.origin.y+dW +(bleedAreaTopByPercentage/2));
        }
        CGContextStrokePath(context);
        CGContextClosePath(context);

        // BOTTOM
        CGContextSetLineWidth(context, (bleedAreaBottomByPercentage / 1));
        CGContextBeginPath(context);

        if (self.bleedAreaBottom > 0.0) {
            for(int i=0;i<3;++i){
                dW += rct.size.height/3;
            }
            CGContextMoveToPoint(context, rct.origin.x, rct.origin.y+dW - (bleedAreaBottomByPercentage/2));
            CGContextAddLineToPoint(context, rct.origin.x+rct.size.width, rct.origin.y+dW - (bleedAreaBottomByPercentage/2));
        }

        CGContextStrokePath(context);
        CGContextClosePath(context);

    }
}

@end

@implementation CLClippingPanel
{
    CLGridLayar *_gridLayer;
    CLClippingCircle *_ltView;
    CLClippingCircle *_lbView;
    CLClippingCircle *_rtView;
    CLClippingCircle *_rbView;
}

- (CLClippingCircle*)clippingCircleWithTag:(NSInteger)tag
{
    CLClippingCircle *view = [[CLClippingCircle alloc] initWithFrame:CGRectMake(0, 0, 75, 75)];
    view.backgroundColor = [UIColor clearColor];
    view.bgColor = [UIColor blackColor];
    view.tag = tag;
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panCircleView:)];
    [view addGestureRecognizer:panGesture];
    
    [self.superview addSubview:view];
    
    return view;
}

- (id)initWithSuperview:(UIView*)superview frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){

        superview.userInteractionEnabled = YES;
        //Utilities *utilities = [Utilities sharedUtilities];
       // self.layer.transform = [utilities getTransfromImage];

         [superview addSubview:self];

      //  self.transform = CGAffineTransformMakeRotation((utilities.angle) * M_PI/180);
        
        _gridLayer = [[CLGridLayar alloc] init];
        _gridLayer.frame = self.bounds;
        _gridLayer.bgColor   = [UIColor colorWithWhite:1 alpha:0.6];
        _gridLayer.gridColor = [UIColor colorWithWhite:0 alpha:0.6];
        _gridLayer.isBleedAreaShow = NO;
        _gridLayer.bleedAreaTop = 0.0;
        _gridLayer.bleedAreaBottom = 0.0;
        _gridLayer.bleedAreaRight = 0.0;
        _gridLayer.bleedAreaLeft = 0.0;

        [self.layer addSublayer:_gridLayer];
        
        _ltView = [self clippingCircleWithTag:0];
        _lbView = [self clippingCircleWithTag:1];
        _rtView = [self clippingCircleWithTag:2];
        _rbView = [self clippingCircleWithTag:3];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGridView:)];
        [self addGestureRecognizer:panGesture];
        
        self.clippingRect = self.bounds;
    }
    return self;
}

-(void)setNewGridFrame:(UIView*)superview frame:(CGRect)frame
{
        superview.userInteractionEnabled = YES;

        self.frame = frame;
        //_gridLayer.frame = self.bounds;
    
        //self.clippingRect = self.bounds;

}

-(void)setAllViewHidden:(BOOL)hidden
{
    _gridLayer.hidden = hidden;
    _ltView.hidden = hidden;
    _lbView.hidden = hidden;
    _rtView.hidden = hidden;
    _rbView.hidden = hidden;
}

- (void)removeFromSuperview
{
    [super removeFromSuperview];
    
    [_ltView removeFromSuperview];
    [_lbView removeFromSuperview];
    [_rtView removeFromSuperview];
    [_rbView removeFromSuperview];
}

- (void)setBgColor:(UIColor *)bgColor
{
    _gridLayer.bgColor = bgColor;
}

- (void)setGridColor:(UIColor *)gridColor
{
    _gridLayer.gridColor = gridColor;
    _ltView.bgColor = _lbView.bgColor = _rtView.bgColor = _rbView.bgColor = [gridColor colorWithAlphaComponent:1];
}

- (void)setClippingRect:(CGRect)clippingRect
{
    _clippingRect = clippingRect;
    
    _ltView.center = [self.superview convertPoint:CGPointMake(_clippingRect.origin.x, _clippingRect.origin.y) fromView:self];
    _lbView.center = [self.superview convertPoint:CGPointMake(_clippingRect.origin.x, _clippingRect.origin.y+_clippingRect.size.height) fromView:self];
    _rtView.center = [self.superview convertPoint:CGPointMake(_clippingRect.origin.x+_clippingRect.size.width, _clippingRect.origin.y) fromView:self];
    _rbView.center = [self.superview convertPoint:CGPointMake(_clippingRect.origin.x+_clippingRect.size.width, _clippingRect.origin.y+_clippingRect.size.height) fromView:self];
    
    _gridLayer.clippingRect = clippingRect;

    [self setNeedsDisplay];
}

- (void)setBleedArea:(double)bleedAreaTop withBleedAreaBottom:(double)bleedAreaBottom withBleedAreaLeft:(double)bleedAreaLeft withBleedAreaRight:(double)bleedAreaRight
{
    _gridLayer.isBleedAreaShow = YES;
    _gridLayer.bleedAreaTop = bleedAreaTop;
    _gridLayer.bleedAreaBottom = bleedAreaBottom;
    _gridLayer.bleedAreaRight = bleedAreaRight;
    _gridLayer.bleedAreaLeft = bleedAreaLeft;
}

-(void)setMinSize:(CGSize)minSize
{
    _minRectSize = minSize;
}

- (void)setClippingRect:(CGRect)clippingRect animated:(BOOL)animated
{
    if(animated){
        [UIView animateWithDuration:kCLImageToolFadeoutDuration
                         animations:^{
                             _ltView.center = [self.superview convertPoint:CGPointMake(clippingRect.origin.x, clippingRect.origin.y) fromView:self];
                             _lbView.center = [self.superview convertPoint:CGPointMake(clippingRect.origin.x, clippingRect.origin.y+clippingRect.size.height) fromView:self];
                             _rtView.center = [self.superview convertPoint:CGPointMake(clippingRect.origin.x+clippingRect.size.width, clippingRect.origin.y) fromView:self];
                             _rbView.center = [self.superview convertPoint:CGPointMake(clippingRect.origin.x+clippingRect.size.width, clippingRect.origin.y+clippingRect.size.height) fromView:self];
                         }
         ];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"clippingRect"];
        animation.duration = kCLImageToolFadeoutDuration;
        animation.fromValue = [NSValue valueWithCGRect:_clippingRect];
        animation.toValue = [NSValue valueWithCGRect:clippingRect];
        [_gridLayer addAnimation:animation forKey:nil];
        
        _gridLayer.clippingRect = clippingRect;
        _clippingRect = clippingRect;
        [self setNeedsDisplay];
    }
    else{
        self.clippingRect = clippingRect;
    }
}

- (void)clippingRatioDidChange
{
    CGRect rect = self.bounds;
    if(self.clippingRatio){
        CGFloat H = rect.size.width * self.clippingRatio.ratio;
        if(H<=rect.size.height){
            rect.size.height = H;
        }
        else{
            rect.size.width *= rect.size.height / H;
        }
        
        rect.origin.x = (self.bounds.size.width - rect.size.width) / 2;
        rect.origin.y = (self.bounds.size.height - rect.size.height) / 2;
    }
    [self setClippingRect:rect animated:YES];
}

- (void)setClippingRatio:(CLRatio *)clippingRatio
{
    if(clippingRatio != _clippingRatio){
        _clippingRatio = clippingRatio;
        [self clippingRatioDidChange];
    }
}

- (void)setNeedsDisplay
{
    [super setNeedsDisplay];
    [_gridLayer setNeedsDisplay];
}

- (void)panCircleView:(UIPanGestureRecognizer*)sender
{
    CGPoint point = [sender locationInView:self];
    CGPoint dp = [sender translationInView:self];
    
    CGRect rct = self.clippingRect;
    
    const CGFloat W = self.frame.size.width;
    const CGFloat H = self.frame.size.height;
    CGFloat minX = 0;
    CGFloat minY = 0;
    CGFloat maxX = W;
    CGFloat maxY = H;
    
    CGFloat ratio = (sender.view.tag == 1 || sender.view.tag==2) ? -self.clippingRatio.ratio : self.clippingRatio.ratio;
    
    switch (sender.view.tag) {
        case 0: // upper left
        {
            maxX = MAX((rct.origin.x + rct.size.width)  - 0.1 * W, 0.1 * W);
            maxY = MAX((rct.origin.y + rct.size.height) - 0.1 * H, 0.1 * H);
            
            if(ratio!=0){
                CGFloat y0 = rct.origin.y - ratio * rct.origin.x;
                CGFloat x0 = -y0 / ratio;
                minX = MAX(x0, 0);
                minY = MAX(y0, 0);
                
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
                
                if(-dp.x*ratio + dp.y > 0){ point.x = (point.y - y0) / ratio; }
                else{ point.y = point.x * ratio + y0; }
            }
            else{
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
            }
            
            rct.size.width  = rct.size.width  - (point.x - rct.origin.x);
            rct.size.height = rct.size.height - (point.y - rct.origin.y);
            rct.origin.x = point.x;
            rct.origin.y = point.y;
            break;
        }
        case 1: // lower left
        {
            maxX = MAX((rct.origin.x + rct.size.width)  - 0.1 * W, 0.1 * W);
            minY = MAX(rct.origin.y + 0.1 * H, 0.1 * H);
            
            if(ratio!=0){
                CGFloat y0 = (rct.origin.y + rct.size.height) - ratio* rct.origin.x ;
                CGFloat xh = (H - y0) / ratio;
                minX = MAX(xh, 0);
                maxY = MIN(y0, H);
                
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
                
                if(-dp.x*ratio + dp.y < 0){ point.x = (point.y - y0) / ratio; }
                else{ point.y = point.x * ratio + y0; }
            }
            else{
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
            }
            
            rct.size.width  = rct.size.width  - (point.x - rct.origin.x);
            rct.size.height = point.y - rct.origin.y;
            rct.origin.x = point.x;
            break;
        }
        case 2: // upper right
        {
            minX = MAX(rct.origin.x + 0.1 * W, 0.1 * W);
            maxY = MAX((rct.origin.y + rct.size.height) - 0.1 * H, 0.1 * H);
            
            if(ratio!=0){
                CGFloat y0 = rct.origin.y - ratio * (rct.origin.x + rct.size.width);
                CGFloat yw = ratio * W + y0;
                CGFloat x0 = -y0 / ratio;
                maxX = MIN(x0, W);
                minY = MAX(yw, 0);
                
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
                
                if(-dp.x*ratio + dp.y > 0){ point.x = (point.y - y0) / ratio; }
                else{ point.y = point.x * ratio + y0; }
            }
            else{
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
            }
            
            rct.size.width  = point.x - rct.origin.x;
            rct.size.height = rct.size.height - (point.y - rct.origin.y);
            rct.origin.y = point.y;
            break;
        }
        case 3: // lower right
        {
            minX = MAX(rct.origin.x + 0.1 * W, 0.1 * W);
            minY = MAX(rct.origin.y + 0.1 * H, 0.1 * H);
            
            if(ratio!=0){
                CGFloat y0 = (rct.origin.y + rct.size.height) - ratio * (rct.origin.x + rct.size.width);
                CGFloat yw = ratio * W + y0;
                CGFloat xh = (H - y0) / ratio;
                maxX = MIN(xh, W);
                maxY = MIN(yw, H);
                
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
                
                if(-dp.x*ratio + dp.y < 0){ point.x = (point.y - y0) / ratio; }
                else{ point.y = point.x * ratio + y0; }
            }
            else{
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
            }
            
            rct.size.width  = point.x - rct.origin.x;
            rct.size.height = point.y - rct.origin.y;
            break;
        }
        default:
            break;
    }
    // Danish: Minimum Rect Size
    if (rct.size.width > self.minRectSize.width || rct.size.height > self.minRectSize.height) {
          self.clippingRect = rct;
    }
}

- (void)panGridView:(UIPanGestureRecognizer*)sender
{
    static BOOL dragging = NO;
    static CGRect initialRect;
    
    if(sender.state==UIGestureRecognizerStateBegan){
        CGPoint point = [sender locationInView:self];
        dragging = CGRectContainsPoint(_clippingRect, point);
        initialRect = self.clippingRect;
    }
    else if(dragging){
        CGPoint point = [sender translationInView:self];
        CGFloat left  = MIN(MAX(initialRect.origin.x + point.x, 0), self.frame.size.width-initialRect.size.width);
        CGFloat top   = MIN(MAX(initialRect.origin.y + point.y, 0), self.frame.size.height-initialRect.size.height);
        
        CGRect rct = self.clippingRect;
        rct.origin.x = left;
        rct.origin.y = top;
        self.clippingRect = rct;
    }
}
@end




@implementation CLRatio
{
    CGFloat _longSide;
    CGFloat _shortSide;
}

- (id)initWithValue1:(CGFloat)value1 value2:(CGFloat)value2
{
    self = [super init];
    if(self){
        _longSide  = fabs(value1); // MAX(fabs(value1), fabs(value2));
        _shortSide = fabs(value2); //MIN(fabs(value1), fabs(value2));
    }
    return self;
}

- (NSString*)description
{
    NSString *format = (self.titleFormat) ? self.titleFormat : @"%g : %g";
    
    if(self.isLandscape){
        return [NSString stringWithFormat:format, _longSide, _shortSide];
    }
    return [NSString stringWithFormat:format, _shortSide, _longSide];
}

- (CGFloat)ratio
{
    if(_longSide==0 || _shortSide==0){
        return 0;
    }
    
    if(self.isLandscape){
        return _shortSide / (CGFloat)_longSide;
    }
    return _longSide / (CGFloat)_shortSide;
}

@end


@implementation CLRatioMenuItem

- (void)setRatio:(CLRatio *)ratio
{
    if(ratio != _ratio){
        _ratio = ratio;
        [self refreshViews];
    }
}

- (void)refreshViews
{
    _titleLabel.text = [_ratio description];
    
    CGPoint center = _iconView.center;
    CGFloat W, H;
    if(_ratio.ratio!=0){
        if(_ratio.isLandscape){
            W = 50;
            H = 50*_ratio.ratio;
        }
        else{
            W = 50/_ratio.ratio;
            H = 50;
        }
    }
    else{
        CGFloat maxW  = MAX(_iconView.image.size.width, _iconView.image.size.height);
        W = 50 * _iconView.image.size.width / maxW;
        H = 50 * _iconView.image.size.height / maxW;
    }
    _iconView.frame = CGRectMake(center.x-W/2, center.y-H/2, W, H);
}

- (void)changeOrientation
{
    self.ratio.isLandscape = !self.ratio.isLandscape;
    
    [UIView animateWithDuration:kCLImageToolFadeoutDuration
                     animations:^{
                         [self refreshViews];
                     }
     ];
}

@end
