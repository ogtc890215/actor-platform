//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/ex3ndr/Develop/actor-model/actor-ios/build/java/im/actor/model/modules/contacts/ContactsSyncActor.java
//

#include "IOSObjectArray.h"
#include "IOSPrimitiveArray.h"
#include "J2ObjC_source.h"
#include "im/actor/model/Configuration.h"
#include "im/actor/model/api/User.h"
#include "im/actor/model/api/rpc/RequestGetContacts.h"
#include "im/actor/model/api/rpc/ResponseGetContacts.h"
#include "im/actor/model/crypto/CryptoUtils.h"
#include "im/actor/model/droidkit/actors/Actor.h"
#include "im/actor/model/droidkit/actors/ActorRef.h"
#include "im/actor/model/droidkit/bser/DataInput.h"
#include "im/actor/model/droidkit/bser/DataOutput.h"
#include "im/actor/model/droidkit/engine/ListEngine.h"
#include "im/actor/model/droidkit/engine/PreferencesStorage.h"
#include "im/actor/model/entity/Avatar.h"
#include "im/actor/model/entity/Contact.h"
#include "im/actor/model/entity/User.h"
#include "im/actor/model/log/Log.h"
#include "im/actor/model/modules/Contacts.h"
#include "im/actor/model/modules/Modules.h"
#include "im/actor/model/modules/Updates.h"
#include "im/actor/model/modules/contacts/ContactsSyncActor.h"
#include "im/actor/model/modules/updates/internal/ContactsLoaded.h"
#include "im/actor/model/modules/utils/ModuleActor.h"
#include "im/actor/model/mvvm/ValueModel.h"
#include "im/actor/model/network/RpcException.h"
#include "im/actor/model/viewmodel/UserVM.h"
#include "java/io/IOException.h"
#include "java/lang/Boolean.h"
#include "java/lang/Integer.h"
#include "java/util/ArrayList.h"
#include "java/util/Arrays.h"
#include "java/util/Collections.h"
#include "java/util/List.h"

__attribute__((unused)) static void ImActorModelModulesContactsContactsSyncActor_updateEngineList(ImActorModelModulesContactsContactsSyncActor *self);
__attribute__((unused)) static void ImActorModelModulesContactsContactsSyncActor_saveList(ImActorModelModulesContactsContactsSyncActor *self);

@interface ImActorModelModulesContactsContactsSyncActor () {
 @public
  jboolean ENABLE_LOG_;
  JavaUtilArrayList *contacts_;
  jboolean isInProgress_;
  jboolean isInvalidated_;
}

- (void)updateEngineList;

- (void)saveList;
@end

J2OBJC_FIELD_SETTER(ImActorModelModulesContactsContactsSyncActor, contacts_, JavaUtilArrayList *)

@interface ImActorModelModulesContactsContactsSyncActor_PerformSync ()
- (instancetype)init;
@end

@interface ImActorModelModulesContactsContactsSyncActor_ContactsLoaded () {
 @public
  ImActorModelApiRpcResponseGetContacts *result_;
}
@end

J2OBJC_FIELD_SETTER(ImActorModelModulesContactsContactsSyncActor_ContactsLoaded, result_, ImActorModelApiRpcResponseGetContacts *)

@interface ImActorModelModulesContactsContactsSyncActor_ContactsAdded () {
 @public
  IOSIntArray *uids_;
}
@end

J2OBJC_FIELD_SETTER(ImActorModelModulesContactsContactsSyncActor_ContactsAdded, uids_, IOSIntArray *)

@interface ImActorModelModulesContactsContactsSyncActor_ContactsRemoved () {
 @public
  IOSIntArray *uids_;
}
@end

J2OBJC_FIELD_SETTER(ImActorModelModulesContactsContactsSyncActor_ContactsRemoved, uids_, IOSIntArray *)

@interface ImActorModelModulesContactsContactsSyncActor_UserChanged () {
 @public
  AMUser *user_;
}
@end

J2OBJC_FIELD_SETTER(ImActorModelModulesContactsContactsSyncActor_UserChanged, user_, AMUser *)

@interface ImActorModelModulesContactsContactsSyncActor_$1 () {
 @public
  ImActorModelModulesContactsContactsSyncActor *this$0_;
}
@end

J2OBJC_FIELD_SETTER(ImActorModelModulesContactsContactsSyncActor_$1, this$0_, ImActorModelModulesContactsContactsSyncActor *)

