//
//  ProfileViewController.m
//  BMATCH IOS
//
//  Created by María Camila Angel on 7/06/14.
//  Copyright (c) 2014 María Camila Angel. All rights reserved.
//

#import "ProfileViewController.h"
#import <Parse/Parse.h>

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *lastName;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *career;
@property (weak, nonatomic) IBOutlet UITextField *company;

@end

@implementation ProfileViewController

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
    PFUser *user = [PFUser currentUser];
    _name.text = user[@"name"];
    _lastName.text = user[@"lastName"];
    _email.text = user[@"email"];
    _career.text = user[@"career"];
    _company.text = user[@"company"];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)updateUser:(id)sender {
    PFUser *user = [PFUser currentUser];
    user[@"name"] = _name.text ;
    user[@"lastName"] = _lastName.text;
    user[@"email"] = _email.text;
    user[@"career"] = _career.text;
    user[@"company"] = _company.text;
    [user saveInBackground];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_name resignFirstResponder];
    [_lastName resignFirstResponder];
    [_email resignFirstResponder];
    [_career resignFirstResponder];
    [_company resignFirstResponder];
}
@end
