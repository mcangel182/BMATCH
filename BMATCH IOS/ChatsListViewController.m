//
//  ChatsListViewController.m
//  BMATCH IOS
//
//  Created by María Camila Angel on 7/06/14.
//  Copyright (c) 2014 María Camila Angel. All rights reserved.
//

#import "ChatsListViewController.h"
#import <Parse/Parse.h>
#import "ChatViewController.h"

@interface ChatsListViewController ()
@property NSMutableArray *chats;
@property (strong, nonatomic) PFObject* selectedChat;
@property (strong, nonatomic) PFObject* selectedChatUser;
@property (strong, nonatomic) PFObject* event;
@end

@implementation ChatsListViewController

@synthesize selectedChat = _selectedChat;
@synthesize selectedChatUser = _selectedChatUser;
@synthesize event = _event;

- (void)loadChats {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Chat"];
    [query whereKey:@"event" equalTo:_event];
    [query whereKey:@"user1" equalTo:[PFUser currentUser]];
    [query whereKey:@"active1" equalTo:@YES];
    NSArray *chats1 = [query findObjects];
    
    PFQuery *query2 = [PFQuery queryWithClassName:@"Chat"];
    [query2 whereKey:@"event" equalTo:_event];
    [query2 whereKey:@"user2" equalTo:[PFUser currentUser]];
    [query2 whereKey:@"active2" equalTo:@YES];
    NSArray *chats2 = [query2 findObjects];
    
    [self.chats addObjectsFromArray: chats1];
    [self.chats addObjectsFromArray: chats2];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _chats = [[NSMutableArray alloc] init];
    [self loadChats];
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _chats.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ListPrototypeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    PFObject *chatAtIndex = [self.chats objectAtIndex:indexPath.row];
    PFUser *user;
    PFUser *user1 = chatAtIndex[@"user1"];
    if([[PFUser currentUser].objectId isEqualToString:user1.objectId]){
        user = chatAtIndex[@"user2"];
    }
    else{
        user = user1;
    }
    
    [user fetchIfNeeded];
    NSString *str = user[@"name"];
    str = [str stringByAppendingString:@" "];
    str = [str stringByAppendingString:user[@"lastName"]];
    cell.textLabel.text = str;
    
    PFQuery *query = [PFQuery queryWithClassName:@"ChatMessage"];
    [query whereKey:@"chat" equalTo:chatAtIndex];
    [query orderByDescending:@"createdAt"];
    PFObject *lastMessage = [query getFirstObject];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.detailTextLabel.text = lastMessage[@"message"];
    
    cell.imageView.layer.cornerRadius = [UIImage imageNamed:@"uknownUser"].size.height/2;
    cell.imageView.layer.masksToBounds = YES;
    cell.imageView.layer.borderColor = [[UIColor colorWithRed:(202/255.0) green:(202/255.0) blue:(202/255.0) alpha:1.0] CGColor];
    cell.imageView.layer.borderWidth = 1.0f;
    cell.imageView.image = [UIImage imageNamed:@"uknownUser"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    _selectedChat = [_chats objectAtIndex:indexPath.row];
    PFUser *user1 = _selectedChat[@"user1"];
    if([[PFUser currentUser].objectId isEqualToString:user1.objectId]){
        _selectedChatUser = _selectedChat[@"user2"];
    }
    else{
        _selectedChatUser = user1;
    }
    NSLog(@"\ntapped item: %@", _selectedChat.objectId);
    [self performSegueWithIdentifier: @"goToChat" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepareForSegue: %@", segue.identifier);
    ChatViewController *destViewController = segue.destinationViewController;
    [destViewController setChat:_selectedChat];
    [destViewController setChatUser:_selectedChatUser];
}

// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        _selectedChat = [_chats objectAtIndex:indexPath.row];
        PFUser *user1 = _selectedChat[@"user1"];
        if([[PFUser currentUser].objectId isEqualToString:user1.objectId]){
            _selectedChat[@"active1"]=@NO;
        }
        else{
            _selectedChat[@"active2"]=@NO;
        }
        [_selectedChat saveInBackground];
        [_chats removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
    }
}

-(void)setEvent:(PFObject *)event{
    _event = event;
    NSLog(@"Event: %@", event.objectId);
}

-(void)addChat:(PFObject *)chat{
    [_chats addObject:chat];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.navigationController.navigationBar setTranslucent:NO];
}

-(void) viewDidAppear:(BOOL)animated{
    [self.navigationController.navigationBar setTranslucent:NO];
    printf("\n\n view did appear \n\n");
    _chats = [[NSMutableArray alloc] init];
    [self loadChats];
    [self.tableView reloadData];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