@implementation ImActorModelModulesContactsContactsSyncActor

NSString * ImActorModelModulesContactsContactsSyncActor_TAG_ = @"ContactsServerSync";

- (instancetype)initWithImActorModelModulesModules:(ImActorModelModulesModules *)messenger {
  if (self = [super initWithImActorModelModulesModules:messenger]) {
    contacts_ = [[JavaUtilArrayList alloc] init];
    isInProgress_ = NO;
    isInvalidated_ = NO;
    ENABLE_LOG_ = [((AMConfiguration *) nil_chk([((ImActorModelModulesModules *) nil_chk(messenger)) getConfiguration])) isEnableContactsLogging];
  }
  return self;
}

- (void)preStart {
  [super preStart];
  if (ENABLE_LOG_) {
    AMLog_dWithNSString_withNSString_(ImActorModelModulesContactsContactsSyncActor_TAG_, @"Loading contacts ids from storage...");
  }
  IOSByteArray *data = [((id<DKPreferencesStorage>) nil_chk([self preferences])) getBytes:@"contact_list"];
  if (data != nil) {
    @try {
      BSDataInput *dataInput = [[BSDataInput alloc] initWithByteArray:data withInt:0 withInt:data->size_];
      jint count = [dataInput readInt];
      for (jint i = 0; i < count; i++) {
        [((JavaUtilArrayList *) nil_chk(contacts_)) addWithId:JavaLangInteger_valueOfWithInt_([dataInput readInt])];
      }
    }
    @catch (JavaIoIOException *e) {
      [((JavaIoIOException *) nil_chk(e)) printStackTrace];
    }
  }
  [((DKActorRef *) nil_chk([self self__])) sendWithId:[[ImActorModelModulesContactsContactsSyncActor_PerformSync alloc] init]];
}

- (void)performSync {
  if (ENABLE_LOG_) {
    AMLog_dWithNSString_withNSString_(ImActorModelModulesContactsContactsSyncActor_TAG_, @"Checking sync");
  }
  if (isInProgress_) {
    if (ENABLE_LOG_) {
      AMLog_dWithNSString_withNSString_(ImActorModelModulesContactsContactsSyncActor_TAG_, @"Sync in progress, invalidating current sync");
    }
    isInvalidated_ = YES;
    return;
  }
  isInProgress_ = YES;
  isInvalidated_ = NO;
  if (ENABLE_LOG_) {
    AMLog_dWithNSString_withNSString_(ImActorModelModulesContactsContactsSyncActor_TAG_, @"Starting sync");
  }
  IOSObjectArray *uids = [((JavaUtilArrayList *) nil_chk(contacts_)) toArrayWithNSObjectArray:[IOSObjectArray newArrayWithLength:0 type:JavaLangInteger_class_()]];
  JavaUtilArrays_sortWithNSObjectArray_(uids);
  NSString *hash_ = @"";
  {
    IOSObjectArray *a__ = uids;
    JavaLangInteger * const *b__ = ((IOSObjectArray *) nil_chk(a__))->buffer_;
    JavaLangInteger * const *e__ = b__ + a__->size_;
    while (b__ < e__) {
      jlong u = [((JavaLangInteger *) nil_chk(*b__++)) intValue];
      if (((jint) [hash_ length]) != 0) {
        hash_ = JreStrcat("$C", hash_, ',');
      }
      hash_ = JreStrcat("$J", hash_, u);
    }
  }
  NSString *hashValue = AMCryptoUtils_hexWithByteArray_(AMCryptoUtils_SHA256WithByteArray_([hash_ getBytes]));
  AMLog_dWithNSString_withNSString_(ImActorModelModulesContactsContactsSyncActor_TAG_, JreStrcat("$$", @"Performing sync with uids: ", hash_));
  AMLog_dWithNSString_withNSString_(ImActorModelModulesContactsContactsSyncActor_TAG_, JreStrcat("$$", @"Performing sync with hash: ", hashValue));
  [self requestWithImActorModelNetworkParserRequest:[[ImActorModelApiRpcRequestGetContacts alloc] initWithNSString:hashValue] withAMRpcCallback:[[ImActorModelModulesContactsContactsSyncActor_$1 alloc] initWithImActorModelModulesContactsContactsSyncActor:self]];
}

