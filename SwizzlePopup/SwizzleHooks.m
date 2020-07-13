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

UIWindowScene* getWindowScene() {
    UIWindowScene *windowScene;
    for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
        if (scene.activationState == UISceneActivationStateForegroundActive) {
            windowScene = (UIWindowScene *) scene;
        }
    }
    return windowScene;
}

void showBanner(NSString *message) {
    NSLog(@"%@", message);
    dispatch_async(dispatch_get_main_queue(), ^{
    UIWindowScene *windowScene = getWindowScene();
    
    UIViewController *viewController = [[UIViewController alloc] init];
    viewController.view.backgroundColor = UIColor.clearColor;

    UIWindow *window = [[UIWindow alloc] initWithWindowScene:windowScene];
        CGRect frame = CGRectMake(0, 0, windowScene.screen.bounds.size.width, 2 * window.safeAreaInsets.top + 60);
    window.frame = frame;
    window.windowLevel = UIWindowLevelAlert + 1;
    window.backgroundColor = UIColor.clearColor;
    window.rootViewController = viewController;
        
    CGRect innerFrame = CGRectInset(frame, 16, window.safeAreaInsets.top);
    CGRect labelFrame = CGRectMake(0, 0, innerFrame.size.width, innerFrame.size.height);

    UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
    label.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.9];
    label.textColor = UIColor.blackColor;
    label.textAlignment = NSTextAlignmentCenter;
    label.text = message;
    label.font = [UIFont systemFontOfSize:11];
    label.numberOfLines = 0;
    label.minimumScaleFactor = 0.4;
    label.layer.cornerRadius = 28;
    label.layer.masksToBounds = true;
    
    UIView *shadowView = [[UIView alloc] initWithFrame:innerFrame];
    shadowView.backgroundColor = UIColor.clearColor;
    shadowView.layer.shadowColor = UIColor.blackColor.CGColor;
    shadowView.layer.shadowRadius = 8;
    shadowView.layer.shadowOpacity = 0.2;
    shadowView.layer.shadowOffset = CGSizeMake(4,4);
    shadowView.alpha = 0;
    shadowView.frame = CGRectOffset(innerFrame, 0, -innerFrame.size.height - 10);
    
    [viewController.view addSubview:shadowView];
    [shadowView addSubview:label];

    [window makeKeyAndVisible];
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        shadowView.alpha = 1;
        shadowView.frame = innerFrame;
    } completion:nil];
    
    [UIView animateWithDuration:0.3 delay:6 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        shadowView.alpha = 0;
        shadowView.frame = CGRectOffset(innerFrame, 0, -(innerFrame.size.height + 10));
    } completion:^(BOOL finished) {
        [window resignKeyWindow];
    }];
    });
}

__attribute__((always_inline)) NSString* getFrameworkName() {
    NSString *sourceString = [[NSThread callStackSymbols] objectAtIndex:1];
    NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString:@" -[]+?.,"];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[sourceString  componentsSeparatedByCharactersInSet:separatorSet]];
    [array removeObject:@""];
    NSString *framework = [array objectAtIndex:1];
    return framework;
}

OBJC_EXPORT IMP _Nonnull
method_setImplementation(Method _Nonnull m, IMP _Nonnull imp) {
    NSString *message = [NSString stringWithFormat:@"%@ is trying to set the implementation for %s", getFrameworkName(), sel_getName(method_getName(m))];
    showBanner(message);
    
    void *handle = dlopen("/System/Library/Frameworks/Foundation.framework/Foundation", RTLD_LAZY);
    IMP (*original_method)(Method, IMP) = dlsym(handle, "method_setImplementation");
    original_method(m,imp);
    
    return original_method(m,imp);
}

OBJC_EXPORT void
method_exchangeImplementations(Method _Nonnull m1, Method _Nonnull m2) {
    NSString *message = [NSString stringWithFormat:@"%@ is trying to replace %s with %s", getFrameworkName(), sel_getName(method_getName(m1)), sel_getName(method_getName(m2))];
    showBanner(message);
    
    void *handle = dlopen("/System/Library/Frameworks/Foundation.framework/Foundation", RTLD_LAZY);
    void (*original_method)(Method, Method) = dlsym(handle, "method_exchangeImplementations");
    original_method(m1,m2);
}


OBJC_EXPORT BOOL
class_addMethod(Class _Nullable cls, SEL _Nonnull name, IMP _Nonnull imp,
                const char * _Nullable types) {
    NSString *message = [NSString stringWithFormat:@"%@ is trying to add %@ to %@", getFrameworkName(), NSStringFromSelector(name), NSStringFromClass(cls)];
    showBanner(message);

    void *handle = dlopen("/System/Library/Frameworks/Foundation.framework/Foundation", RTLD_LAZY);
    BOOL (*original_method)(Class, SEL, IMP, const char *) = dlsym(handle, "class_addMethod");
    
    return original_method(cls,name,imp,types);
}

OBJC_EXPORT IMP _Nullable
class_replaceMethod(Class _Nullable cls, SEL _Nonnull name, IMP _Nonnull imp,
                    const char * _Nullable types) {
    NSString *message = [NSString stringWithFormat:@"%@ is trying to replace the implmentation of %@ in %@", getFrameworkName(), NSStringFromSelector(name), NSStringFromClass(cls)];
    showBanner(message);

    void *handle = dlopen("/System/Library/Frameworks/Foundation.framework/Foundation", RTLD_LAZY);
    IMP (*original_method)(Class, SEL, IMP, const char *) = dlsym(handle, "class_replaceMethod");
    
    return original_method(cls,name,imp,types);
}


