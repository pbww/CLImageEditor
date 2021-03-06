//
//  _CLImageEditorViewController.m
//
//  Created by sho yakushiji on 2013/11/05.
//  Copyright (c) 2013年 CALACULU. All rights reserved.
//

#import "_CLImageEditorViewController.h"

#import "CLImageToolBase.h"
#import "CLClippingTool.h"
#import "Utilities.h"
#import "CLRotateTool.h"

#pragma mark- _CLImageEditorViewController

static const CGFloat kNavBarHeight = 44.0f;
static const CGFloat kMenuBarHeight = 80.0f;

@interface _CLImageEditorViewController()
<CLImageToolProtocol, UINavigationBarDelegate>
@property (nonatomic, strong) CLImageToolBase *currentTool;
@property (nonatomic, strong, readwrite) CLImageToolInfo *toolInfo;
@property (nonatomic, strong) UIImageView *targetImageView;
@end


@implementation _CLImageEditorViewController
{
    UIImage *_originalImageReset;
    UIImage *_originalImage;
    UIImage *_tempImage;
    UIView *_bgView;
    CATransform3D _lastTransform;
}
@synthesize toolInfo = _toolInfo, clBleedArea = _clBleedArea;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.toolInfo = [CLImageToolInfo toolInfoForToolClass:[self class]];
    }
    return self;
}

- (id)init
{
    self = [self initWithNibName:nil bundle:nil];
    if (self){
        self.clBleedArea = [[CLBleedArea alloc] init];
        if (_font != nil) {

            [[CLImageEditorTheme theme] setFont:_boldFont];
            NSDictionary *barButtonAppearanceDict = @{NSFontAttributeName : _font, NSForegroundColorAttributeName: [UIColor colorWithRed:68.0/255.0 green:128.0/255.0 blue:170.0/255.0 alpha:1.0]};
            [[UIBarButtonItem appearance] setTitleTextAttributes:barButtonAppearanceDict forState:UIControlStateNormal];


            [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                                   NSForegroundColorAttributeName: [UIColor colorWithRed:74.0/255.0  green:74.0/255.0  blue:74.0/255.0  alpha:1.0],
                                                                   NSFontAttributeName: _boldFont
                                                                   }];
        }
    }
    return self;
}   

- (id)initWithImage:(UIImage *)image
{
    return [self initWithImage:image delegate:nil];
}

- (id)initWithImage:(UIImage*)image delegate:(id<CLImageEditorDelegate>)delegate
{
    self = [self init];
    if (self){
        _originalImage = [image deepCopy];
        _originalImageReset = [image deepCopy];
        self.delegate = delegate;
        _angle = 0.0;
        _cropRect = CGRectMake(0, 0, _originalImageReset.size.width,_originalImageReset.size.height);
        _trimRect = CGRectMake(0, 0, _originalImageReset.size.width,_originalImageReset.size.height);

        if (_contentMode != NULL){
            UIViewContentMode contentMode = [[NSNumber numberWithInt:UIViewContentModeScaleAspectFit] intValue];
            _contentMode = &contentMode;
        }

        if ([_imageProperty objectForKey:CONTENTMODE] != nil) {
            _imageView.contentMode = [[_imageProperty objectForKey:CONTENTMODE] intValue];
        }
        else {
            _imageView.contentMode = UIViewContentModeScaleAspectFit;
        }

    }
    return self;
}

- (id)initWithImage:(UIImage*)image delegate:(id<CLImageEditorDelegate>)delegate withOptions:(NSDictionary*)imageProperty
{
    _imageProperty = [[NSMutableDictionary alloc] initWithDictionary: imageProperty];

    if ([imageProperty objectForKey:FONT] != nil) {
        _font = [imageProperty objectForKey:FONT];
    } else {
        _font = [UIFont fontWithName:@"HelveticaNeue-Regular" size:18.0];
    }

    if ([imageProperty objectForKey:BOLDFONT] != nil) {
        _boldFont = [imageProperty objectForKey:BOLDFONT];
    } else {
        _boldFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0];
    }

    self = [self init];
    if (self){
        _originalImage = [image deepCopy];
        _originalImageReset = [image deepCopy];
        self.delegate = delegate;

        _isCropingFirstTime = YES;

        if ([imageProperty objectForKey:CROPRECT] != nil) {
             CGRect cropRectCoordinate = CGRectFromString([imageProperty objectForKey:CROPRECT]);
             _cropRect = cropRectCoordinate;
        }
        else{
            _cropRect = CGRectMake(0, 0, _originalImageReset.size.width,_originalImageReset.size.height);
        }

        if ([imageProperty objectForKey:TRIMRECT] != nil) {
            CGRect cropRectCoordinate = CGRectFromString([imageProperty objectForKey:TRIMRECT]);
            _trimRect = cropRectCoordinate;
        }
        else{
            _trimRect = _cropRect;
        }

        if ([imageProperty objectForKey:ANGLE] != nil) {
            float angle = [[imageProperty objectForKey:ANGLE] floatValue];
            _angle = angle;
        }
        else{
             _angle = 0.0;
        }

        if ([imageProperty objectForKey:BLEEDAREAX] != nil) {
            float bleedAreaX = [[imageProperty objectForKey:BLEEDAREAX] floatValue];
            _bleedAreaX = bleedAreaX;
            _isBleedAreaShow = YES;
            self.clBleedArea.bleedAreaLeft = bleedAreaX;
            self.clBleedArea.bleedAreaRight  = bleedAreaX;
        }
        else{
            _bleedAreaX = 0.0;
        }

        if ([imageProperty objectForKey:BLEEDAREAY] != nil) {
            float bleedAreaY = [[imageProperty objectForKey:BLEEDAREAY] floatValue];
            _bleedAreaY = bleedAreaY;
            _isBleedAreaShow = YES;
            self.clBleedArea.bleedAreaTop = bleedAreaY;
            self.clBleedArea.bleedAreaBottom = bleedAreaY;
        }
        else{
            _bleedAreaY = 0.0;
        }

        if ([imageProperty objectForKey:CONTENTMODE] != nil) {
            UIViewContentMode contentMode = [[imageProperty objectForKey:CONTENTMODE] intValue];
            _contentMode = &contentMode;
        }
        else{
            UIViewContentMode contentMode = [[NSNumber numberWithInt:UIViewContentModeScaleAspectFit] intValue];
            _contentMode = &contentMode;
        }

        if ([imageProperty objectForKey:ASPECTRATIO] != nil) {
            CGSize aspectRatio = CGSizeFromString([imageProperty objectForKey:ASPECTRATIO]);
            _aspectRatio = aspectRatio;
        }
        else{
            _aspectRatio = CGSizeMake(_originalImageReset.size.width, _originalImageReset.size.height);
        }
        
        if ([imageProperty objectForKey:CONTENTMODE] != nil) {
             _imageView.contentMode = [[imageProperty objectForKey:CONTENTMODE] intValue];
        }
        else {
            _imageView.contentMode = UIViewContentModeScaleAspectFit;
        }

        if ([imageProperty objectForKey:MINRECTSIZE] != nil) {
            CGSize minRectSize = CGSizeFromString([imageProperty objectForKey:MINRECTSIZE]);
            _minRectSize = minRectSize;
        }
        else{
            _minRectSize = CGSizeMake(100.0, 100.0);
        }
    }
    return self;
}