- (void)onContactsLoadedWithImActorModelApiRpcResponseGetContacts:(ImActorModelApiRpcResponseGetContacts *)result {
  if (ENABLE_LOG_) {
    AMLog_dWithNSString_withNSString_(ImActorModelModulesContactsContactsSyncActor_TAG_, @"Sync result received");
  }
  isInProgress_ = NO;
  if ([((ImActorModelApiRpcResponseGetContacts *) nil_chk(result)) isNotChanged]) {
    AMLog_dWithNSString_withNSString_(ImActorModelModulesContactsContactsSyncActor_TAG_, @"Sync: Not changed");
    if (isInvalidated_) {
      [self performSync];
    }
    else {
    }
    return;
  }
  if (ENABLE_LOG_) {
    AMLog_dWithNSString_withNSString_(ImActorModelModulesContactsContactsSyncActor_TAG_, JreStrcat("$I$", @"Sync received ", [((id<JavaUtilList>) nil_chk([result getUsers])) size], @" contacts"));
  }
  {
    IOSObjectArray *a__ = [contacts_ toArrayWithNSObjectArray:[IOSObjectArray newArrayWithLength:[((JavaUtilArrayList *) nil_chk(contacts_)) size] type:JavaLangInteger_class_()]];
    JavaLangInteger * const *b__ = ((IOSObjectArray *) nil_chk(a__))->buffer_;
    JavaLangInteger * const *e__ = b__ + a__->size_;
    while (b__ < e__) {
      JavaLangInteger *uid = *b__++;
      {
        for (ImActorModelApiUser * __strong u in nil_chk([result getUsers])) {
          if ([((ImActorModelApiUser *) nil_chk(u)) getId] == [((JavaLangInteger *) nil_chk(uid)) intValue]) {
            goto continue_outer;
          }
        }
        if (ENABLE_LOG_) {
          AMLog_dWithNSString_withNSString_(ImActorModelModulesContactsContactsSyncActor_TAG_, JreStrcat("$@", @"Removing: #", uid));
        }
        [contacts_ removeWithId:(JavaLangInteger *) check_class_cast(uid, [JavaLangInteger class])];
        if ([self getUserWithInt:[((JavaLangInteger *) nil_chk(uid)) intValue]] != nil) {
          [((AMValueModel *) nil_chk([((AMUserVM *) nil_chk([self getUserVMWithInt:[uid intValue]])) isContact])) changeWithId:JavaLangBoolean_valueOfWithBoolean_(NO)];
        }
        [((ImActorModelModulesContacts *) nil_chk([((ImActorModelModulesModules *) nil_chk([self modules])) getContactsModule])) markNonContactWithInt:[uid intValue]];
      }
      continue_outer: ;
    }
  }
  for (ImActorModelApiUser * __strong u in nil_chk([result getUsers])) {
    if ([contacts_ containsWithId:JavaLangInteger_valueOfWithInt_([((ImActorModelApiUser *) nil_chk(u)) getId])]) {
      continue;
    }
    if (ENABLE_LOG_) {
      AMLog_dWithNSString_withNSString_(ImActorModelModulesContactsContactsSyncActor_TAG_, JreStrcat("$I", @"Adding: #", [u getId]));
    }
    [contacts_ addWithId:JavaLangInteger_valueOfWithInt_([u getId])];
    if ([self getUserWithInt:[u getId]] != nil) {
      [((AMValueModel *) nil_chk([((AMUserVM *) nil_chk([self getUserVMWithInt:[u getId]])) isContact])) changeWithId:JavaLangBoolean_valueOfWithBoolean_(YES)];
    }
    [((ImActorModelModulesContacts *) nil_chk([((ImActorModelModulesModules *) nil_chk([self modules])) getContactsModule])) markContactWithInt:[u getId]];
  }
  ImActorModelModulesContactsContactsSyncActor_saveList(self);
  ImActorModelModulesContactsContactsSyncActor_updateEngineList(self);
  if (isInvalidated_) {
    [((DKActorRef *) nil_chk([self self__])) sendWithId:[[ImActorModelModulesContactsContactsSyncActor_PerformSync alloc] init]];
  }
}

