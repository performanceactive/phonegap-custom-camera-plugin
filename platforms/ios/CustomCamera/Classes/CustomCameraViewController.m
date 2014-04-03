//
//  CustomCameraViewController.m
//  CustomCamera
//
//  Created by Chris van Es on 24/02/2014.
//
//

#import "CustomCameraViewController.h"

#import <Cordova/CDV.h>
#import <AVFoundation/AVFoundation.h>

@implementation CustomCameraViewController {
    void(^_callback)(UIImage*);
    AVCaptureSession *_captureSession;
    AVCaptureDevice *_rearCamera;
    AVCaptureStillImageOutput *_stillImageOutput;
    UIButton *_captureButton;
    UIButton *_backButton;
    UIImageView *_topLeftGuide;
    UIImageView *_topRightGuide;
    UIImageView *_bottomLeftGuide;
    UIImageView *_bottomRightGuide;
    UIActivityIndicatorView *_activityIndicator;
}

static const CGFloat kCaptureButtonWidthPhone = 50;
static const CGFloat kCaptureButtonHeightPhone = 50;
static const CGFloat kBackButtonWidthPhone = 100;
static const CGFloat kBackButtonHeightPhone = 40;
static const CGFloat kBorderImageWidthPhone = 50;
static const CGFloat kBorderImageHeightPhone = 50;
static const CGFloat kHorizontalInsetPhone = 15;
static const CGFloat kVerticalInsetPhone = 25;

static const CGFloat kCaptureButtonWidthTablet = 75;
static const CGFloat kCaptureButtonHeightTablet = 75;
static const CGFloat kBackButtonWidthTablet = 150;
static const CGFloat kBackButtonHeightTablet = 50;
static const CGFloat kBorderImageWidthTablet = 50;
static const CGFloat kBorderImageHeightTablet = 50;
static const CGFloat kHorizontalInsetTablet = 100;
static const CGFloat kVerticalInsetTablet = 50;

static const CGFloat kAspectRatio = 125.0f / 86;

- (id)initWithCallback:(void(^)(UIImage*))callback {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _callback = callback;
        _captureSession = [[AVCaptureSession alloc] init];
        _captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    }
    return self;
}

- (void)dealloc {
    [_captureSession stopRunning];
}

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view.backgroundColor = [UIColor blackColor];
    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    previewLayer.frame = self.view.bounds;
    [[self.view layer] addSublayer:previewLayer];
    [self.view addSubview:[self createOverlay]];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self layoutOverlayForTablet];
    } else {
        [self layoutOverlayForPhone];
    }
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicator.center = self.view.center;
    [self.view addSubview:_activityIndicator];
    [_activityIndicator startAnimating];
}

- (UIView*)createOverlay {
    UIView *overlay = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    _captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_captureButton setImage:[UIImage imageNamed:@"www/img/cameraoverlay/capture_button.png"] forState:UIControlStateNormal];
    [_captureButton setImage:[UIImage imageNamed:@"www/img/cameraoverlay/capture_button_pressed.png"] forState:UIControlStateHighlighted];
    [_captureButton addTarget:self action:@selector(takePictureWaitingForCameraToFocus) forControlEvents:UIControlEventTouchUpInside];
    [overlay addSubview:_captureButton];
    
    _backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_backButton setBackgroundImage:[UIImage imageNamed:@"www/img/cameraoverlay/back_button.png"] forState:UIControlStateNormal];
    [_backButton setBackgroundImage:[UIImage imageNamed:@"www/img/cameraoverlay/back_button_pressed.png"] forState:UIControlStateHighlighted];
    [_backButton setTitle:@"Back" forState:UIControlStateNormal];
    [_backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [[_backButton titleLabel] setFont:[UIFont systemFontOfSize:14]];
    [_backButton addTarget:self action:@selector(dismissCameraPreview) forControlEvents:UIControlEventTouchUpInside];
    [overlay addSubview:_backButton];
    
    _topLeftGuide = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"www/img/cameraoverlay/border_top_left.png"]];
    [overlay addSubview:_topLeftGuide];
    
    _topRightGuide = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"www/img/cameraoverlay/border_top_right.png"]];
    [overlay addSubview:_topRightGuide];
    
    _bottomLeftGuide = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"www/img/cameraoverlay/border_bottom_left.png"]];
    [overlay addSubview:_bottomLeftGuide];
    
    _bottomRightGuide = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"www/img/cameraoverlay/border_bottom_right.png"]];
    [overlay addSubview:_bottomRightGuide];

    return overlay;
}