- (id)initWithImage:(UIImage*)image delegate:(id<CLImageEditorDelegate>)delegate withOptions:(NSDictionary*)imageProperty withBleedArea:(CLBleedArea*)bleedArea
    {
        _imageProperty = [[NSMutableDictionary alloc] initWithDictionary: imageProperty];

        if ([imageProperty objectForKey:FONT] != nil) {
            _font = [imageProperty objectForKey:FONT];
        } else {
            _font = [UIFont fontWithName:@"HelveticaNeue-Regular" size:18.0];
        }

        if ([imageProperty objectForKey:BOLDFONT] != nil) {
            _boldFont = [imageProperty objectForKey:BOLDFONT];
        } else {
            _boldFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0];
        }

        self = [self init];
        if (self){
            _originalImage = [image deepCopy];
            _originalImageReset = [image deepCopy];
            self.delegate = delegate;

            _isCropingFirstTime = YES;

            if ([imageProperty objectForKey:CROPRECT] != nil) {
                CGRect cropRectCoordinate = CGRectFromString([imageProperty objectForKey:CROPRECT]);
                _cropRect = cropRectCoordinate;
            }
            else{
                _cropRect = CGRectMake(0, 0, _originalImageReset.size.width,_originalImageReset.size.height);
            }

            if ([imageProperty objectForKey:TRIMRECT] != nil) {
                CGRect cropRectCoordinate = CGRectFromString([imageProperty objectForKey:TRIMRECT]);
                _trimRect = cropRectCoordinate;
            }
            else{
                _trimRect = _cropRect;
            }

            if ([imageProperty objectForKey:ANGLE] != nil) {
                float angle = [[imageProperty objectForKey:ANGLE] floatValue];
                _angle = angle;
            }
            else{
                _angle = 0.0;
            }

            if ([imageProperty objectForKey:BLEEDAREAX] != nil) {
                float bleedAreaX = [[imageProperty objectForKey:BLEEDAREAX] floatValue];
                _bleedAreaX = bleedAreaX;
                _isBleedAreaShow = YES;
            }
            else{
                _bleedAreaX = 0.0;
            }

            if ([imageProperty objectForKey:BLEEDAREAY] != nil) {
                float bleedAreaY = [[imageProperty objectForKey:BLEEDAREAY] floatValue];
                _bleedAreaY = bleedAreaY;
                _isBleedAreaShow = YES;
            }
            else{
                _bleedAreaY = 0.0;
            }

            if (bleedArea != nil) {
                _isBleedAreaShow = bleedArea.isBleedAreaShow;
                self.clBleedArea.bleedAreaTop = bleedArea.bleedAreaTop;
                self.clBleedArea.bleedAreaBottom = bleedArea.bleedAreaBottom;
                self.clBleedArea.bleedAreaLeft = bleedArea.bleedAreaLeft;
                self.clBleedArea.bleedAreaRight  = bleedArea.bleedAreaRight;
            }
            else {
                self.clBleedArea.bleedAreaTop = 0.0;
                self.clBleedArea.bleedAreaBottom = 0.0;
                self.clBleedArea.bleedAreaLeft = 0.0;
                self.clBleedArea.bleedAreaRight  = 0.0;
            }

            if ([imageProperty objectForKey:CONTENTMODE] != nil) {
                UIViewContentMode contentMode = [[imageProperty objectForKey:CONTENTMODE] intValue];
                _contentMode = &contentMode;
            }
            else{
                UIViewContentMode contentMode = [[NSNumber numberWithInt:UIViewContentModeScaleAspectFit] intValue];
                _contentMode = &contentMode;
            }

            if ([imageProperty objectForKey:ASPECTRATIO] != nil) {
                CGSize aspectRatio = CGSizeFromString([imageProperty objectForKey:ASPECTRATIO]);
                _aspectRatio = aspectRatio;
            }
            else{
                _aspectRatio = CGSizeMake(_originalImageReset.size.width, _originalImageReset.size.height);
            }

            if ([imageProperty objectForKey:CONTENTMODE] != nil) {
                _imageView.contentMode = [[imageProperty objectForKey:CONTENTMODE] intValue];
            }
            else {
                _imageView.contentMode = UIViewContentModeScaleAspectFit;
            }

            if ([imageProperty objectForKey:MINRECTSIZE] != nil) {
                CGSize minRectSize = CGSizeFromString([imageProperty objectForKey:MINRECTSIZE]);
                _minRectSize = minRectSize;
            }
            else{
                _minRectSize = CGSizeMake(100.0, 100.0);
            }
        }
        return self;
}

