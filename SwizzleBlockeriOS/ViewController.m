//
//  ViewController.m
//  SwizzleBlockeriOS
//
//  Created by Tim Gymnich on 12.7.20.
//  Copyright © 2020 Tim Gymnich. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation ViewController

- (void)someMethod {
    [self.label setText:@"no swizzling"];
    NSLog(@"no swizzling");
}

- (void)someSwizzeledMethod {
    [self.label setText:@"some swizzling"];
    NSLog(@"some swizzling");
}

- (IBAction)buttonClicked:(id)sender {
    [self someMethod];
}

- (IBAction)swizzleMethod:(id)sender {
    Class class = [self class];

    SEL originalSelector = @selector(someMethod);
    SEL swizzledSelector = @selector(someSwizzeledMethod);

    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);

    method_exchangeImplementations(originalMethod, swizzledMethod);
}

@end
