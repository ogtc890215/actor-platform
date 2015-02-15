//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/ex3ndr/Develop/actor-model/actor-ios/build/java/im/actor/model/entity/GroupMember.java
//

#include "J2ObjC_source.h"
#include "im/actor/model/entity/GroupMember.h"

@interface ImActorModelEntityGroupMember () {
 @public
  jint uid_;
  jint inviterUid_;
  jlong inviteDate_;
}
@end

@implementation ImActorModelEntityGroupMember

- (instancetype)initWithInt:(jint)uid
                    withInt:(jint)inviterUid
                   withLong:(jlong)inviteDate {
  if (self = [super init]) {
    self->uid_ = uid;
    self->inviterUid_ = inviterUid;
    self->inviteDate_ = inviteDate;
  }
  return self;
}

- (jint)getUid {
  return uid_;
}

- (jint)getInviterUid {
  return inviterUid_;
}

- (jlong)getInviteDate {
  return inviteDate_;
}

- (void)copyAllFieldsTo:(ImActorModelEntityGroupMember *)other {
  [super copyAllFieldsTo:other];
  other->uid_ = uid_;
  other->inviterUid_ = inviterUid_;
  other->inviteDate_ = inviteDate_;
}

+ (const J2ObjcClassInfo *)__metadata {
  static const J2ObjcMethodInfo methods[] = {
    { "initWithInt:withInt:withLong:", "GroupMember", NULL, 0x1, NULL },
    { "getUid", NULL, "I", 0x1, NULL },
    { "getInviterUid", NULL, "I", 0x1, NULL },
    { "getInviteDate", NULL, "J", 0x1, NULL },
  };
  static const J2ObjcFieldInfo fields[] = {
    { "uid_", NULL, 0x12, "I", NULL,  },
    { "inviterUid_", NULL, 0x12, "I", NULL,  },
    { "inviteDate_", NULL, 0x12, "J", NULL,  },
  };
  static const J2ObjcClassInfo _ImActorModelEntityGroupMember = { 1, "GroupMember", "im.actor.model.entity", NULL, 0x1, 4, methods, 3, fields, 0, NULL};
  return &_ImActorModelEntityGroupMember;
}

@end

J2OBJC_CLASS_TYPE_LITERAL_SOURCE(ImActorModelEntityGroupMember)