- (id)initWithDelegate:(id<CLImageEditorDelegate>)delegate
{
    self = [self init];
    if (self){
        self.delegate = delegate;
    }
    return self;
}

- (void)dealloc
{
    [_navigationBar removeFromSuperview];
}

#pragma mark- Custom initialization

- (UIBarButtonItem*)createDoneButton
{
    UIBarButtonItem *rightBarButtonItem = nil;
    NSString *doneBtnTitle = [CLImageEditorTheme localizedString:@"CLImageEditor_DoneBtnTitle" withDefault:nil];
    
    if(![doneBtnTitle isEqualToString:@"CLImageEditor_DoneBtnTitle"]){
        rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:doneBtnTitle style:UIBarButtonItemStyleDone target:self action:@selector(pushedFinishBtn:)];
    }
    else{
        rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(pushedFinishBtn:)];
    }
    return rightBarButtonItem;
}

- (void)initNavigationBar
{
    self.navigationItem.rightBarButtonItem = [self createDoneButton];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    if(_navigationBar==nil){
        UINavigationItem *navigationItem  = [[UINavigationItem alloc] init];
        navigationItem.leftBarButtonItem  =  [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@/%@/backbutton.png", CLImageEditorTheme.bundle.bundlePath, @"Back"]] style:UIBarButtonItemStylePlain target:self action:@selector(pushedCloseBtn:)];
        navigationItem.rightBarButtonItem = [self createDoneButton];
        
        CGFloat dy = ([UIDevice iosVersion]<7) ? 0 : MIN([UIApplication sharedApplication].statusBarFrame.size.height, [UIApplication sharedApplication].statusBarFrame.size.width);
        
        UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, dy, self.view.width, kNavBarHeight)];
        [navigationBar pushNavigationItem:navigationItem animated:NO];
        navigationBar.delegate = self;
        
        if(self.navigationController){
            [self.navigationController.view addSubview:navigationBar];
            [_CLImageEditorViewController setConstraintsLeading:@0 trailing:@0 top:@(dy) bottom:nil height:@(kNavBarHeight) width:nil parent:self.navigationController.view child:navigationBar peer:nil];
        }
        else{
            [self.view addSubview:navigationBar];
            [_CLImageEditorViewController setConstraintsLeading:@0 trailing:@0 top:@(dy) bottom:nil height:@(kNavBarHeight) width:nil parent:self.view child:navigationBar peer:nil];
        }
        _navigationBar = navigationBar;
    }
    
    if(self.navigationController!=nil){
        _navigationBar.frame  = self.navigationController.navigationBar.frame;
        _navigationBar.hidden = YES;
        [_navigationBar popNavigationItemAnimated:NO];
    }
    else{
        _navigationBar.topItem.title = self.title;
    }
    
    if([UIDevice iosVersion] < 7){
        _navigationBar.barStyle = UIBarStyleBlackTranslucent;
    }
}

- (void)initMenuScrollView
{
    if(self.menuView==nil){

        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 1)];
        lineView.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:203.0/255.0 blue:203.0/255.0 alpha:1.0];

        UIScrollView *menuScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kMenuBarHeight)];
        
        // Adjust for iPhone X
        if (@available(iOS 11.0, *)) {
            UIEdgeInsets theInsets = [UIApplication sharedApplication].keyWindow.rootViewController.view.safeAreaInsets;
            menuScroll.height += theInsets.bottom;
        }
        
        menuScroll.top = self.view.height - menuScroll.height;
        menuScroll.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        menuScroll.showsHorizontalScrollIndicator = NO;
        menuScroll.showsVerticalScrollIndicator = NO;

        [self.view addSubview:menuScroll];
        self.menuView = menuScroll;
        [_CLImageEditorViewController setConstraintsLeading:@0 trailing:@0 top:nil bottom:@0 height:@(menuScroll.height) width:nil parent:self.view child:menuScroll peer:nil];

        [self.view addSubview:lineView];
        [_CLImageEditorViewController setConstraintsLeading:@0 trailing:@0 top:nil bottom:@(-menuScroll.height) height:@(lineView.height) width:nil parent:self.view child:lineView peer:nil];
    }
    self.menuView.backgroundColor = [CLImageEditorTheme toolbarColor];

    // -- Danish
    int i = 0;
    for(CLImageToolInfo *tool in self.toolInfo.subtools){
        if(tool.available){
            i++;
        }
    }

    if(i < 3){
        self.menuView.scrollEnabled = false;
    }
}

- (void)initImageScrollView
{
    if(_scrollView==nil){
        UIScrollView *imageScroll = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        imageScroll.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        imageScroll.showsHorizontalScrollIndicator = NO;
        imageScroll.showsVerticalScrollIndicator = NO;
        imageScroll.delegate = self;
        imageScroll.clipsToBounds = NO;
        
        CGFloat y = 0;
        if(self.navigationController){
            if(self.navigationController.navigationBar.translucent){
                y = self.navigationController.navigationBar.bottom;
            }
            y = ([UIDevice iosVersion] < 7) ? y-[UIApplication sharedApplication].statusBarFrame.size.height : y;
        }
        else{
            y = _navigationBar.bottom;
        }
        
        imageScroll.top = y;
        imageScroll.height = self.view.height - imageScroll.top - _menuView.height;
        
        [self.view insertSubview:imageScroll atIndex:0];
        _scrollView = imageScroll;
        [_CLImageEditorViewController setConstraintsLeading:@0 trailing:@0 top:@(y) bottom:@(-_menuView.height) height:nil width:nil parent:self.view child:imageScroll peer:nil];
    }
}

