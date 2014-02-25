//
//  GripCamera.m
//  GripCamera
//
//  Created by Chris van Es on 24/02/2014.
//
//

#import "GripCamera.h"
#import "GripCameraViewController.h"

@implementation GripCamera {
    CDVInvokedUrlCommand *_command;
    UIImagePickerController *_picker;
}

- (void)takePicture:(CDVInvokedUrlCommand*)command {
    _command = command;
    if (![UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"No rear camera detected"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    } else if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Camera is not accessible, has user denied access?"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    } else {
        GripCameraViewController *cameraViewController = [[GripCameraViewController alloc] initWithCallback:^(NSData* imageData) {
            NSString* documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString* imagePath = [documentsDirectory stringByAppendingPathComponent:[command argumentAtIndex:0]];
            [imageData writeToFile:imagePath atomically:YES];
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:imagePath];
            [self.commandDelegate sendPluginResult:result callbackId:_command.callbackId];
            [self.viewController dismissViewControllerAnimated:YES completion:nil];
        }];
        [self.viewController presentViewController:cameraViewController animated:YES completion:nil];
    }
}

@end