//
//  ChatViewController.m
//  BMATCH IOS
//
//  Created by María Camila Angel on 3/06/14.
//  Copyright (c) 2014 María Camila Angel. All rights reserved.
//

#import "ChatViewController.h"
#import <Parse/Parse.h>

@interface ChatViewController ()
{
    IBOutlet UINavigationItem *navigationHeader;
    
}
@property (strong, nonatomic) PFObject* chatUser;

@end

@implementation ChatViewController

@synthesize chat = _chat;
@synthesize chatUser = _chatUser;

-(void)loadMessages{
    self.messages = [[NSMutableArray alloc] init];
    NSArray *users = [[NSArray alloc] initWithObjects:_chatUser, [PFUser currentUser], nil];
    PFQuery *query = [PFQuery queryWithClassName:@"ChatMessage"];
    [query whereKey:@"chat" equalTo:_chat];
    [query whereKey:@"from" containedIn:users];
    [query orderByAscending:@"createdAt"];
    NSArray *messages = [query findObjects];
    JSQMessage *msg;
    
    for (PFObject *message in messages) {
        if([[message[@"from"] objectId] isEqualToString:[PFUser currentUser].objectId]){
            msg = [[JSQMessage alloc] initWithText:message[@"message"] sender:self.sender date:[message createdAt]];
            [self.messages addObject:msg];
        }
        else{
            msg = [[JSQMessage alloc] initWithText:message[@"message"] sender:self.title date:[message createdAt]];
            [self.messages addObject:msg];

        }
        
    }
}

- (void)viewDidLoad
{
    printf("\n\n HIZOOO VIEW DID LOOOAAADD!!!\n\n");
    [super viewDidLoad];
    
    self.sender = [PFUser currentUser][@"name"];
    
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    
    // Configuración del titulo de la vista
    [_chatUser fetchIfNeeded];
    NSString *nombreCompleto = _chatUser[@"name"];
    nombreCompleto = [nombreCompleto stringByAppendingString:@" "];
    nombreCompleto = [nombreCompleto stringByAppendingString:_chatUser[@"lastName"]];
    self.title = nombreCompleto;
    
    self.hidesBottomBarWhenPushed = YES;

    /**
     * Despliegue de mensajes del chat
     */

    [self loadMessages];
   
    /**
     *  Create bubble images.
     */
    self.outgoingBubbleImageView = [JSQMessagesBubbleImageFactory
                                    outgoingMessageBubbleImageViewWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    
    self.incomingBubbleImageView = [JSQMessagesBubbleImageFactory
                                    incomingMessageBubbleImageViewWithColor:[UIColor jsq_messageBubbleBlueColor]];
    /**
     * Quitar camera
     */
    self.inputToolbar.contentView.leftBarButtonItem = nil;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.delegateModal) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                              target:self
                                                                                              action:@selector(closePressed:)];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    /**
     *  Enable/disable springy bubbles, default is YES.
     *  For best results, toggle from `viewDidAppear:`
     */
    self.collectionView.collectionViewLayout.springinessEnabled = YES;
}



#pragma mark - Actions


#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                    sender:(NSString *)sender
                      date:(NSDate *)date
{
    /**
     *  Sending a message. Your implementation of this method should do *at least* the following:
     *
     *  1. Play sound (optional)
     *  2. Add new id<JSQMessageData> object to your data source
     *  3. Call `finishSendingMessage`
     */
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    JSQMessage *message = [[JSQMessage alloc] initWithText:text sender:sender date:date];
    [self.messages addObject:message];
    
    [self finishSendingMessage];
    
    /**
     * Guardar mensaje en Parse
     */
    PFObject *chatMessage = [PFObject objectWithClassName:@"ChatMessage"];
    chatMessage[@"message"] = text;
    chatMessage[@"chat"] = _chat;
    chatMessage[@"from"] = [PFUser currentUser];
    chatMessage[@"to"] = _chatUser;
    [chatMessage saveInBackground];
    
    /**
     * Mandar notificación a Parse
     */
    PFUser *currentUser = [PFUser currentUser];
    NSString *alert = currentUser[@"name"];
    alert = [alert stringByAppendingString:@" "];
    alert = [alert stringByAppendingString:currentUser[@"lastName"]];
    alert = [alert stringByAppendingString:@": "];
    alert = [alert stringByAppendingString:text];
    
    NSDictionary *data = @{@"alert": alert,
                           @"chat": _chat.objectId,
                           @"chatUser": [PFUser currentUser].objectId,
                           @"msg": text};
    PFPush *push = [[PFPush alloc] init];
    [push setChannel:_chatUser.objectId];
    [push setData:data];
    [push sendPushInBackground];
    
    /**
     * Poner chat activo
     */
    PFObject *user1 = _chat[@"user1"];
    if([_chatUser.objectId isEqualToString:user1.objectId]){
        if ([_chat[@"active2"] isEqual:@NO]) {
            _chat[@"active2"]=@YES;
            [_chat saveInBackground];
        }
    }
    else{
        if ([_chat[@"active1"] isEqual:@NO]) {
            _chat[@"active1"]=@YES;
            [_chat saveInBackground];
        }
    }

}