+(NSArray <NSLayoutConstraint *>*)setConstraintsLeading:(NSNumber *)leading
                                               trailing:(NSNumber *)trailing
                                                    top:(NSNumber *)top
                                                 bottom:(NSNumber *)bottom
                                                 height:(NSNumber *)height
                                                  width:(NSNumber *)width
                                                 parent:(UIView *)parent
                                                  child:(UIView *)child
                                                   peer:(UIView *)peer
{
    NSMutableArray <NSLayoutConstraint *>*constraints = [NSMutableArray new];
    //Trailing
    if (trailing) {
        NSLayoutConstraint *trailingConstraint = [NSLayoutConstraint
                                                  constraintWithItem:child
                                                  attribute:NSLayoutAttributeTrailing
                                                  relatedBy:NSLayoutRelationEqual
                                                  toItem:(peer ?: parent)
                                                  attribute:NSLayoutAttributeTrailing
                                                  multiplier:1.0f
                                                  constant:trailing.floatValue];
        [parent addConstraint:trailingConstraint];
        [constraints addObject:trailingConstraint];
    }
    //Leading
    if (leading) {
        NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint
                                                 constraintWithItem:child
                                                 attribute:NSLayoutAttributeLeading
                                                 relatedBy:NSLayoutRelationEqual
                                                 toItem:(peer ?: parent)
                                                 attribute:NSLayoutAttributeLeading
                                                 multiplier:1.0f
                                                 constant:leading.floatValue];
        [parent addConstraint:leadingConstraint];
        [constraints addObject:leadingConstraint];
    }
    //Bottom
    if (bottom) {
        NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint
                                                constraintWithItem:child
                                                attribute:NSLayoutAttributeBottom
                                                relatedBy:NSLayoutRelationEqual
                                                toItem:(peer ?: parent)
                                                attribute:NSLayoutAttributeBottom
                                                multiplier:1.0f
                                                constant:bottom.floatValue];
        [parent addConstraint:bottomConstraint];
        [constraints addObject:bottomConstraint];
    }
    //Top
    if (top) {
        NSLayoutConstraint *topConstraint = [NSLayoutConstraint
                                             constraintWithItem:child
                                             attribute:NSLayoutAttributeTop
                                             relatedBy:NSLayoutRelationEqual
                                             toItem:(peer ?: parent)
                                             attribute:NSLayoutAttributeTop
                                             multiplier:1.0f
                                             constant:top.floatValue];
        [parent addConstraint:topConstraint];
        [constraints addObject:topConstraint];
    }
    //Height
    if (height) {
        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint
                                                constraintWithItem:child
                                                attribute:NSLayoutAttributeHeight
                                                relatedBy:NSLayoutRelationEqual
                                                toItem:nil
                                                attribute:NSLayoutAttributeNotAnAttribute
                                                multiplier:1.0f
                                                constant:height.floatValue];
        [child addConstraint:heightConstraint];
        [constraints addObject:heightConstraint];
    }
    //Width
    if (width) {
        NSLayoutConstraint *widthConstraint = [NSLayoutConstraint
                                               constraintWithItem:child
                                               attribute:NSLayoutAttributeWidth
                                               relatedBy:NSLayoutRelationEqual
                                               toItem:nil
                                               attribute:NSLayoutAttributeNotAnAttribute
                                               multiplier:1.0f
                                               constant:width.floatValue];
        [child addConstraint:widthConstraint];
        [constraints addObject:widthConstraint];
    }
    child.translatesAutoresizingMaskIntoConstraints = NO;
    return constraints;
}

#pragma mark-

