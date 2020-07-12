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

OBJC_EXPORT IMP _Nonnull
method_setImplementation(Method _Nonnull m, IMP _Nonnull imp) {
    printf("called hooker\n");
    return imp;
}

UIWindow *window;

OBJC_EXPORT void
method_exchangeImplementations(Method _Nonnull m1, Method _Nonnull m2) {
    NSLog(@"Swizzling Alert!");
    UIWindowScene *windowScene;
    for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
        if (scene.activationState == UISceneActivationStateForegroundActive) {
            windowScene = scene;
        }
    }

    NSString *message = [NSString stringWithFormat:@"Someone is trying to replace %s with %s", method_getName(m1), method_getName(m2)];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Method Swizzling" message:message preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Allow" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // the dynamic linker giveth and taketh away
        void *handle = dlopen("/System/Library/Frameworks/Foundation.framework/Foundation", RTLD_LAZY);
        void (*original_method_exchangeImplementations)(Method, Method) = dlsym(handle, "method_exchangeImplementations");
        original_method_exchangeImplementations(m1,m2);
        window = nil;
    }];

    UIAlertAction *secondaryAction = [UIAlertAction actionWithTitle:@"Deny" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"swizzling denied");
        window = nil;
    }];

    [alert addAction:defaultAction];
    [alert addAction:secondaryAction];

    window = [[UIWindow alloc] initWithWindowScene:windowScene];
    UIViewController *viewController = [[UIViewController alloc] init];
    window.rootViewController = viewController;
    window.windowLevel = UIWindowLevelAlert + 1;
    [window makeKeyAndVisible];
    [viewController presentViewController:alert animated:YES completion:nil];
}
