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
    CGFloat targetWidth = [[command argumentAtIndex:2] floatValue];
    CGFloat targetHeight = [[command argumentAtIndex:3] floatValue];
    if (![UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"No rear camera detected"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    } else if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Camera is not accessible"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    } else {
        CustomCameraViewController *cameraViewController = [[CustomCameraViewController alloc] initWithCallback:^(UIImage *image) {
            NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:filename];
            UIImage *scaledImage = [self scaleImage:image toSize:CGSizeMake(targetWidth, targetHeight)];
            NSData *scaledImageData = UIImageJPEGRepresentation(scaledImage, quality / 100);
            [scaledImageData writeToFile:imagePath atomically:YES];
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                        messageAsString:[[NSURL fileURLWithPath:imagePath] absoluteString]];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            [self.viewController dismissViewControllerAnimated:YES completion:nil];
        }];
        [self.viewController presentViewController:cameraViewController animated:YES completion:nil];
    }
}

- (UIImage*)scaleImage:(UIImage*)image toSize:(CGSize)targetSize {
    if (targetSize.width <= 0 && targetSize.height <= 0) {
        return image;
    }
    
    CGFloat aspectRatio = image.size.height / image.size.width;
    CGSize scaledSize;
    if (targetSize.width > 0 && targetSize.height <= 0) {
        scaledSize = CGSizeMake(targetSize.width, targetSize.width * aspectRatio);
    } else if (targetSize.width <= 0 && targetSize.height > 0) {
        scaledSize = CGSizeMake(targetSize.height / aspectRatio, targetSize.height);
    } else {
        scaledSize = CGSizeMake(targetSize.width, targetSize.height);
    }
    
    UIGraphicsBeginImageContext(scaledSize);
    [image drawInRect:CGRectMake(0, 0, scaledSize.width, scaledSize.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

@end