- (void)showInViewController:(UIViewController*)controller withImageView:(UIImageView*)imageView;
{
    _originalImage = imageView.image;
    
    self.targetImageView = imageView;
    
    [controller addChildViewController:self];
    [self didMoveToParentViewController:controller];
    
    self.view.frame = controller.view.bounds;
    [controller.view addSubview:self.view];
    [self refreshImageView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.toolInfo.title;
    self.view.clipsToBounds = YES;
    self.view.backgroundColor = self.theme.backgroundColor;
    self.navigationController.view.backgroundColor = self.view.backgroundColor;
    
    if([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]){
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]){
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    [self initNavigationBar];
    [self initMenuScrollView];
    [self initImageScrollView];
    
    [self refreshToolSettings];
    
    if(_imageView==nil){
        _imageView = [UIImageView new];
        [_scrollView addSubview:_imageView];
        [self refreshImageView];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(self.targetImageView){
        [self expropriateImageView];
    }
    else{
        [self refreshImageView];
    }

    [self setLayerContent];
    [self setRotation];

    _lastTransform = _imageView.layer.transform;

    self.isTranslucent = self.navigationController.navigationBar.isTranslucent;
    [self.navigationController.navigationBar setTranslucent:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setTranslucent:self.isTranslucent];
}

#pragma mark- View transition

- (void)copyImageViewInfo:(UIImageView*)fromView toView:(UIImageView*)toView
{
    CGAffineTransform transform = fromView.transform;
    fromView.transform = CGAffineTransformIdentity;
    
    toView.transform = CGAffineTransformIdentity;
    toView.frame = [toView.superview convertRect:fromView.frame fromView:fromView.superview];
    toView.transform = transform;
    toView.image = fromView.image;
    toView.contentMode = fromView.contentMode;
    toView.clipsToBounds = fromView.clipsToBounds;
    
    fromView.transform = transform;
}

- (void)expropriateImageView
{
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    
    UIImageView *animateView = [UIImageView new];
    [window addSubview:animateView];
    [self copyImageViewInfo:self.targetImageView toView:animateView];
    
    _bgView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view insertSubview:_bgView atIndex:0];
    
    _bgView.backgroundColor = self.view.backgroundColor;
    self.view.backgroundColor = [self.view.backgroundColor colorWithAlphaComponent:0];
    
    self.targetImageView.hidden = YES;
    _imageView.hidden = YES;
    _bgView.alpha = 0;
    _navigationBar.transform = CGAffineTransformMakeTranslation(0, -_navigationBar.height);
    _menuView.transform = CGAffineTransformMakeTranslation(0, self.view.height-_menuView.top);
    
    [UIView animateWithDuration:kCLImageToolAnimationDuration
                     animations:^{
                         animateView.transform = CGAffineTransformIdentity;
                         
                         CGFloat dy = ([UIDevice iosVersion]<7) ? [UIApplication sharedApplication].statusBarFrame.size.height : 0;
                         
                         CGSize size = (_imageView.image) ? _imageView.image.size : _imageView.frame.size;
                         if(size.width>0 && size.height>0){
                             CGFloat ratio = MIN(_scrollView.width / size.width, _scrollView.height / size.height);
                             CGFloat W = ratio * size.width;
                             CGFloat H = ratio * size.height;
                             animateView.frame = CGRectMake((_scrollView.width-W)/2 + _scrollView.left, (_scrollView.height-H)/2 + _scrollView.top + dy, W, H);
                         }
                         
                         _bgView.alpha = 1;
                         _navigationBar.transform = CGAffineTransformIdentity;
                         _menuView.transform = CGAffineTransformIdentity;
                     }
                     completion:^(BOOL finished) {
                         self.targetImageView.hidden = NO;
                         _imageView.hidden = NO;
                         [animateView removeFromSuperview];
                     }
     ];
}

- (void)restoreImageView:(BOOL)canceled
{
    if(!canceled){
        self.targetImageView.image = _imageView.image;
    }
    self.targetImageView.hidden = YES;
    
    id<CLImageEditorTransitionDelegate> delegate = [self transitionDelegate];
    if([delegate respondsToSelector:@selector(imageEditor:willDismissWithImageView:canceled:)]){
        [delegate imageEditor:self willDismissWithImageView:self.targetImageView canceled:canceled];
    }
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    
    UIImageView *animateView = [UIImageView new];
    [window addSubview:animateView];
    [self copyImageViewInfo:_imageView toView:animateView];
    
    _menuView.frame = [window convertRect:_menuView.frame fromView:_menuView.superview];
    _navigationBar.frame = [window convertRect:_navigationBar.frame fromView:_navigationBar.superview];
    
    [window addSubview:_menuView];
    [window addSubview:_navigationBar];
    
    self.view.userInteractionEnabled = NO;
    _menuView.userInteractionEnabled = NO;
    _navigationBar.userInteractionEnabled = NO;
    _imageView.hidden = YES;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         _bgView.alpha = 0;
                         _menuView.alpha = 0;
                         _navigationBar.alpha = 0;
                         
                         _menuView.transform = CGAffineTransformMakeTranslation(0, self.view.height-_menuView.top);
                         _navigationBar.transform = CGAffineTransformMakeTranslation(0, -_navigationBar.height);
                         
                         [self copyImageViewInfo:self.targetImageView toView:animateView];
                     }
                     completion:^(BOOL finished) {
                         [animateView removeFromSuperview];
                         [_menuView removeFromSuperview];
                         [_navigationBar removeFromSuperview];
                         
                         [self willMoveToParentViewController:nil];
                         [self.view removeFromSuperview];
                         [self removeFromParentViewController];
                         
                         _imageView.hidden = NO;
                         self.targetImageView.hidden = NO;
                         
                         if([delegate respondsToSelector:@selector(imageEditor:didDismissWithImageView:canceled:)]){
                             [delegate imageEditor:self didDismissWithImageView:self.targetImageView canceled:canceled];
                         }
                     }
     ];
}

#pragma mark- Properties

- (id<CLImageEditorTransitionDelegate>)transitionDelegate
{
    if([self.delegate conformsToProtocol:@protocol(CLImageEditorTransitionDelegate)]){
        return (id<CLImageEditorTransitionDelegate>)self.delegate;
    }
    return nil;
}

- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    self.toolInfo.title = title;
}

- (UIScrollView*)scrollView
{
    return _scrollView;
}

#pragma mark- ImageTool setting

+ (NSString*)defaultIconImagePath
{
    return nil;
}

+ (CGFloat)defaultDockedNumber
{
    return 0;
}

+ (NSString*)defaultTitle
{
    return [CLImageEditorTheme localizedString:@"CLImageEditor_DefaultTitle" withDefault:@"Edit"];
}

+ (BOOL)isAvailable
{
    return YES;
}

+ (NSArray*)subtools
{
    return [CLImageToolInfo toolsWithToolClass:[CLImageToolBase class]];
}

+ (NSDictionary*)optionalInfo
{
    return nil;
}

#pragma mark- 

