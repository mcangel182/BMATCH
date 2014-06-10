//
//  ChatViewController.h
//  BMATCH IOS
//
//  Created by María Camila Angel on 3/06/14.
//  Copyright (c) 2014 María Camila Angel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIBubbleTableViewDataSource.h"
#import <Parse/Parse.h>

@interface ChatViewController : UIViewController <UIBubbleTableViewDataSource>
    -(void)setChatToMe:(PFObject *)chat;
    -(void)setChatFromMe:(PFObject *)chat;
@end
