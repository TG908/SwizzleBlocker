//
//  SwizzleHooks.h
//  SwizzleBlockeriOS
//
//  Created by Tim Gymnich on 12.7.20.
//  Copyright © 2020 Tim Gymnich. All rights reserved.
//

#ifndef SwizzleHooks_h
#define SwizzleHooks_h

#import <objc/runtime.h>

OBJC_EXPORT IMP _Nonnull
method_setImplementation(Method _Nonnull m, IMP _Nonnull imp);

OBJC_EXPORT void
method_exchangeImplementations(Method _Nonnull m1, Method _Nonnull m2);

#endif /* SwizzleHooks_h */