- (void)refreshToolSettings
{
    for(UIView *sub in _menuView.subviews){ [sub removeFromSuperview]; }

    // -- Danish
    CGFloat x = 20;
    CGFloat W = 70;
    CGFloat H = _menuView.height;
    
    int toolCount = 0;
    CGFloat padding = 0;
    for(CLImageToolInfo *info in self.toolInfo.sortedSubtools){
        if(info.available){
            toolCount++;
        }
    }
    
    CGFloat diff = _menuView.frame.size.width - toolCount * W;
    if (0<diff && diff<2*W) {
        padding = diff/(toolCount+1);
    }
    
    for(CLImageToolInfo *info in self.toolInfo.sortedSubtools){
        if(!info.available){
            continue;
        }
        
        CLToolbarMenuItem *view = [CLImageEditorTheme menuItemWithFrame:CGRectMake(x+padding, 0, W, H) target:self action:@selector(tappedMenuView:) toolInfo:info];
        [_menuView addSubview:view];
        x += (_menuView.width/3);
    }

    // -- Danish -- Reset
    CLImageToolInfo *info = [[CLImageToolInfo alloc] init];
    info.title = [@"Reset" uppercaseString];
    info.iconImagePath = [NSString stringWithFormat:@"%@/%@/resetbutton.png", CLImageEditorTheme.bundle.bundlePath, @"ResetTool"];
    CLToolbarMenuItem *resetView = [CLImageEditorTheme menuItemWithFrame:CGRectMake(x+padding, 0, W, H) target:self action:@selector(resetOrignalImage:) toolInfo:info];
    [_menuView addSubview:resetView];

    _menuView.contentSize = CGSizeMake(MAX(x, _menuView.frame.size.width+85), 0);
}

- (void)resetImageViewFrame
{
    CGSize size = (_imageView.image) ? _imageView.image.size : _imageView.frame.size;
    if(size.width>0 && size.height>0){
        CGFloat ratio = MIN(_scrollView.frame.size.width / size.width, _scrollView.frame.size.height / size.height);
        CGFloat W = ratio * size.width * _scrollView.zoomScale;
        CGFloat H = ratio * size.height * _scrollView.zoomScale;

       // _imageView.frame = CGRectMake(_scrollView.frame.origin.x, 0, _scrollView.frame.size.width, _scrollView.frame.size.height); // _scrollView.frame;
        _imageView.frame = CGRectMake(MAX(0, (_scrollView.width-W)/2), MAX(0, (_scrollView.height-H)/2), W, H);

        // -- Danish : ratio save 
        _imageWidth = _imageView.frame.size.width;
        _imageFrame = _imageView.frame;
    }
}

- (void)fixZoomScaleWithAnimated:(BOOL)animated
{
    CGFloat minZoomScale = _scrollView.minimumZoomScale;
    _scrollView.maximumZoomScale = 0.95*minZoomScale;
    _scrollView.minimumZoomScale = 0.95*minZoomScale;
    //[_scrollView setZoomScale:_scrollView.minimumZoomScale animated:animated];
}

- (void)resetZoomScaleWithAnimated:(BOOL)animated
{
    CGFloat Rw = _scrollView.frame.size.width / _imageView.frame.size.width;
    CGFloat Rh = _scrollView.frame.size.height / _imageView.frame.size.height;
    
    //CGFloat scale = [[UIScreen mainScreen] scale];
    CGFloat scale = 1;
    Rw = MAX(Rw, _imageView.image.size.width / (scale * _scrollView.frame.size.width));
    Rh = MAX(Rh, _imageView.image.size.height / (scale * _scrollView.frame.size.height));
    
    _scrollView.contentSize = _imageView.frame.size;
    _scrollView.minimumZoomScale = 1;
    _scrollView.maximumZoomScale = 1;//MAX(MAX(Rw, Rh), 1);
    
    //[_scrollView setZoomScale:_scrollView.minimumZoomScale animated:animated];
}

- (void)refreshImageView
{
   // NSLog(@"refreshImageView");
    _imageView.image = _originalImage;
    
    [self resetImageViewFrame];
    [self resetZoomScaleWithAnimated:NO];
}

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

- (BOOL)shouldAutorotate
{
    return (_currentTool == nil);
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif
{
    return UIInterfaceOrientationMaskAll;
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
   // [self resetImageViewFrame];
    [self refreshToolSettings];
   // [self scrollViewDidZoom:_scrollView];
}

- (BOOL)prefersStatusBarHidden
{
    return [[CLImageEditorTheme theme] statusBarHidden];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return [[CLImageEditorTheme theme] statusBarStyle];
}

#pragma mark- Tool actions

- (void)setCurrentTool:(CLImageToolBase *)currentTool
{
    if(currentTool != _currentTool){

        [_currentTool cleanup];
        _currentTool = currentTool;
        [_currentTool setup];
        
        [self swapToolBarWithEditing:(_currentTool!=nil)];
    }
}

#pragma mark- Menu actions

- (void)swapMenuViewWithEditing:(BOOL)editing
{
    [UIView animateWithDuration:kCLImageToolAnimationDuration
                     animations:^{
                         if(editing){
                             _menuView.transform = CGAffineTransformMakeTranslation(0, self.view.height-_menuView.top);
                         }
                         else{
                             _menuView.transform = CGAffineTransformIdentity;
                         }
                     }
     ];
}

- (void)swapNavigationBarWithEditing:(BOOL)editing
{
    if(self.navigationController==nil){
        return;
    }
    
    if(editing){
        _navigationBar.hidden = NO;
        _navigationBar.transform = CGAffineTransformMakeTranslation(0, -_navigationBar.height);
        
        [UIView animateWithDuration:kCLImageToolAnimationDuration
                         animations:^{
                             self.navigationController.navigationBar.transform = CGAffineTransformMakeTranslation(0, -self.navigationController.navigationBar.height-20);
                             _navigationBar.transform = CGAffineTransformIdentity;
                         }
         ];
    }
    else{
        [UIView animateWithDuration:kCLImageToolAnimationDuration
                         animations:^{
                             self.navigationController.navigationBar.transform = CGAffineTransformIdentity;
                             _navigationBar.transform = CGAffineTransformMakeTranslation(0, -_navigationBar.height);
                         }
                         completion:^(BOOL finished) {
                             _navigationBar.hidden = YES;
                             _navigationBar.transform = CGAffineTransformIdentity;
                         }
         ];
    }
}

- (void)swapToolBarWithEditing:(BOOL)editing
{
    [self swapMenuViewWithEditing:editing];
    [self swapNavigationBarWithEditing:editing];
    
    if(self.currentTool){
        UINavigationItem *item  = [[UINavigationItem alloc] initWithTitle:self.currentTool.toolInfo.title];
        item.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStyleDone target:self action:@selector(pushedDoneBtn:)];
        item.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@/%@/backbutton.png", CLImageEditorTheme.bundle.bundlePath, @"Back"]] style:UIBarButtonItemStylePlain target:self action:@selector(pushedCancelBtn:)];
        
        [_navigationBar pushNavigationItem:item animated:(self.navigationController==nil)];
    }
    else{
        [_navigationBar popNavigationItemAnimated:(self.navigationController==nil)];
    }
}

