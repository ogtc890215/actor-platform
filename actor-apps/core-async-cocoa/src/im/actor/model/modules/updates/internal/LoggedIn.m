//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/ex3ndr/Develop/actor-platform/actor-apps/core/src/main/java/im/actor/model/modules/updates/internal/LoggedIn.java
//


#include "J2ObjC_source.h"
#include "im/actor/model/api/rpc/ResponseAuth.h"
#include "im/actor/model/modules/updates/internal/InternalUpdate.h"
#include "im/actor/model/modules/updates/internal/LoggedIn.h"
#include "java/lang/Runnable.h"

@interface ImActorModelModulesUpdatesInternalLoggedIn () {
 @public
  APResponseAuth *auth_;
  id<JavaLangRunnable> runnable_;
}

@end

J2OBJC_FIELD_SETTER(ImActorModelModulesUpdatesInternalLoggedIn, auth_, APResponseAuth *)
J2OBJC_FIELD_SETTER(ImActorModelModulesUpdatesInternalLoggedIn, runnable_, id<JavaLangRunnable>)

@implementation ImActorModelModulesUpdatesInternalLoggedIn

- (instancetype)initWithAPResponseAuth:(APResponseAuth *)auth
                  withJavaLangRunnable:(id<JavaLangRunnable>)runnable {
  ImActorModelModulesUpdatesInternalLoggedIn_initWithAPResponseAuth_withJavaLangRunnable_(self, auth, runnable);
  return self;
}

- (APResponseAuth *)getAuth {
  return auth_;
}

- (id<JavaLangRunnable>)getRunnable {
  return runnable_;
}

@end

void ImActorModelModulesUpdatesInternalLoggedIn_initWithAPResponseAuth_withJavaLangRunnable_(ImActorModelModulesUpdatesInternalLoggedIn *self, APResponseAuth *auth, id<JavaLangRunnable> runnable) {
  (void) ImActorModelModulesUpdatesInternalInternalUpdate_init(self);
  self->auth_ = auth;
  self->runnable_ = runnable;
}

ImActorModelModulesUpdatesInternalLoggedIn *new_ImActorModelModulesUpdatesInternalLoggedIn_initWithAPResponseAuth_withJavaLangRunnable_(APResponseAuth *auth, id<JavaLangRunnable> runnable) {
  ImActorModelModulesUpdatesInternalLoggedIn *self = [ImActorModelModulesUpdatesInternalLoggedIn alloc];
  ImActorModelModulesUpdatesInternalLoggedIn_initWithAPResponseAuth_withJavaLangRunnable_(self, auth, runnable);
  return self;
}

J2OBJC_CLASS_TYPE_LITERAL_SOURCE(ImActorModelModulesUpdatesInternalLoggedIn)