//
//  LoginViewController.m
//  BMATCH IOS
//
//  Created by María Camila Angel on 2/06/14.
//  Copyright (c) 2014 María Camila Angel. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@end

@implementation LoginViewController

@synthesize username = _username;
@synthesize password = _password;

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepareForSegue: %@", segue.identifier);
    
    if([segue.identifier isEqualToString:@"goToHome"]){
        UITabBarController *destViewController = segue.destinationViewController;
        [destViewController setSelectedIndex:1];
    }
}

- (IBAction)registration:(id)sender {
    [self performSegueWithIdentifier: @"goToRegistration" sender:sender];
}
- (IBAction)login:(id)sender {
    
    //con log in de parse
    [PFUser logInWithUsernameInBackground:_username.text password:_password.text
                                    block:^(PFUser *user, NSError *error) {
                                        if (user) {
                                            [self performSegueWithIdentifier: @"goToHome" sender:sender];
                                        } else {
                                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alerta!"
                                                                                            message:@"Login o clave están mal"
                                                                                           delegate:nil
                                                                                  cancelButtonTitle:@"OK"
                                                                                  otherButtonTitles:nil];
                                            [alert show];
                                        }
                                    }];
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation removeObjectForKey:@"channels"];
    [currentInstallation addUniqueObject:[PFUser currentUser].objectId forKey:@"channels"];
    [currentInstallation saveInBackground];
}

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

    
    //PFObject *testObject = [PFObject objectWithClassName:@"TestObject"];
    //testObject[@"foo"] = @"bar";
    //[testObject saveInBackground];
	// Do any additional setup after loading the view.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.username resignFirstResponder];
    [self.password resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
