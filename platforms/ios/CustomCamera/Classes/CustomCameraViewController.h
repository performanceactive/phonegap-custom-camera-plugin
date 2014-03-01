//
//  CustomCameraViewController.h
//  CustomCamera
//
//  Created by Chris van Es on 24/02/2014.
//
//

#import <UIKit/UIKit.h>

@interface CustomCameraViewController : UIViewController

- (id)initWithCallback:(void(^)(UIImage*))callback;

@end