- (void)didPressAccessoryButton:(UIButton *)sender
{
    NSLog(@"Camera pressed!");
    /**
     *  Accessory button has no default functionality, yet.
     */
}



#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.messages objectAtIndex:indexPath.item];
}

- (UIImageView *)collectionView:(JSQMessagesCollectionView *)collectionView bubbleImageViewForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     */
    
    /**
     *  Reuse created bubble images, but create new imageView to add to each cell
     *  Otherwise, each cell would be referencing the same imageView and bubbles would disappear from cells
     */
    
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    if ([message.sender isEqualToString:self.sender]) {
        return [[UIImageView alloc] initWithImage:self.outgoingBubbleImageView.image
                                 highlightedImage:self.outgoingBubbleImageView.highlightedImage];
    }
    
    return [[UIImageView alloc] initWithImage:self.incomingBubbleImageView.image
                             highlightedImage:self.incomingBubbleImageView.highlightedImage];
}

- (UIImageView *)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageViewForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
    /**
     *  Return `nil` here if you do not want avatars.
     *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
     *
     *  It is possible to have only outgoing avatars or only incoming avatars, too.
     */
    
    /**
     *  Reuse created avatar images, but create new imageView to add to each cell
     *  Otherwise, each cell would be referencing the same imageView and avatars would disappear from cells
     *
     *  Note: these images will be sized according to these values:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
     *
     *  Override the defaults in `viewDidLoad`
     */
    
    
    //JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    //UIImage *avatarImage = [self.avatars objectForKey:message.sender];
    //return [[UIImageView alloc] initWithImage:avatarImage];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
    //JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    //if ([message.sender isEqualToString:self.sender]) {
    //    return nil;
    //}
    
    //if (indexPath.item - 1 > 0) {
    //    JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
    //    if ([[previousMessage sender] isEqualToString:message.sender]) {
    //        return nil;
    //    }
    //}
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    //return [[NSAttributedString alloc] initWithString:message.sender];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    JSQMessage *msg = [self.messages objectAtIndex:indexPath.item];
    
    if ([msg.sender isEqualToString:self.sender]) {
        cell.textView.textColor = [UIColor blackColor];
    }
    else {
        cell.textView.textColor = [UIColor whiteColor];
    }
    
    cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                          NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    
    return cell;
}



#pragma mark - JSQMessages collection view flow layout delegate

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    JSQMessage *currentMessage = [self.messages objectAtIndex:indexPath.item];
    if ([[currentMessage sender] isEqualToString:self.sender]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage sender] isEqualToString:[currentMessage sender]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"Load earlier messages!");
}

-(void)recieveMessage:(NSString *)message{
    /**
     *  This you should do upon receiving a message:
     *
     *  1. Play sound (optional)
     *  2. Add new id<JSQMessageData> object to your data source
     *  3. Call `finishReceivingMessage`
     */
    JSQMessage *recievedMessage = [[JSQMessage alloc] initWithText:message sender:self.sender date:[NSDate dateWithTimeIntervalSinceNow:0]];
    [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
    [self.messages addObject:recievedMessage];
    [self finishReceivingMessage];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.inputToolbar.contentView.textView resignFirstResponder];
}

-(void)setChat:(PFObject *)chat{
    _chat = chat;
    NSLog(@"Chat %@", chat.objectId);
    
}

-(void) setChatUser:(PFObject *)chatUser{
    _chatUser = chatUser;
    NSLog(@"Chat user %@", chatUser.objectId);
}
@end