- (void)onContactsAddedWithIntArray:(IOSIntArray *)uids {
  if (ENABLE_LOG_) {
    AMLog_dWithNSString_withNSString_(ImActorModelModulesContactsContactsSyncActor_TAG_, @"OnContactsAdded received");
  }
  {
    IOSIntArray *a__ = uids;
    jint const *b__ = ((IOSIntArray *) nil_chk(a__))->buffer_;
    jint const *e__ = b__ + a__->size_;
    while (b__ < e__) {
      jint uid = *b__++;
      if (ENABLE_LOG_) {
        AMLog_dWithNSString_withNSString_(ImActorModelModulesContactsContactsSyncActor_TAG_, JreStrcat("$I", @"Adding: #", uid));
      }
      [((JavaUtilArrayList *) nil_chk(contacts_)) addWithId:JavaLangInteger_valueOfWithInt_(uid)];
      [((ImActorModelModulesContacts *) nil_chk([((ImActorModelModulesModules *) nil_chk([self modules])) getContactsModule])) markContactWithInt:uid];
      [((AMValueModel *) nil_chk([((AMUserVM *) nil_chk([self getUserVMWithInt:uid])) isContact])) changeWithId:JavaLangBoolean_valueOfWithBoolean_(YES)];
    }
  }
  ImActorModelModulesContactsContactsSyncActor_saveList(self);
  ImActorModelModulesContactsContactsSyncActor_updateEngineList(self);
  [((DKActorRef *) nil_chk([self self__])) sendWithId:[[ImActorModelModulesContactsContactsSyncActor_PerformSync alloc] init]];
}

- (void)onContactsRemovedWithIntArray:(IOSIntArray *)uids {
  if (ENABLE_LOG_) {
    AMLog_dWithNSString_withNSString_(ImActorModelModulesContactsContactsSyncActor_TAG_, @"OnContactsRemoved received");
  }
  {
    IOSIntArray *a__ = uids;
    jint const *b__ = ((IOSIntArray *) nil_chk(a__))->buffer_;
    jint const *e__ = b__ + a__->size_;
    while (b__ < e__) {
      jint uid = *b__++;
      AMLog_dWithNSString_withNSString_(ImActorModelModulesContactsContactsSyncActor_TAG_, JreStrcat("$I", @"Removing: #", uid));
      [((JavaUtilArrayList *) nil_chk(contacts_)) removeWithId:JavaLangInteger_valueOfWithInt_(uid)];
      [((ImActorModelModulesContacts *) nil_chk([((ImActorModelModulesModules *) nil_chk([self modules])) getContactsModule])) markNonContactWithInt:uid];
      [((AMValueModel *) nil_chk([((AMUserVM *) nil_chk([self getUserVMWithInt:uid])) isContact])) changeWithId:JavaLangBoolean_valueOfWithBoolean_(NO)];
    }
  }
  ImActorModelModulesContactsContactsSyncActor_saveList(self);
  ImActorModelModulesContactsContactsSyncActor_updateEngineList(self);
  [((DKActorRef *) nil_chk([self self__])) sendWithId:[[ImActorModelModulesContactsContactsSyncActor_PerformSync alloc] init]];
}

- (void)onUserChangedWithAMUser:(AMUser *)user {
  if (ENABLE_LOG_) {
    AMLog_dWithNSString_withNSString_(ImActorModelModulesContactsContactsSyncActor_TAG_, JreStrcat("$I$", @"OnUserChanged #", [((AMUser *) nil_chk(user)) getUid], @" received"));
  }
  if (![((JavaUtilArrayList *) nil_chk(contacts_)) containsWithId:JavaLangInteger_valueOfWithInt_([((AMUser *) nil_chk(user)) getUid])]) {
    return;
  }
  ImActorModelModulesContactsContactsSyncActor_updateEngineList(self);
}

- (void)updateEngineList {
  ImActorModelModulesContactsContactsSyncActor_updateEngineList(self);
}

- (void)saveList {
  ImActorModelModulesContactsContactsSyncActor_saveList(self);
}

