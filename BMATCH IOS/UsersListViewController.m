//
//  UsersListViewController.m
//  BMATCH IOS
//
//  Created by María Camila Angel on 2/06/14.
//  Copyright (c) 2014 María Camila Angel. All rights reserved.
//

#import "UsersListViewController.h"
#import "ChatViewController.h"
#import "ChatsListViewController.h"

@interface UsersListViewController ()
@property NSMutableArray *users;
@property NSArray *searchResults;
@property (strong, nonatomic) PFObject* selectedChat;
@property (strong, nonatomic) PFObject* selectedChatUser;
@property (strong, nonatomic) PFObject* event;

@end

@implementation UsersListViewController

@synthesize selectedChat = _selectedChat;
@synthesize selectedChatUser = _selectedChatUser;
@synthesize event = _event;

- (void)loadEventUsers {
    
    PFQuery *query = [PFQuery queryWithClassName:@"EventUser"];
    [query whereKey:@"event" equalTo:_event];
    [query whereKey:@"user" notEqualTo:[PFUser currentUser]];
    NSArray *usuarios = [query findObjects];
    NSLog(@"cargo %d",usuarios.count);
    [self.users addObjectsFromArray: usuarios];
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
    _users = [[NSMutableArray alloc] init];
    _searchResults = [[NSArray alloc] init];
    [self loadEventUsers];
    
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
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [_searchResults count];
        
    } else {
        return [_users count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ListPrototypeCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    PFObject *user;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        user = [_searchResults objectAtIndex:indexPath.row][@"user"];
    } else {
        user= [_users objectAtIndex:indexPath.row][@"user"];
    }
    
    [user fetchIfNeeded];
    NSString *str = user[@"name"];
    str = [str stringByAppendingString:@" "];
    str = [str stringByAppendingString:user[@"lastName"]];
    cell.textLabel.text = str;
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.detailTextLabel.text = user[@"career"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    PFObject *selectedEventUser = [self.users objectAtIndex:indexPath.row];
    _selectedChatUser = selectedEventUser[@"user"];
    NSLog(@"\ntapped item: %@", _selectedChatUser.objectId);
    
    NSArray *users = [[NSArray alloc] initWithObjects:[PFUser currentUser],_selectedChatUser, nil];
    
    PFQuery *queryChat = [PFQuery queryWithClassName:@"Chat"];
    [queryChat whereKey:@"user1" containedIn:users];
    [queryChat whereKey:@"user2" containedIn:users];
    _selectedChat = [queryChat getFirstObject];
    
    if (!_selectedChat) {
        //si el chat no ha sido inicializado por alguno de los dos usuarios se crea
        PFObject *chat = [PFObject objectWithClassName:@"Chat"];
        chat[@"user1"] = [PFUser currentUser];
        chat[@"user2"] = _selectedChatUser;
        chat[@"event"] = _event;
        chat[@"active1"] = @NO;
        chat[@"active2"] = @NO;
        [chat saveInBackground];
        _selectedChat = chat;
    }
    
    [self performSegueWithIdentifier: @"goToChat" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepareForSegue: %@", segue.identifier);
    ChatViewController *destViewController = segue.destinationViewController;
    [destViewController setChat:_selectedChat];
    [destViewController setChatUser:_selectedChatUser];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"objectId contains[c] %@", searchText];
    _searchResults = [_users filteredArrayUsingPredicate:resultPredicate];
}

-(void)setEvent:(PFObject *)event{
    _event = event;
    NSLog(@"Event: %@", event.objectId);
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.navigationController.navigationBar setTranslucent:NO];
}

-(void) viewDidAppear:(BOOL)animated{
    [self.navigationController.navigationBar setTranslucent:NO];
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
