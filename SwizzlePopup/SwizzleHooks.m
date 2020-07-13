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

UIWindow *window;

UIWindowScene* getWindowScene() {
    UIWindowScene *windowScene;
    for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
        if (scene.activationState == UISceneActivationStateForegroundActive) {
            windowScene = scene;
        }
    }
    return windowScene;
}

void showBanner(NSString *message) {
    UIWindowScene *windowScene = getWindowScene();
    CGRect frame = CGRectMake(0, 0, windowScene.screen.bounds.size.width, 130);
    CGRect innerFrame = CGRectInset(frame, 40, 40);
    CGRect labelFrame = CGRectMake(0, 0, innerFrame.size.width, innerFrame.size.height);
    
    UIViewController *viewController = [[UIViewController alloc] init];
    viewController.view.backgroundColor = UIColor.clearColor;

    window = [[UIWindow alloc] initWithWindowScene:windowScene];
    window.frame = frame;
    window.windowLevel = UIWindowLevelAlert + 1;
    window.backgroundColor = UIColor.clearColor;
    window.rootViewController = viewController;

    UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
    label.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = message;
    label.font = [UIFont systemFontOfSize:11];
    label.numberOfLines = 0;
    label.minimumScaleFactor = 0.5;
    label.layer.cornerRadius = 24;
    label.layer.masksToBounds = true;
    
    UIView *shadowView = [[UIView alloc] initWithFrame:innerFrame];
    shadowView.backgroundColor = UIColor.clearColor;
    shadowView.layer.shadowColor = UIColor.blackColor.CGColor;
    shadowView.layer.shadowRadius = 12;
    shadowView.layer.shadowOpacity = 0.2;
    shadowView.layer.shadowOffset = CGSizeMake(4, 4);
    shadowView.alpha = 0;
    
    [viewController.view addSubview:shadowView];
    [shadowView addSubview:label];

    [window makeKeyAndVisible];
    
    [UIView animateWithDuration:3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        shadowView.alpha = 1;
    } completion:nil];
    
    [UIView animateWithDuration:3 delay:6 options:UIViewAnimationOptionCurveEaseOut animations:^{
        shadowView.alpha = 0;
    } completion:^(BOOL finished) {
        window = nil;
    }];
}

NSString* getFrameworkName() {
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


