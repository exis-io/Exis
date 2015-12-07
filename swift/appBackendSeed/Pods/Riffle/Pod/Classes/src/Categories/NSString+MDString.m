//
//  NSString+MDString.m
//  MDWamp
//
//  Created by Niko Usai on 09/03/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "NSString+MDString.h"
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>

@implementation NSString (MDString)

+ (NSString*) stringWithRandomId
{
	NSInteger ii;
    NSString *allletters = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuwxyz0123456789";
	NSString *outstring = @"";
    for (ii=0; ii<20; ii++) {
        outstring = [outstring stringByAppendingString:[allletters substringWithRange:[allletters rangeOfComposedCharacterSequenceAtIndex:random()%[allletters length]]]];
    }
	
    return outstring;
}

- (NSString *) hmacSHA256DataWithKey:(NSString *)key
{
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [self cStringUsingEncoding:NSASCIIStringEncoding];
    
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);

    //return [[NSData dataWithBytes:cHMAC length:CC_SHA1_DIGEST_LENGTH] base64Encoding];
    return [[NSData dataWithBytes:cHMAC length:CC_SHA1_DIGEST_LENGTH] base64EncodedStringWithOptions:0];
}


@end
