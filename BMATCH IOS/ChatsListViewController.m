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
@property (strong, nonatomic) PFObject* selectedChatToMe;
@property (strong, nonatomic) PFObject* selectedChatFromMe;
@property (strong, nonatomic) PFObject* event;
@end

@implementation ChatsListViewController

- (void)loadChats {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Chat"];
    [query whereKey:@"event" equalTo:_event];
    [query whereKey:@"to" equalTo:[PFUser currentUser]];
    [query whereKey:@"active" equalTo:@YES];
    NSArray *chats = [query findObjects];
    
    [self.chats addObjectsFromArray: chats];
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
    
    PFUser *user = chatAtIndex[@"from"];;
    [user fetchIfNeeded];
    NSString *str = user[@"name"];
    str = [str stringByAppendingString:@" "];
    str = [str stringByAppendingString:user[@"lastName"]];
    cell.textLabel.text = str;
    
    PFQuery *queryChat = [PFQuery queryWithClassName:@"Chat"];
    [queryChat whereKey:@"from" equalTo:[PFUser currentUser]];
    [queryChat whereKey:@"to" equalTo:user];
    PFObject *chatAtIndex2 = [queryChat getFirstObject];
    
    PFQuery *query = [PFQuery queryWithClassName:@"ChatMessage"];
    NSArray *chats = [[NSArray alloc]initWithObjects:chatAtIndex, chatAtIndex2, nil];
    [query whereKey:@"chat" containedIn:chats];
    [query orderByDescending:@"createdAt"];
    PFObject *lastMessage = [query getFirstObject];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.detailTextLabel.text = lastMessage[@"message"];
    
    cell.imageView.layer.cornerRadius = [UIImage imageNamed:@"uknownUser"].size.height/2;
    cell.imageView.layer.masksToBounds = YES;
    cell.imageView.image = [UIImage imageNamed:@"uknownUser"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    _selectedChatToMe = [_chats objectAtIndex:indexPath.row];
    
    PFQuery *queryChat = [PFQuery queryWithClassName:@"Chat"];
    [queryChat whereKey:@"from" equalTo:[PFUser currentUser]];
    [queryChat whereKey:@"to" equalTo:_selectedChatToMe[@"from"]];
    _selectedChatFromMe = [queryChat getFirstObject];
    
    NSLog(@"\ntapped item: %@", _selectedChatToMe.objectId);
    [self performSegueWithIdentifier: @"goToChat" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepareForSegue: %@", segue.identifier);
    ChatViewController *destViewController = segue.destinationViewController;
    [destViewController setChatToMe:_selectedChatToMe];
    [destViewController setChatFromMe:_selectedChatFromMe];
    [destViewController setChatUser:_selectedChatToMe[@"from"]];
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
        _selectedChatToMe = [_chats objectAtIndex:indexPath.row];
        _selectedChatToMe[@"active"]=@NO;

        [_selectedChatToMe saveInBackground];
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
