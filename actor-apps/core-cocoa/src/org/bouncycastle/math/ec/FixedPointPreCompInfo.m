//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/ex3ndr/Develop/actor-proprietary/actor-apps/core-crypto/src/main/java/org/bouncycastle/math/ec/FixedPointPreCompInfo.java
//


#include "IOSObjectArray.h"
#include "J2ObjC_source.h"
#include "org/bouncycastle/math/ec/FixedPointPreCompInfo.h"

@implementation OrgBouncycastleMathEcFixedPointPreCompInfo

- (IOSObjectArray *)getPreComp {
  return preComp_;
}

- (void)setPreCompWithOrgBouncycastleMathEcECPointArray:(IOSObjectArray *)preComp {
  self->preComp_ = preComp;
}

- (jint)getWidth {
  return width_;
}

- (void)setWidthWithInt:(jint)width {
  self->width_ = width;
}

- (instancetype)init {
  OrgBouncycastleMathEcFixedPointPreCompInfo_init(self);
  return self;
}

@end

void OrgBouncycastleMathEcFixedPointPreCompInfo_init(OrgBouncycastleMathEcFixedPointPreCompInfo *self) {
  (void) NSObject_init(self);
  self->preComp_ = nil;
  self->width_ = -1;
}

OrgBouncycastleMathEcFixedPointPreCompInfo *new_OrgBouncycastleMathEcFixedPointPreCompInfo_init() {
  OrgBouncycastleMathEcFixedPointPreCompInfo *self = [OrgBouncycastleMathEcFixedPointPreCompInfo alloc];
  OrgBouncycastleMathEcFixedPointPreCompInfo_init(self);
  return self;
}

J2OBJC_CLASS_TYPE_LITERAL_SOURCE(OrgBouncycastleMathEcFixedPointPreCompInfo)