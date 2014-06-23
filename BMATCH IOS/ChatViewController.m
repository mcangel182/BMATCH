//
//  ChatViewController.m
//  BMATCH IOS
//
//  Created by María Camila Angel on 3/06/14.
//  Copyright (c) 2014 María Camila Angel. All rights reserved.
//

#import "ChatViewController.h"
#import "UIBubbleTableView.h"
#import "UIBubbleTableViewDataSource.h"
#import "NSBubbleData.h"
#import <Parse/Parse.h>


@interface ChatViewController ()
{
    IBOutlet UIToolbar *toolbar;
    IBOutlet UIBubbleTableView *bubbleTable;
    IBOutlet UIView *textInputView;
    //IBOutlet UITextField *textField;
    IBOutlet UINavigationItem *navigationHeader;
    IBOutlet UITextView *textField;

    NSMutableArray *bubbleData;
}

@property (strong, nonatomic) PFObject* chatUser;

@end

@implementation ChatViewController

@synthesize chat = _chat;
@synthesize chatUser = _chatUser;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    printf("\n\n HIZOOO VIEW DID LOOOAAADD!!!\n\n");
    [super viewDidLoad];
    
    
    textField.delegate = self;
    textField.layer.borderWidth = 1.0f;
    textField.layer.cornerRadius = 5;
    textField.clipsToBounds = YES;
    textField.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    // Configuración del titulo de la vista
    [_chatUser fetchIfNeeded];
    NSString *nombreCompleto = _chatUser[@"name"];
    nombreCompleto = [nombreCompleto stringByAppendingString:@" "];
    nombreCompleto = [nombreCompleto stringByAppendingString:_chatUser[@"lastName"]];
    [navigationHeader setTitle:nombreCompleto];
    
    self.hidesBottomBarWhenPushed = YES;

    // Despliegue de mensajes del chat
    
    bubbleData = [[NSMutableArray alloc] init];
    PFQuery *query = [PFQuery queryWithClassName:@"ChatMessage"];
    [query whereKey:@"chat" equalTo:_chat];
    [query whereKey:@"from" equalTo:_chatUser];
    NSArray *messagesForMe = [query findObjects];
    PFQuery *query2 = [PFQuery queryWithClassName:@"ChatMessage"];
    [query2 whereKey:@"chat" equalTo:_chat];
    [query2 whereKey:@"to" equalTo:_chatUser];
    NSArray *messagesFromMe = [query2 findObjects];
    
    for (PFObject *message in messagesForMe) {
        NSBubbleData *bubble;
        bubble = [NSBubbleData dataWithText:message[@"message"] date:[message createdAt] type:BubbleTypeSomeoneElse];
        [bubbleData addObject:bubble];
    }
    for (PFObject *message in messagesFromMe) {
        NSBubbleData *bubble;
        bubble = [NSBubbleData dataWithText:message[@"message"] date:[message createdAt] type:BubbleTypeMine];
        [bubbleData addObject:bubble];
    }
    bubbleTable.bubbleDataSource = self;
    
    // The line below sets the snap interval in seconds. This defines how the bubbles will be grouped in time.
    // Interval of 120 means that if the next messages comes in 2 minutes since the last message, it will be added into the same group.
    // Groups are delimited with header which contains date and time for the first message in the group.
    
    bubbleTable.snapInterval = 86400;
    
    // The line below enables avatar support. Avatar can be specified for each bubble with .avatar property of NSBubbleData.
    // Avatars are enabled for the whole table at once. If particular NSBubbleData misses the avatar, a default placeholder will be set (missingAvatar.png)
    
    bubbleTable.showAvatars = NO;
    
    // Uncomment the line below to add "Now typing" bubble
    // Possible values are
    //    - NSBubbleTypingTypeSomebody - shows "now typing" bubble on the left
    //    - NSBubbleTypingTypeMe - shows "now typing" bubble on the right
    //    - NSBubbleTypingTypeNone - no "now typing" bubble
    
    bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
    
    [bubbleTable reloadData];
    
    // Keyboard events
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    
    [self scrollToLast];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - UIBubbleTableViewDataSource implementation

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    return [bubbleData count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    return [bubbleData objectAtIndex:row];
}

