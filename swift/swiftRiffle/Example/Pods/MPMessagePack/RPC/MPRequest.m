//
//  MPRequest.m
//  MPMessagePack
//
//  Created by Gabriel on 10/14/15.
//  Copyright © 2015 Gabriel Handford. All rights reserved.
//

#import "MPRequest.h"

@interface MPRequest ()
@property MPRequestCompletion completion;
@end

@implementation MPRequest

+ (instancetype)requestWithCompletion:(MPRequestCompletion)completion {
  MPRequest *request = [[MPRequest alloc] init];
  request.completion = completion;
  return request;
}

- (void)completeWithResult:(id)result error:(NSError *)error {
  self.completion(error, result);
  self.completion = nil;
}

@end
