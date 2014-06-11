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
    IBOutlet UITextField *textField;
    IBOutlet UINavigationItem *navigationHeader;

    NSMutableArray *bubbleData;
}

@property (strong, nonatomic) PFObject* chatToMe;
@property (strong, nonatomic) PFObject* chatFromMe;
@property (strong, nonatomic) PFObject* chatUser;

@end

@implementation ChatViewController

@synthesize chatToMe = _chatToMe;
@synthesize chatFromMe = _chatFromMe;
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
    [super viewDidLoad];
    
    // Configuración del titulo de la vista
    PFUser *chatUser = _chatToMe[@"from"];
    [chatUser fetchIfNeeded];
    NSString *nombreCompleto = chatUser[@"name"];
    nombreCompleto = [nombreCompleto stringByAppendingString:@" "];
    nombreCompleto = [nombreCompleto stringByAppendingString:chatUser[@"lastName"]];
    [navigationHeader setTitle:nombreCompleto];
    
    self.hidesBottomBarWhenPushed = YES;

    // Despliegue de mensajes del chat
    
    bubbleData = [[NSMutableArray alloc] init];
    PFQuery *query = [PFQuery queryWithClassName:@"ChatMessage"];
    [query whereKey:@"chat" equalTo:_chatToMe];
    NSArray *messages1 = [query findObjects];
    PFQuery *query2 = [PFQuery queryWithClassName:@"ChatMessage"];
    [query2 whereKey:@"chat" equalTo:_chatFromMe];
    NSArray *messages2 = [query2 findObjects];
    
    for (PFObject *message in messages1) {
        NSBubbleData *bubble;
        bubble = [NSBubbleData dataWithText:message[@"message"] date:[message createdAt] type:BubbleTypeSomeoneElse];
        [bubbleData addObject:bubble];
    }
    for (PFObject *message in messages2) {
        NSBubbleData *bubble;
        bubble = [NSBubbleData dataWithText:message[@"message"] date:[message createdAt] type:BubbleTypeMine];
        [bubbleData addObject:bubble];
    }
    bubbleTable.bubbleDataSource = self;
    
    // The line below sets the snap interval in seconds. This defines how the bubbles will be grouped in time.
    // Interval of 120 means that if the next messages comes in 2 minutes since the last message, it will be added into the same group.
    // Groups are delimited with header which contains date and time for the first message in the group.
    
    bubbleTable.snapInterval = 120;
    
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
        
        CGRect frame = textInputView.frame;
        frame.origin.y -= kbSize.height;
        textInputView.frame = frame;
        
        frame = bubbleTable.frame;
        frame.size.height -= kbSize.height;
        bubbleTable.frame = frame;
    }];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.2f animations:^{
        
        CGRect frame = textInputView.frame;
        frame.origin.y += kbSize.height;
        textInputView.frame = frame;
        
        frame = bubbleTable.frame;
        frame.size.height += kbSize.height;
        bubbleTable.frame = frame;
    }];
}

#pragma mark - Actions
- (IBAction)sendMessage:(id)sender {
    bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
    
    NSBubbleData *sayBubble = [NSBubbleData dataWithText:textField.text date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];
    PFObject *chatMessage = [PFObject objectWithClassName:@"ChatMessage"];
    chatMessage[@"message"] = textField.text;
    chatMessage[@"chat"] = _chatFromMe;
    [chatMessage saveInBackground];
    [bubbleData addObject:sayBubble];
    [bubbleTable reloadData];
    
    PFUser *currentUser = [PFUser currentUser];
    NSString *alert = currentUser[@"name"];
    alert = [alert stringByAppendingString:@" "];
    alert = [alert stringByAppendingString:currentUser[@"lastName"]];
    alert = [alert stringByAppendingString:@": "];
    alert = [alert stringByAppendingString:textField.text];

    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          alert, @"alert",
                          @"Increment", @"badge",
                          nil];
    PFPush *push = [[PFPush alloc] init];
    [push setChannel:_chatUser.objectId];
    [push setData:data];
    [push sendPushInBackground];
    
    textField.text = @"";
    [textField resignFirstResponder];
}

-(void)setChatToMe:(PFObject *)chat{
    _chatToMe = chat;
    NSLog(@"Chat to me %@", chat.objectId);
    
}

-(void)setChatFromMe:(PFObject *)chat{
    _chatFromMe = chat;
    NSLog(@"Chat from me %@", chat.objectId);
    
}
     
-(void) setChatUser:(PFObject *)chatUser{
    _chatUser = chatUser;
    NSLog(@"Chat user %@", chatUser.objectId);
}

@end
