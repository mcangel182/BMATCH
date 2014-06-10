//
//  EventListViewController.m
//  BMATCH IOS
//
//  Created by María Camila Angel on 6/06/14.
//  Copyright (c) 2014 María Camila Angel. All rights reserved.
//

#import "EventListViewController.h"
#import <Parse/Parse.h>
#import "UsersListViewController.h"
#import "ChatsListViewController.h"

@interface EventListViewController ()
@property NSMutableArray *events;
@property (strong, nonatomic) PFObject* selectedEvent;

@end

@implementation EventListViewController
@synthesize events = _events;
@synthesize selectedEvent = _selectedEvent;

- (void)loadEvents {

    PFQuery *query = [PFQuery queryWithClassName:@"EventUser"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    NSArray *events = [query findObjects];
    [_events addObjectsFromArray: events];
    NSLog(@"eventos cargados %d", _events.count);
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
    NSLog(@"Hizo view did load");
    [super viewDidLoad];
    _events = [[NSMutableArray alloc] init];
    [self loadEvents];

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
    return _events.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ListPrototypeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...

    PFObject *evento = [_events objectAtIndex:indexPath.row];
    PFObject *event = evento[@"event"];
    [event fetchIfNeeded];
    NSLog(@"carg la celda con evento %@", event[@"name"]);
    cell.textLabel.text = event[@"name"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    PFObject *selectedEventUser = [_events objectAtIndex:indexPath.row];
    _selectedEvent = selectedEventUser[@"event"];
    NSLog(@"\ntapped item: %@", _selectedEvent.objectId);
    
    [self performSegueWithIdentifier: @"goToUserList" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepareForSegue: %@", segue.identifier);
    UITabBarController *destViewController = segue.destinationViewController;
    UsersListViewController *controller = destViewController.childViewControllers[0];
     ChatsListViewController *controller2 = destViewController.childViewControllers[1];
    [controller setEvent:_selectedEvent];
    [controller2 setEvent:_selectedEvent];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.navigationController.navigationBar setTranslucent:YES];
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