- (void)setupToolWithToolInfo:(CLImageToolInfo*)info
{
    if(self.currentTool){ return; }
    
    Class toolClass = NSClassFromString(info.toolName);
    
    if(toolClass){
        id instance = [toolClass alloc];
        if(instance!=nil && [instance isKindOfClass:[CLImageToolBase class]]){
            instance = [instance initWithImageEditor:self withToolInfo:info];
            self.currentTool = instance;
        }
    }
}

- (void)tappedMenuView:(UITapGestureRecognizer*)sender
{
     UIView *view = sender.view;

    // -- Danish : set image crop rect to identical value so it will show full image while doing crop
    if ([((CLToolbarMenuItem*)view).title isEqualToString:CROP]) {
        [_imageView.layer setContentsRect:CGRectMake(0, 0, 1, 1)];
    }
    
    view.alpha = 0.2;
    [UIView animateWithDuration:kCLImageToolAnimationDuration
                     animations:^{
                         view.alpha = 1;
                     }
     ];
    
    [self setupToolWithToolInfo:view.toolInfo];

}

- (IBAction)pushedCancelBtn:(id)sender
{
    //_imageView.image = _originalImage;
   // [self resetImageViewFrame];

    // -- Danish : apply previous transfrom to imageview while cancel order.
    if ([self.currentTool.toolInfo.toolName isEqualToString:@"CLRotateTool"]) {
        [((CLRotateTool*)_currentTool) applyOldTransform];
    }
    self.currentTool = nil;
    [self setLayerContent];

}