- (void)onReceiveWithId:(id)message {
  if ([message isKindOfClass:[ImActorModelModulesContactsContactsSyncActor_ContactsLoaded class]]) {
    [self onContactsLoadedWithImActorModelApiRpcResponseGetContacts:[((ImActorModelModulesContactsContactsSyncActor_ContactsLoaded *) nil_chk(((ImActorModelModulesContactsContactsSyncActor_ContactsLoaded *) check_class_cast(message, [ImActorModelModulesContactsContactsSyncActor_ContactsLoaded class])))) getResult]];
  }
  else if ([message isKindOfClass:[ImActorModelModulesContactsContactsSyncActor_ContactsAdded class]]) {
    [self onContactsAddedWithIntArray:[((ImActorModelModulesContactsContactsSyncActor_ContactsAdded *) nil_chk(((ImActorModelModulesContactsContactsSyncActor_ContactsAdded *) check_class_cast(message, [ImActorModelModulesContactsContactsSyncActor_ContactsAdded class])))) getUids]];
  }
  else if ([message isKindOfClass:[ImActorModelModulesContactsContactsSyncActor_ContactsRemoved class]]) {
    [self onContactsRemovedWithIntArray:[((ImActorModelModulesContactsContactsSyncActor_ContactsRemoved *) nil_chk(((ImActorModelModulesContactsContactsSyncActor_ContactsRemoved *) check_class_cast(message, [ImActorModelModulesContactsContactsSyncActor_ContactsRemoved class])))) getUids]];
  }
  else if ([message isKindOfClass:[ImActorModelModulesContactsContactsSyncActor_UserChanged class]]) {
    [self onUserChangedWithAMUser:[((ImActorModelModulesContactsContactsSyncActor_UserChanged *) nil_chk(((ImActorModelModulesContactsContactsSyncActor_UserChanged *) check_class_cast(message, [ImActorModelModulesContactsContactsSyncActor_UserChanged class])))) getUser]];
  }
  else if ([message isKindOfClass:[ImActorModelModulesContactsContactsSyncActor_PerformSync class]]) {
    [self performSync];
  }
  else {
    [self dropWithId:message];
  }
}

- (void)copyAllFieldsTo:(ImActorModelModulesContactsContactsSyncActor *)other {
  [super copyAllFieldsTo:other];
  other->ENABLE_LOG_ = ENABLE_LOG_;
  other->contacts_ = contacts_;
  other->isInProgress_ = isInProgress_;
  other->isInvalidated_ = isInvalidated_;
}

@end

void ImActorModelModulesContactsContactsSyncActor_updateEngineList(ImActorModelModulesContactsContactsSyncActor *self) {
  if (self->ENABLE_LOG_) {
    AMLog_dWithNSString_withNSString_(ImActorModelModulesContactsContactsSyncActor_TAG_, @"Saving contact EngineList");
  }
  JavaUtilArrayList *userList = [[JavaUtilArrayList alloc] init];
  for (JavaLangInteger *boxed__ in nil_chk(self->contacts_)) {
    jint u = [((JavaLangInteger *) nil_chk(boxed__)) intValue];
    [userList addWithId:[self getUserWithInt:u]];
  }
  JavaUtilCollections_sortWithJavaUtilList_withJavaUtilComparator_(userList, [[ImActorModelModulesContactsContactsSyncActor_$2 alloc] init]);
  id<JavaUtilList> registeredContacts = [[JavaUtilArrayList alloc] init];
  jint index = -1;
  for (AMUser * __strong userModel in userList) {
    AMContact *contact = [[AMContact alloc] initWithInt:[((AMUser *) nil_chk(userModel)) getUid] withLong:(jlong) index-- withAMAvatar:[userModel getAvatar] withNSString:[userModel getName]];
    [registeredContacts addWithId:contact];
  }
  [((id<DKListEngine>) nil_chk([((ImActorModelModulesContacts *) nil_chk([((ImActorModelModulesModules *) nil_chk([self modules])) getContactsModule])) getContacts])) replaceItemsWithJavaUtilList:registeredContacts];
}

void ImActorModelModulesContactsContactsSyncActor_saveList(ImActorModelModulesContactsContactsSyncActor *self) {
  if (self->ENABLE_LOG_) {
    AMLog_dWithNSString_withNSString_(ImActorModelModulesContactsContactsSyncActor_TAG_, @"Saving contacts ids to storage");
  }
  BSDataOutput *dataOutput = [[BSDataOutput alloc] init];
  [dataOutput writeIntWithInt:[((JavaUtilArrayList *) nil_chk(self->contacts_)) size]];
  for (JavaLangInteger *boxed__ in self->contacts_) {
    jint l = [((JavaLangInteger *) nil_chk(boxed__)) intValue];
    [dataOutput writeIntWithInt:l];
  }
  [((id<DKPreferencesStorage>) nil_chk([self preferences])) putBytes:@"contact_list" withValue:[dataOutput toByteArray]];
}

J2OBJC_CLASS_TYPE_LITERAL_SOURCE(ImActorModelModulesContactsContactsSyncActor)

@implementation ImActorModelModulesContactsContactsSyncActor_PerformSync

- (instancetype)init {
  return [super init];
}

@end

J2OBJC_CLASS_TYPE_LITERAL_SOURCE(ImActorModelModulesContactsContactsSyncActor_PerformSync)

