//
//  GripCamera.h
//  GripCamera
//
//  Created by Chris van Es on 24/02/2014.
//
//

#import <Cordova/CDV.h>

@interface GripCamera : CDVPlugin

- (void)takePicture:(CDVInvokedUrlCommand*)command;

@end
