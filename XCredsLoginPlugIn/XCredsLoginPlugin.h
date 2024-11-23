//
//  XCredsLoginPlugin.h
//  XCredsLoginPlugin
//
//  Created by Timothy Perfitt on 7/2/22.
//

#import <Foundation/Foundation.h>


@import Foundation;
@import Security.AuthorizationPlugin;
@import Security.AuthSession;
extern OSStatus SecKeychainChangePassword(SecKeychainRef keychainRef, UInt32 oldPasswordLength, const void* oldPassword, UInt32 newPasswordLength, const void* newPassword);

extern OSStatus SecKeychainResetLogin(UInt32 passwordLength,
                                      const void* password,
                                      Boolean resetSearchList);

extern OSStatus SecKeychainItemSetAccessWithPassword(SecKeychainItemRef item, SecAccessRef access, UInt32 passLength, const void* password);


// Plugin constants

enum {
    kPluginMagic = 'PlgN'
};

struct PluginRecord {
    OSType fMagic;
    const AuthorizationCallbacks *fCallbacks;
};

typedef struct PluginRecord PluginRecord;

#pragma mark - Mechanism

enum {
    kMechanismMagic = 'Mchn'
};

struct MechanismRecord {
    OSType                          fMagic;
    AuthorizationEngineRef          fEngine;
    const PluginRecord *            fPlugin;
    AuthorizationString             fMechID;
    Boolean                         fCheckAD;
    Boolean                         fUserSetup;

    Boolean                         fLoginWindow;
    Boolean                         fPowerControl;
    Boolean                         fEnableFDE;
    Boolean                         fKeychainAdd;
    Boolean                         fCreateUser;
    Boolean                         fLoginDone;

};

typedef struct MechanismRecord MechanismRecord;

#pragma mark
#pragma mark ObjC AuthPlugin Wrapper

@interface XCredsLoginPlugin : NSObject
- (OSStatus)MechanismCreate:(AuthorizationPluginRef)inPlugin
                  EngineRef:(AuthorizationEngineRef)inEngine
                MechanismId:(AuthorizationMechanismId)mechanismId
               MechanismRef:(AuthorizationMechanismRef *)outMechanism;

// Starts authentication

- (OSStatus)MechanismInvoke:(AuthorizationMechanismRef)inMechanism;

// Decactive mechanism

- (OSStatus)MechanismDeactivate:(AuthorizationMechanismRef)inMechanism;

// Destroys mechanism

- (OSStatus)MechanismDestroy:(AuthorizationMechanismRef)inMechanism;

// Plugin parts

// Destroy plugin

- (OSStatus)PluginDestroy:(AuthorizationPluginRef)inPlugin;

// Creates plugin

- (OSStatus)AuthorizationPluginCreate:(const AuthorizationCallbacks *)callbacks
                            PluginRef:(AuthorizationPluginRef *)outPlugin
                      PluginInterface:(const AuthorizationPluginInterface **)outPluginInterface;

@end

