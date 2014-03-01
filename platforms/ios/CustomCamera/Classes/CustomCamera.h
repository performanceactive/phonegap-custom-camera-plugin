//
//  CustomCamera.h
//  CustomCamera
//
//  Created by Chris van Es on 24/02/2014.
//
//

#import <Cordova/CDV.h>

@interface CustomCamera : CDVPlugin

- (void)takePicture:(CDVInvokedUrlCommand*)command;

@end
