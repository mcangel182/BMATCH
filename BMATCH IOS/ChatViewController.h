//
//  ChatViewController.h
//  BMATCH IOS
//
//  Created by María Camila Angel on 3/06/14.
//  Copyright (c) 2014 María Camila Angel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSQMessages.h"
#import <Parse/Parse.h>

@class ChatViewController;


@protocol JSQDemoViewControllerDelegate <NSObject>

- (void)didDismissJSQDemoViewController:(ChatViewController *)vc;

@end

@interface ChatViewController : JSQMessagesViewController

@property (weak, nonatomic) id<JSQDemoViewControllerDelegate> delegateModal;

@property (strong, nonatomic) NSMutableArray *messages;
@property (copy, nonatomic) NSDictionary *avatars;

@property (strong, nonatomic) UIImageView *outgoingBubbleImageView;
@property (strong, nonatomic) UIImageView *incomingBubbleImageView;
@property (strong, nonatomic) PFObject* chat;

- (void)setChat:(PFObject *)chat;

- (void) setChatUser:(PFObject *)chatUser;

-(void)recieveMessage:(NSString *)message sender:(NSString*)sender;

@end