@implementation ImActorModelModulesContactsContactsSyncActor_ContactsLoaded

- (instancetype)initWithImActorModelApiRpcResponseGetContacts:(ImActorModelApiRpcResponseGetContacts *)result {
  if (self = [super init]) {
    self->result_ = result;
  }
  return self;
}

- (ImActorModelApiRpcResponseGetContacts *)getResult {
  return result_;
}

- (void)copyAllFieldsTo:(ImActorModelModulesContactsContactsSyncActor_ContactsLoaded *)other {
  [super copyAllFieldsTo:other];
  other->result_ = result_;
}

@end

J2OBJC_CLASS_TYPE_LITERAL_SOURCE(ImActorModelModulesContactsContactsSyncActor_ContactsLoaded)

@implementation ImActorModelModulesContactsContactsSyncActor_ContactsAdded

- (instancetype)initWithIntArray:(IOSIntArray *)uids {
  if (self = [super init]) {
    self->uids_ = uids;
  }
  return self;
}

- (IOSIntArray *)getUids {
  return uids_;
}

- (void)copyAllFieldsTo:(ImActorModelModulesContactsContactsSyncActor_ContactsAdded *)other {
  [super copyAllFieldsTo:other];
  other->uids_ = uids_;
}

@end

J2OBJC_CLASS_TYPE_LITERAL_SOURCE(ImActorModelModulesContactsContactsSyncActor_ContactsAdded)

@implementation ImActorModelModulesContactsContactsSyncActor_ContactsRemoved

- (instancetype)initWithIntArray:(IOSIntArray *)uids {
  if (self = [super init]) {
    self->uids_ = uids;
  }
  return self;
}

- (IOSIntArray *)getUids {
  return uids_;
}

- (void)copyAllFieldsTo:(ImActorModelModulesContactsContactsSyncActor_ContactsRemoved *)other {
  [super copyAllFieldsTo:other];
  other->uids_ = uids_;
}

@end

J2OBJC_CLASS_TYPE_LITERAL_SOURCE(ImActorModelModulesContactsContactsSyncActor_ContactsRemoved)

@implementation ImActorModelModulesContactsContactsSyncActor_UserChanged

- (instancetype)initWithAMUser:(AMUser *)user {
  if (self = [super init]) {
    self->user_ = user;
  }
  return self;
}

- (AMUser *)getUser {
  return user_;
}

- (void)copyAllFieldsTo:(ImActorModelModulesContactsContactsSyncActor_UserChanged *)other {
  [super copyAllFieldsTo:other];
  other->user_ = user_;
}

@end

J2OBJC_CLASS_TYPE_LITERAL_SOURCE(ImActorModelModulesContactsContactsSyncActor_UserChanged)

@implementation ImActorModelModulesContactsContactsSyncActor_$1

- (void)onResultWithImActorModelNetworkParserResponse:(ImActorModelApiRpcResponseGetContacts *)response {
  [((ImActorModelModulesUpdates *) nil_chk([this$0_ updates])) onUpdateReceivedWithId:[[ImActorModelModulesUpdatesInternalContactsLoaded alloc] initWithImActorModelApiRpcResponseGetContacts:response]];
}

- (void)onErrorWithAMRpcException:(AMRpcException *)e {
  this$0_->isInProgress_ = NO;
  [((AMRpcException *) nil_chk(e)) printStackTrace];
}

- (instancetype)initWithImActorModelModulesContactsContactsSyncActor:(ImActorModelModulesContactsContactsSyncActor *)outer$ {
  this$0_ = outer$;
  return [super init];
}

- (void)copyAllFieldsTo:(ImActorModelModulesContactsContactsSyncActor_$1 *)other {
  [super copyAllFieldsTo:other];
  other->this$0_ = this$0_;
}

@end

J2OBJC_CLASS_TYPE_LITERAL_SOURCE(ImActorModelModulesContactsContactsSyncActor_$1)

@implementation ImActorModelModulesContactsContactsSyncActor_$2

- (jint)compareWithId:(AMUser *)lhs
               withId:(AMUser *)rhs {
  return [((NSString *) nil_chk([((AMUser *) nil_chk(lhs)) getName])) compareToWithId:[((AMUser *) nil_chk(rhs)) getName]];
}

- (instancetype)init {
  return [super init];
}

@end

J2OBJC_CLASS_TYPE_LITERAL_SOURCE(ImActorModelModulesContactsContactsSyncActor_$2)