- (IBAction)pushedDoneBtn:(id)sender
{
    self.view.userInteractionEnabled = NO;
    
    [self.currentTool executeWithCompletionBlock:^(UIImage *image, NSError *error, NSDictionary *userInfo) {
        if(error){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else if(image){
            //_originalImage = image;
            //_imageView.image = image;

           // [self resetImageViewFrame];

            self.currentTool = nil;

            if (userInfo) {
                if([[userInfo objectForKey:@"Crop"] boolValue]){
                    [self setLayerContent];
                }
                else if([[userInfo objectForKey:@"Rotate"] boolValue]){

                }
            }
        }
        self.view.userInteractionEnabled = YES;
    }];
}

- (void)pushedCloseBtn:(id)sender
{
    if(self.targetImageView==nil){
        if([self.delegate respondsToSelector:@selector(imageEditorDidCancel:)]){
            [self.delegate imageEditorDidCancel:self];
        }
        else{
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    else{
        _imageView.image = self.targetImageView.image;
        [self restoreImageView:YES];
    }
}

- (void)pushedFinishBtn:(id)sender
{
    if(self.targetImageView==nil){
        // --Danish
        if([self.delegate respondsToSelector:@selector(imageEditor:didFinishEditingWithImage:withImageOptions:)]){
            NSMutableDictionary *imageProperty = [[NSMutableDictionary alloc]init];

            [imageProperty setObject:NSStringFromCGRect(_cropRect) forKey:CROPRECT];

            if (_angle == -90.0) {
                _angle = 270.0;
            }
            [imageProperty setObject:[NSNumber numberWithFloat:_angle] forKey:ANGLE];


            if (self.isBleedAreaShow) {

                [imageProperty setObject:NSStringFromCGRect(_cropRect) forKey:TRIMRECT];
                
                CGFloat zoomScale = _imageWidth / _imageView.image.size.width;
                CGRect rct = _cropRect;

                rct.size.width  *= zoomScale;
                rct.size.height *= zoomScale;
                rct.origin.x    *= zoomScale;
                rct.origin.y    *= zoomScale;
                if (!self.isCropingFirstTime) {

                    rct.size.width += (self.bleedAreaRightByPercentage / 1);
                    rct.size.width += (self.bleedAreaLeftByPercentage / 1);

                    rct.size.height += (self.bleedAreaTopByPercentage / 1);
                    rct.size.height += (self.bleedAreaBottomByPercentage / 1);
                    
                    rct.origin.x -= (self.bleedAreaLeftByPercentage / 1);
                    rct.origin.y -= (self.bleedAreaTopByPercentage / 1);

                }
                rct.size.width  /= zoomScale;
                rct.size.height /= zoomScale;
                rct.origin.x    /= zoomScale;
                rct.origin.y    /= zoomScale;

//                float x = (rct.origin.x - (rct.size.width * self.clBleedArea.bleedAreaLeft));
//                float y = (rct.origin.y - (rct.size.height * self.clBleedArea.bleedAreaTop));
//                float width = (rct.size.width + ((rct.size.width * self.clBleedArea.bleedAreaRight) + (rct.size.width * self.clBleedArea.bleedAreaLeft)));
//                float height = (rct.size.height + ((rct.size.height * self.clBleedArea.bleedAreaBottom) + (rct.size.height * self.clBleedArea.bleedAreaTop)));
//
//                rct = CGRectMake(x, y,width, height);

                [imageProperty setObject:NSStringFromCGRect(rct) forKey:CROPRECT];
            }

            [self.delegate imageEditor:self didFinishEditingWithImage:[self buildImage:_originalImage]  withImageOptions:imageProperty];
        }
        else if([self.delegate respondsToSelector:@selector(imageEditor:didFinishEditingWithImage:)]){
            [self.delegate imageEditor:self didFinishEditingWithImage:_originalImage];
        }
        else if([self.delegate respondsToSelector:@selector(imageEditor:didFinishEdittingWithImage:)]){
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [self.delegate imageEditor:self didFinishEdittingWithImage:_originalImage];
#pragma clang diagnostic pop
        }
        else{
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    else{
        _imageView.image = _originalImage;
        [self restoreImageView:NO];
    }
}

#pragma mark- ScrollView delegate

// -- Danish : reset to orignal image form
- (void)resetOrignalImage:(UITapGestureRecognizer*)sender
{
    _imageView.layer.transform = _lastTransform;
    [_imageView.layer setContentsRect:CGRectMake(0, 0, 1, 1)];
    _cropRect = CGRectMake(0, 0, _originalImageReset.size.width,  _originalImageReset.size.height);
    _angle = 0.0;
    self.currentTool = nil;
    [self setLayerContent];
}

// -- Danish :  set crop rect on image layer
-(void)setLayerContent
{
    if ([_imageProperty objectForKey:CONTENTMODE] != nil) {
        _imageView.contentMode = [[_imageProperty objectForKey:CONTENTMODE] intValue];
    }
    else {
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }

    if (_isCropingFirstTime) {

        float x = (_cropRect.origin.x + (_cropRect.size.width * self.clBleedArea.bleedAreaLeft));
        float y = (_cropRect.origin.y + (_cropRect.size.height * self.clBleedArea.bleedAreaTop));
        float width = (_cropRect.size.width - ((_cropRect.size.width * self.clBleedArea.bleedAreaRight) + (_cropRect.size.width * self.clBleedArea.bleedAreaLeft)));
        float height = (_cropRect.size.height - ((_cropRect.size.height * self.clBleedArea.bleedAreaBottom) + (_cropRect.size.height * self.clBleedArea.bleedAreaTop)));

         [_imageView.layer setContentsRect:CGRectMake(x/_originalImageReset.size.width, y/_originalImageReset.size.height,width/_originalImageReset.size.width, height/_originalImageReset.size.height)];

      //  [_imageView.layer setContentsRect:CGRectMake(_trimRect.origin.x/_originalImageReset.size.width, _trimRect.origin.y/_originalImageReset.size.height,_trimRect.size.width/_originalImageReset.size.width, _trimRect.size.height/_originalImageReset.size.height)];
    }
    else {
//        [_imageView.layer setContentsRect:CGRectMake(x/_originalImageReset.size.width, y/_originalImageReset.size.height,width/_originalImageReset.size.width, height/_originalImageReset.size.height)];

        [_imageView.layer setContentsRect:CGRectMake(_cropRect.origin.x/_originalImageReset.size.width, _cropRect.origin.y/_originalImageReset.size.height,_cropRect.size.width/_originalImageReset.size.width, _cropRect.size.height/_originalImageReset.size.height)];
    }
}

// -- Danish : Set Rotation
-(void)setRotation
{
    CATransform3D transform = CATransform3DIdentity;
    transform = CATransform3DRotate(transform, (_angle * M_PI / 180), 0, 0, 1);
    CGFloat scale = 1.0;

    Utilities *utilities = [[Utilities alloc]init];

    CGFloat Wnew = fabs(_imageView.bounds.size.width * cos([utilities getImageAngle:_angle] * M_PI)) + fabs(_imageView.bounds.size.height * sin([utilities getImageAngle:_angle] * M_PI));
    CGFloat Hnew = fabs(_imageView.bounds.size.width * sin([utilities getImageAngle:_angle] * M_PI)) + fabs(_imageView.bounds.size.height * cos([utilities getImageAngle:_angle] * M_PI));

    CGFloat Rw = _scrollView.bounds.size.width / Wnew;
    CGFloat Rh = _scrollView.bounds.size.height / Hnew;
    scale = MIN(Rw, Rh) * 0.95;

    transform = CATransform3DScale(transform, scale, scale, 1);
    _imageView.layer.transform = transform;
}

// -- Danish : Image Rotate and Crop
- (UIImage*)buildImage:(UIImage*)image
{
    image = [image crop:_cropRect];
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    CIFilter *filter = [CIFilter filterWithName:@"CIAffineTransform" keysAndValues:kCIInputImageKey, ciImage, nil];

    [filter setDefaults];

    float angle = _angle;
    if (angle == 90.0) {
        angle = -90;
    }
    else if (angle == 270.0) {
        angle = 90;
    }

    CGAffineTransform transform = CGAffineTransformMakeRotation(angle * M_PI/180);//CATransform3DGetAffineTransform(self.imageView.layer.transform);
    [filter setValue:[NSValue valueWithBytes:&transform objCType:@encode(CGAffineTransform)] forKey:@"inputTransform"];

    CIContext *context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @(NO)}];
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];

    UIImage *result = [UIImage imageWithCGImage:cgImage];

    CGImageRelease(cgImage);

    return result;
}

@end
