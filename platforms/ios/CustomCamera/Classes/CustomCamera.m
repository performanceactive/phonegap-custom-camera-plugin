//
//  CustomCamera.m
//  CustomCamera
//
//  Created by Chris van Es on 24/02/2014.
//
//

#import "CustomCamera.h"
#import "CustomCameraViewController.h"

@implementation CustomCamera

- (void)takePicture:(CDVInvokedUrlCommand*)command {
    NSString *filename = [command argumentAtIndex:0];
    CGFloat quality = [[command argumentAtIndex:1] floatValue];
    if (![UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"No rear camera detected"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    } else if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Camera is not accessible"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    } else {
        CustomCameraViewController *cameraViewController = [[CustomCameraViewController alloc] initWithCallback:^(UIImage *image) {
            NSString* documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString* imagePath = [documentsDirectory stringByAppendingPathComponent:filename];
            NSData *imageData = UIImageJPEGRepresentation(image, quality / 100);
            [imageData writeToFile:imagePath atomically:YES];
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                        messageAsString:[[NSURL fileURLWithPath:imagePath] absoluteString]];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            [self.viewController dismissViewControllerAnimated:YES completion:nil];
        }];
        [self.viewController presentViewController:cameraViewController animated:YES completion:nil];
    }
}

@end