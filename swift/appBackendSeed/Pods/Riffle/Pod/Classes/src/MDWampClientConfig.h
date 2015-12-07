//
//  MDWampClientConfig.h
//  MDWamp
//
//  Created by Niko Usai on 09/10/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import <Foundation/Foundation.h>

// ROles
extern NSString* const kMDWampRolePublisher;
extern NSString* const kMDWampRoleSubscriber;
extern NSString* const kMDWampRoleCaller;
extern NSString* const kMDWampRoleCallee;

// Auth methods
extern NSString* const kMDWampAuthMethodCRA;
extern NSString* const kMDWampAuthMethodTicket;

@interface MDWampClientConfig : NSObject

#pragma mark Generics
/**
 *  An array of MDWampRoles the client will assume on connection
 *  default is all roles along with all advanced feature
 */
@property (nonatomic, strong) NSDictionary *roles;

/**
 *  Similar to what browsers do with the User-Agent HTTP header,
 *  HELLO message MAY disclose the WAMP implementation in use to its peer
 */
@property (nonatomic, strong) NSString *agent;

#pragma mark Authentication
/**
 *  Shared secret to use in wampCRA
 */
@property (nonatomic, strong) NSString *sharedSecret;

/**
 *  Ticket used with ticket-based Auth
 */
@property (nonatomic, strong) NSString *ticket;

/**
 *  list of authentication method that client is willing to use, currently implemented are:
 *      wampcra - WAMP Challenge-Response Authentication
 */
@property (nonatomic, strong) NSArray *authmethods;

/**
 *  the authentication ID (e.g. username) the client wishes to authenticate as
 */
@property (nonatomic, strong) NSString *authid;

/**
 *  Block used to defer the signing of a Wamp CRA challange
 * in the block you do your processing to sign the challange (async if you need)
 * once getted the signature call
 */
@property (nonatomic, strong) void (^deferredWampCRASigningBlock)( NSString *challange, void(^finishBLock)(NSString *signature) );

#pragma mark Pub/Sub

/**
 * Default config when Sending a Publish request (can be overrided using options dictionary for every PUBLISH mesg)
 * If YES Publisher receives a PUBLISHED acknowledge message from router
 * default: NO
 */
@property (nonatomic, assign) BOOL publisher_acknowledge;

/**
 * Default config when Sending a Publish request (can be overrided using options dictionary for every PUBLISH mesg)
 * If YES the Publisher will NOT receive the messages he sends to the topic he is subscribed to
 * default: YES
 */
@property (nonatomic, assign) BOOL publisher_exclude_me;

/**
 * Default config when Sending a Publish request (can be overrided using options dictionary for every PUBLISH mesg)
 * If YES the Publisher  request the disclosure of its identity (its WAMP session ID) to receivers of a published event
 * default: NO
 */
@property (nonatomic, assign) BOOL publisher_identification;

/**
 * Default config when Sending a Call request (can be overrided using options dictionary for every mesg)
 * If YES the Caller will NOT receive the call of a procedure if he has registered to that procedure
 * default: YES
 */
@property (nonatomic, assign) BOOL caller_exclude_me;

/**
 * Default config when Sending a CALL request (can be overrided using options dictionary for every mesg)
 * If YES the Caller  request the disclosure of its identity (its WAMP session ID) to callee
 * default: NO
 */
@property (nonatomic, assign) BOOL caller_identification;

/**
 * Default config when Sending a CALL request (can be overrided using options dictionary for every mesg)
 * If YES the Caller indicates it's willingness to receive progressive results
 * default: NO

 */
@property (nonatomic, assign) BOOL caller_progressive_result;

#pragma mark Helpers
/**
 *  returns a suitable Dictionary to be used as details settings for an HELLO message
 *
 *  @return NSDictionary hello details dictionary
 */
- (NSDictionary *) getHelloDetails;



@end