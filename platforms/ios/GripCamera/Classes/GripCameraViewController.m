//
//  GripCameraViewController.m
//  GripCamera
//
//  Created by Chris van Es on 24/02/2014.
//
//

#import "GripCameraViewController.h"

#import <Cordova/CDV.h>
#import <AVFoundation/AVFoundation.h>

@implementation GripCameraViewController {
    void(^_callback)(NSData*);
    AVCaptureSession *_captureSession;
    AVCaptureDevice *_rearCamera;
    AVCaptureStillImageOutput *_stillImageOutput;
    UIButton *_captureButton;
    UIImageView *_topLeftGuide;
    UIImageView *_topRightGuide;
    UIImageView *_bottomLeftGuide;
    UIImageView *_bottomRightGuide;
    UIActivityIndicatorView *_activityIndicator;
}

static const CGFloat kButtonWidth = 50;
static const CGFloat kButtonHeight = 50;
static const CGFloat kGuideWidth = 50;
static const CGFloat kGuideHeight = 50;
static const CGFloat kHorizontalInsetPhone = 15;
static const CGFloat kVerticalInsetPhone = 30;
static const CGFloat kHorizontalInsetTablet = 100;
static const CGFloat kVerticalInsetTablet = 200;

- (id)initWithCallback:(void(^)(NSData*))callback {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _callback = callback;
        _captureSession = [[AVCaptureSession alloc] init];
        _captureSession.sessionPreset = AVCaptureSessionPresetHigh;
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
    
    _topLeftGuide = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"www/img/cameraoverlay/guide_top_left.png"]];
    [overlay addSubview:_topLeftGuide];
    
    _topRightGuide = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"www/img/cameraoverlay/guide_top_right.png"]];
    [overlay addSubview:_topRightGuide];
    
    _bottomLeftGuide = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"www/img/cameraoverlay/guide_bottom_left.png"]];
    [overlay addSubview:_bottomLeftGuide];
    
    _bottomRightGuide = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"www/img/cameraoverlay/guide_bottom_right.png"]];
    [overlay addSubview:_bottomRightGuide];

    return overlay;
}

- (void)layoutOverlayForPhone {
    CGRect bounds = [[UIScreen mainScreen] bounds];
    
    _captureButton.frame = CGRectMake((bounds.size.width / 2) - (kButtonWidth / 2),
                                      bounds.size.height - kButtonHeight - 20,
                                      kButtonWidth,
                                      kButtonHeight);
    
    _topLeftGuide.frame = CGRectMake(kHorizontalInsetPhone, kVerticalInsetPhone, kGuideWidth, kGuideHeight);
    
    _topRightGuide.frame = CGRectMake(bounds.size.width - kGuideWidth - kHorizontalInsetPhone,
                                     kVerticalInsetPhone,
                                     kGuideWidth,
                                     kGuideHeight);
    
    _bottomLeftGuide.frame = CGRectMake(kHorizontalInsetPhone,
                                       CGRectGetMinY(_captureButton.frame) - kGuideHeight,
                                       kGuideWidth,
                                       kGuideHeight);
    
    _bottomRightGuide.frame = CGRectMake(bounds.size.width - kGuideWidth - kHorizontalInsetPhone,
                                        CGRectGetMinY(_captureButton.frame) - kGuideHeight,
                                        kGuideWidth,
                                        kGuideHeight);
}

- (void)layoutOverlayForTablet {
    CGRect bounds = [[UIScreen mainScreen] bounds];
    
    _captureButton.frame = CGRectMake((bounds.size.width / 2) - (kButtonWidth / 2),
                                      bounds.size.height - kButtonHeight - 20,
                                      kButtonWidth,
                                      kButtonHeight);
    
    _topLeftGuide.frame = CGRectMake(kHorizontalInsetTablet, kVerticalInsetTablet, kGuideWidth, kGuideHeight);
    
    _topRightGuide.frame = CGRectMake(bounds.size.width - kGuideWidth - kHorizontalInsetTablet,
                                      kVerticalInsetTablet,
                                      kGuideWidth,
                                      kGuideHeight);
    
    _bottomLeftGuide.frame = CGRectMake(kHorizontalInsetTablet,
                                        CGRectGetMinY(_captureButton.frame) - kGuideHeight,
                                        kGuideWidth,
                                        kGuideHeight);
    
    _bottomRightGuide.frame = CGRectMake(bounds.size.width - kGuideWidth - kHorizontalInsetTablet,
                                         CGRectGetMinY(_captureButton.frame) - kGuideHeight,
                                         kGuideWidth,
                                         kGuideHeight);
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
        _callback(imageData);
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
