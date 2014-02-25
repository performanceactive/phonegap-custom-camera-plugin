//
//  GripCameraViewController.h
//  GripCamera
//
//  Created by Chris van Es on 24/02/2014.
//
//

#import <UIKit/UIKit.h>

@interface GripCameraViewController : UIViewController

- (id)initWithCallback:(void(^)(NSData*))callback;

@end
