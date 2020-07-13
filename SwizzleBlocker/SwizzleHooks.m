//
//  SwizzleHooks.m
//  SwizzleBlocker
//
//  Created by Tim Gymnich on 12.7.20.
//  Copyright © 2020 Tim Gymnich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <dlfcn.h>
#import "SwizzleHooks.h"

OBJC_EXPORT void
method_exchangeImplementations(Method _Nonnull m1, Method _Nonnull m2) {
    dispatch_async(dispatch_get_main_queue(), ^{
    UIWindowScene *windowScene;
    for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
        if (scene.activationState == UISceneActivationStateForegroundActive) {
            windowScene = (UIWindowScene*)scene;
        }
    }
    UIWindow *window = [[UIWindow alloc] initWithWindowScene:windowScene];

    NSString *message = [NSString stringWithFormat:@"Someone is trying to replace %s with %s", sel_getName(method_getName(m1)), sel_getName(method_getName(m2))];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Method Swizzling" message:message preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Allow" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // the dynamic linker giveth and taketh away
        void *handle = dlopen("/System/Library/Frameworks/Foundation.framework/Foundation", RTLD_LAZY);
        void (*original_method_exchangeImplementations)(Method, Method) = dlsym(handle, "method_exchangeImplementations");
        original_method_exchangeImplementations(m1,m2);
        [window resignKeyWindow];
    }];

    UIAlertAction *secondaryAction = [UIAlertAction actionWithTitle:@"Deny" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"swizzling denied");
        [window resignKeyWindow];
    }];

    [alert addAction:defaultAction];
    [alert addAction:secondaryAction];

    UIViewController *viewController = [[UIViewController alloc] init];
    window.rootViewController = viewController;
    window.windowLevel = UIWindowLevelAlert + 1;
    [window makeKeyAndVisible];
    [viewController presentViewController:alert animated:YES completion:nil];
    });
}