- (void)layoutOverlayForPhone {
    CGRect bounds = [[UIScreen mainScreen] bounds];
    
    _captureButton.frame = CGRectMake((bounds.size.width / 2) - (kCaptureButtonWidthPhone / 2),
                                      bounds.size.height - kCaptureButtonHeightPhone - 20,
                                      kCaptureButtonWidthPhone,
                                      kCaptureButtonHeightPhone);
    
    _backButton.frame = CGRectMake((CGRectGetMinX(_captureButton.frame) - kBackButtonWidthPhone) / 2,
                                   CGRectGetMinY(_captureButton.frame) + ((kCaptureButtonHeightPhone - kBackButtonHeightPhone) / 2),
                                   kBackButtonWidthPhone,
                                   kBackButtonHeightPhone);
    
    _topLeftGuide.frame = CGRectMake(kHorizontalInsetPhone, kVerticalInsetPhone, kBorderImageWidthPhone, kBorderImageHeightPhone);
    
    _topRightGuide.frame = CGRectMake(bounds.size.width - kBorderImageWidthPhone - kHorizontalInsetPhone,
                                     kVerticalInsetPhone,
                                     kBorderImageWidthPhone,
                                     kBorderImageHeightPhone);
    
    CGFloat height = (CGRectGetMaxX(_topRightGuide.frame) - CGRectGetMinX(_topLeftGuide.frame)) * kAspectRatio;
    
    _bottomLeftGuide.frame = CGRectMake(CGRectGetMinX(_topLeftGuide.frame),
                                        CGRectGetMinY(_topLeftGuide.frame) + height - kBorderImageHeightPhone,
                                        kBorderImageWidthPhone,
                                        kBorderImageHeightPhone);
    
    _bottomRightGuide.frame = CGRectMake(CGRectGetMinX(_topRightGuide.frame),
                                         CGRectGetMinY(_topRightGuide.frame) + height - kBorderImageHeightPhone,
                                         kBorderImageWidthPhone,
                                         kBorderImageHeightPhone);
}

- (void)layoutOverlayForTablet {
    CGRect bounds = [[UIScreen mainScreen] bounds];
    
    _captureButton.frame = CGRectMake((bounds.size.width / 2) - (kCaptureButtonWidthTablet / 2),
                                      bounds.size.height - kCaptureButtonHeightTablet - 20,
                                      kCaptureButtonWidthTablet,
                                      kCaptureButtonHeightTablet);
    
    _backButton.frame = CGRectMake((CGRectGetMinX(_captureButton.frame) - kBackButtonWidthTablet) / 2,
                                   CGRectGetMinY(_captureButton.frame) + ((kCaptureButtonHeightTablet - kBackButtonHeightTablet) / 2),
                                   kBackButtonWidthTablet,
                                   kBackButtonHeightTablet);
    
    _topLeftGuide.frame = CGRectMake(kHorizontalInsetTablet, kVerticalInsetTablet, kBorderImageWidthTablet, kBorderImageHeightTablet);
    
    _topRightGuide.frame = CGRectMake(bounds.size.width - kBorderImageWidthTablet - kHorizontalInsetTablet,
                                      kVerticalInsetTablet,
                                      kBorderImageWidthTablet,
                                      kBorderImageHeightTablet);
    
    CGFloat height = (CGRectGetMaxX(_topRightGuide.frame) - CGRectGetMinX(_topLeftGuide.frame)) * kAspectRatio;
    
    _bottomLeftGuide.frame = CGRectMake(CGRectGetMinX(_topLeftGuide.frame),
                                        CGRectGetMinY(_topLeftGuide.frame) + height - kBorderImageHeightTablet,
                                        kBorderImageWidthTablet,
                                        kBorderImageHeightTablet);
    
    _bottomRightGuide.frame = CGRectMake(CGRectGetMinX(_topRightGuide.frame),
                                         CGRectGetMinY(_topRightGuide.frame) + height - kBorderImageHeightTablet,
                                         kBorderImageWidthTablet,
                                         kBorderImageHeightTablet);
}

- (void)viewDidLoad {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        for (AVCaptureDevice *device in [AVCaptureDevice devices]) {
            if ([device hasMediaType:AVMediaTypeVideo] && [device position] == AVCaptureDevicePositionBack) {
                _rearCamera = device;
            }
        }
        AVCaptureDeviceInput *cameraInput = [AVCaptureDeviceInput deviceInputWithDevice:_rearCamera error:nil];
        [_captureSession addInput:cameraInput];
        _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        [_captureSession addOutput:_stillImageOutput];
        [_captureSession startRunning];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_activityIndicator stopAnimating];
        });
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return orientation == UIDeviceOrientationPortrait;
}

- (void)dismissCameraPreview {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)takePictureWaitingForCameraToFocus {
    if (_rearCamera.adjustingFocus) {
        [_rearCamera addObserver:self forKeyPath:@"adjustingFocus" options:NSKeyValueObservingOptionNew context:nil];
    } else {
        [self takePicture];
    }
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context {
    if ([keyPath isEqualToString:@"adjustingFocus"] && !_rearCamera.adjustingFocus) {
        [_rearCamera removeObserver:self forKeyPath:@"adjustingFocus"];
        [self takePicture];
    }
}

- (void)takePicture {
    AVCaptureConnection *videoConnection = [self videoConnectionToOutput:_stillImageOutput];
    [_stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
        _callback([UIImage imageWithData:imageData]);
    }];
}

- (AVCaptureConnection*)videoConnectionToOutput:(AVCaptureOutput*)output {
    for (AVCaptureConnection *connection in output.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                return connection;
            }
        }
    }
    return nil;
}

@end
