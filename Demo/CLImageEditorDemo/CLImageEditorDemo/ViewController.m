//
//  ViewController.m
//  CLImageEditorDemo
//
//  Created by sho yakushiji on 2013/11/14.
//  Copyright (c) 2013年 CALACULU. All rights reserved.
//

#import "ViewController.h"

#import "CLImageEditor.h"

@interface ViewController ()
<CLImageEditorDelegate, CLImageEditorTransitionDelegate, CLImageEditorThemeDelegate>
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *contentView = [UIView new];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"default.jpg"]];
    [contentView addSubview:imageView];
    [_scrollView addSubview:contentView];
    _imageView = imageView;
    
    //Set a black theme rather than a white one
	/*
    [[CLImageEditorTheme theme] setBackgroundColor:[UIColor blackColor]];
    [[CLImageEditorTheme theme] setToolbarColor:[[UIColor blackColor] colorWithAlphaComponent:0.8]];
    [[CLImageEditorTheme theme] setToolbarTextColor:[UIColor whiteColor]];
    [[CLImageEditorTheme theme] setToolIconColor:@"white"];
    [[CLImageEditorTheme theme] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    */
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self refreshImageView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    return NO;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)pushedNewBtn
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo Library", nil];
    [sheet showInView:self.view.window];
}

- (void)pushedEditBtn
{
    if(_imageView.image){

        //(origin = (x = 315.95853879440477, y = 1408.5740163027067), size = (width = 452.85297373452744, height = 573.61376673040149))

        // (origin = (x = 205.26114521485363, y = 281.47328167454947), size = (width = 825.19875213847229, height = 595.75324544631167))
        NSMutableDictionary *imageProperty = [[NSMutableDictionary alloc]init];
        [imageProperty setObject:NSStringFromCGRect(CGRectMake(205.26114521485363, 281.47328167454947, 825.19875213847229, 595.75324544631167)) forKey:@"cropRect"];
        [imageProperty setObject:[NSNumber numberWithFloat:0.0] forKey:@"angle"];

        CLImageEditor *editor = [[CLImageEditor alloc] initWithImage:_imageView.image delegate:self withOptions:imageProperty];

        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [dic setValue:[[NSNumber alloc] initWithDouble:0.0] forKey:CROP];
        [dic setValue:[[NSNumber alloc] initWithDouble:1.0] forKey:ROTATE];
       // [dic setValue:[[NSNumber alloc] initWithDouble:2.0] forKey:@"Sticker"];

        [editor showOptions:dic withToolInfo:[editor.toolInfo subtools]];


       // float i = 0.0;
//        for (CLImageToolInfo *tool in [editor.toolInfo subtools]){
//            NSLog(@"%@", tool.title);
//            NSLog(@"%f", tool.dockedNumber);
//           // tool.dockedNumber = i++;
//            if([tool.title isEqualToString:@"Rotate"]){
//                [tool setAvailable:YES];
//                tool.dockedNumber = 1.0;
//            }
//            else if ([tool.title isEqualToString:@"Crop"]){
//                [tool setAvailable:YES];
//                tool.dockedNumber = 0.0;
//            }
//            else{
//                [tool setAvailable:NO];
//            }
//        }

        //CLImageToolInfo *tool = [editor.toolInfo subToolInfoWithToolName:@"CLToneCurveTool" recursive:NO];

        //CLImageEditor *editor = [[CLImageEditor alloc] initWithDelegate:self];
        
        /*
        NSLog(@"%@", editor.toolInfo);
        NSLog(@"%@", editor.toolInfo.toolTreeDescription);
        
        CLImageToolInfo *tool = [editor.toolInfo subToolInfoWithToolName:@"CLToneCurveTool" recursive:NO];
        tool.available = NO;
        
        tool = [editor.toolInfo subToolInfoWithToolName:@"CLRotateTool" recursive:YES];
        tool.available = NO;
        
        tool = [editor.toolInfo subToolInfoWithToolName:@"CLHueEffect" recursive:YES];
        tool.available = NO;
        */
        
        [self presentViewController:editor animated:YES completion:nil];
        //[editor showInViewController:self withImageView:_imageView];
    }
    else{
        [self pushedNewBtn];
    }
}

- (void)pushedSaveBtn
{
    if(_imageView.image){
        NSArray *excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypeMessage];
        
        UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:@[_imageView.image] applicationActivities:nil];
        
        activityView.excludedActivityTypes = excludedActivityTypes;
        activityView.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
            if(completed && [activityType isEqualToString:UIActivityTypeSaveToCameraRoll]){
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Saved successfully" message:nil preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alert animated:YES completion:nil];
            }
        };
        
        [self presentViewController:activityView animated:YES completion:nil];
    }
    else{
        [self pushedNewBtn];
    }
}