#pragma mark - Keyboard events

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.2f animations:^{
        
        CGRect frame = toolbar.frame;
        frame.origin.y -= kbSize.height;
        toolbar.frame = frame;
        
        frame = bubbleTable.frame;
        frame.origin.y -= kbSize.height;
        bubbleTable.frame = frame;
    }];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.2f animations:^{
        
        CGRect frame = toolbar.frame;
        frame.origin.y += kbSize.height;
        toolbar.frame = frame;
        
        frame = bubbleTable.frame;
        frame.origin.y += kbSize.height;
        bubbleTable.frame = frame;
    }];
}

#pragma mark - Actions
- (IBAction)sendMessage:(id)sender {
    bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
    
    NSBubbleData *sayBubble = [NSBubbleData dataWithText:textField.text date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];
    PFObject *chatMessage = [PFObject objectWithClassName:@"ChatMessage"];
    chatMessage[@"message"] = textField.text;
    chatMessage[@"chat"] = _chat;
    chatMessage[@"from"] = [PFUser currentUser];
    chatMessage[@"to"] = _chatUser;
    [chatMessage saveInBackground];
    [bubbleData addObject:sayBubble];
    [bubbleTable reloadData];
    
    PFUser *currentUser = [PFUser currentUser];
    NSString *alert = currentUser[@"name"];
    alert = [alert stringByAppendingString:@" "];
    alert = [alert stringByAppendingString:currentUser[@"lastName"]];
    alert = [alert stringByAppendingString:@": "];
    alert = [alert stringByAppendingString:textField.text];

    NSDictionary *data = @{@"alert": alert,
                           @"chat": _chat.objectId,
                           @"chatUser": [PFUser currentUser].objectId,
                           @"msg": textField.text};
    PFPush *push = [[PFPush alloc] init];
    [push setChannel:_chatUser.objectId];
    [push setData:data];
    [push sendPushInBackground];
    
    textField.text = @"";
    [self adjustTextView];
    [textField resignFirstResponder];
    
    //pongo chat activo
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
    
    [self scrollToLast];
}

-(void)setChat:(PFObject *)chat{
    _chat = chat;
    NSLog(@"Chat %@", chat.objectId);
    
}

-(void) setChatUser:(PFObject *)chatUser{
    _chatUser = chatUser;
    NSLog(@"Chat user %@", chatUser.objectId);
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    CGRect textFrame = textView.frame;
    CGSize size = [textView sizeThatFits:CGSizeMake(textFrame.size.width, 70)];
    NSInteger heightDif = size.height-textFrame.size.height;
    if (heightDif!=0){
        printf("hay diferencia");
        
        //Subir o bajar el toolbar
        CGRect frame = toolbar.frame;
        frame.origin.y -= heightDif;
        //frame.size.height += heightDif;
        toolbar.frame = frame;
        
        textFrame.size.height += heightDif;
        //textFrame.origin.y -= heightDif;
        textView.frame = textFrame;
    }
    return YES;
}

-(void)recieveMessage:(NSString *)message{
    NSBubbleData *sayBubble = [NSBubbleData dataWithText:message date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeSomeoneElse];
    [bubbleData addObject:sayBubble];
    [bubbleTable reloadData];
    [self scrollToLast];
}

-(void)scrollToLast{
    NSInteger sections = [bubbleTable.dataSource numberOfSectionsInTableView:bubbleTable];
    NSInteger rowsInSection = [bubbleTable.dataSource tableView:bubbleTable numberOfRowsInSection:sections-1];
    if (sections>0 && rowsInSection>0){
        NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:(rowsInSection - 1) inSection:sections-1];
        [bubbleTable scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

-(void)adjustTextView{
    CGRect textFrame = textField.frame;
    CGSize size = [textField sizeThatFits:CGSizeMake(textFrame.size.width, 70)];
    NSInteger heightDif = size.height-textFrame.size.height;
    if (heightDif!=0){
        printf("hay diferencia");
        
        //Subir o bajar el toolbar
        CGRect frame = toolbar.frame;
        frame.origin.y -= heightDif;
        //frame.size.height += heightDif;
        toolbar.frame = frame;
        
        textFrame.size.height += heightDif;
        //textFrame.origin.y -= heightDif;
        textField.frame = textFrame;
    }
}

@end
