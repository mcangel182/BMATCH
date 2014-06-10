//
//  ChatsListViewController.h
//  BMATCH IOS
//
//  Created by María Camila Angel on 7/06/14.
//  Copyright (c) 2014 María Camila Angel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ChatsListViewController : UITableViewController
    -(void)setEvent:(PFObject *)event;
    -(void)addChat:(PFObject *)chat;
@end