#pragma mark- ImagePicker delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];


    
    CLImageEditor *editor = [[CLImageEditor alloc] initWithImage:image];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:[[NSNumber alloc] initWithDouble:0.0] forKey:@"CROP"];
    [dic setValue:[[NSNumber alloc] initWithDouble:1.0] forKey:@"ROTATE"];
    // [dic setValue:[[NSNumber alloc] initWithDouble:2.0] forKey:@"Sticker"];

    [editor showOptions:dic withToolInfo:[editor.toolInfo subtools]];


    editor.delegate = self;
    
    [picker pushViewController:editor animated:YES];
}
/*
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if([navigationController isKindOfClass:[UIImagePickerController class]] && [viewController isKindOfClass:[CLImageEditor class]]){
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonDidPush:)];
    }
}

- (void)cancelButtonDidPush:(id)sender
{
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}
*/
#pragma mark- CLImageEditor delegate

- (void)imageEditor:(CLImageEditor *)editor didFinishEditingWithImage:(UIImage *)image
{
    _imageView.image = image;
    [self refreshImageView];
    
    [editor dismissViewControllerAnimated:YES completion:nil];
}

- (void)imageEditor:(CLImageEditor *)editor willDismissWithImageView:(UIImageView *)imageView canceled:(BOOL)canceled
{
    [self refreshImageView];
}

- (void)imageEditor:(CLImageEditor*)editor didFinishEditingWithImage:(UIImage*)image withImageOptions:(NSDictionary*)imageProperty
{

    // _imageView.image = _originalImageReset;
    // _imageView.contentMode = UIViewContentModeScaleAspectFit;
    // _imageView.layer.contentsGravity = kCAGravityTopLeft;

    //  Utilities *utilities = [Utilities sharedUtilities];


    //[_imageView.layer setContentsRect:CGRectMake(utilities.cropRect.origin.x/_originalImageReset.size.width, utilities.cropRect.origin.y/_originalImageReset.size.height,utilities.cropRect.size.width/_originalImageReset.size.width, utilities.cropRect.size.height/_originalImageReset.size.height)];
    
    CGRect rect9 = CGRectFromString([imageProperty objectForKey:@"cropRect"]);
    float angle = [[imageProperty objectForKey:@"angle"] floatValue];
    _imageView.image = image;
    [self refreshImageView];

    [editor dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark- Tapbar delegate

- (void)deselectTabBarItem:(UITabBar*)tabBar
{
    tabBar.selectedItem = nil;
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    [self performSelector:@selector(deselectTabBarItem:) withObject:tabBar afterDelay:0.2];
    
    switch (item.tag) {
        case 0:
            [self pushedNewBtn];
            break;
        case 1:
            [self pushedEditBtn];
            break;
        case 2:
            [self pushedSaveBtn];
            break;
        default:
            break;
    }
}

#pragma mark- Actionsheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==actionSheet.cancelButtonIndex){
        return;
    }
    
    UIImagePickerControllerSourceType type = UIImagePickerControllerSourceTypePhotoLibrary;
    
    if([UIImagePickerController isSourceTypeAvailable:type]){
        if(buttonIndex==0 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            type = UIImagePickerControllerSourceTypeCamera;
        }
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.allowsEditing = NO;
        picker.delegate   = self;
        picker.sourceType = type;
        
        [self presentViewController:picker animated:YES completion:nil];
    }
}

#pragma mark- ScrollView

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView.superview;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat Ws = _scrollView.frame.size.width - _scrollView.contentInset.left - _scrollView.contentInset.right;
    CGFloat Hs = _scrollView.frame.size.height - _scrollView.contentInset.top - _scrollView.contentInset.bottom;
    CGFloat W = _imageView.superview.frame.size.width;
    CGFloat H = _imageView.superview.frame.size.height;
    
    CGRect rct = _imageView.superview.frame;
    rct.origin.x = MAX((Ws-W)/2, 0);
    rct.origin.y = MAX((Hs-H)/2, 0);
    _imageView.superview.frame = rct;
}

- (void)resetImageViewFrame
{
    CGSize size = (_imageView.image) ? _imageView.image.size : _imageView.frame.size;
    CGFloat ratio = MIN(_scrollView.frame.size.width / size.width, _scrollView.frame.size.height / size.height);
    CGFloat W = ratio * size.width;
    CGFloat H = ratio * size.height;
    _imageView.frame = CGRectMake(0, 0, W, H);
    _imageView.superview.bounds = _imageView.bounds;
}

- (void)resetZoomScaleWithAnimate:(BOOL)animated
{
    CGFloat Rw = _scrollView.frame.size.width / _imageView.frame.size.width;
    CGFloat Rh = _scrollView.frame.size.height / _imageView.frame.size.height;
    
    //CGFloat scale = [[UIScreen mainScreen] scale];
    CGFloat scale = 1;
    Rw = MAX(Rw, _imageView.image.size.width / (scale * _scrollView.frame.size.width));
    Rh = MAX(Rh, _imageView.image.size.height / (scale * _scrollView.frame.size.height));
    
    _scrollView.contentSize = _imageView.frame.size;
    _scrollView.minimumZoomScale = 1;
    _scrollView.maximumZoomScale = MAX(MAX(Rw, Rh), 1);
    
    [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:animated];
    [self scrollViewDidZoom:_scrollView];
}

- (void)refreshImageView
{
    [self resetImageViewFrame];
    [self resetZoomScaleWithAnimate:NO];
}

@end
