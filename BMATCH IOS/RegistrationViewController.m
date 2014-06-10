//
//  RegistrationViewController.m
//  BMATCH IOS
//
//  Created by María Camila Angel on 6/06/14.
//  Copyright (c) 2014 María Camila Angel. All rights reserved.
//

#import "RegistrationViewController.h"
#import "EventsViewController.h"

@interface RegistrationViewController ()
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *lastName;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *passwordConfirmation;
@property (weak, nonatomic) IBOutlet UITextField *career;
@property (weak, nonatomic) IBOutlet UITextField *company;

@end

@implementation RegistrationViewController

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepareForSegue: %@", segue.identifier);
    
    if([segue.identifier isEqualToString:@"goToHome"]){
        UITabBarController *destViewController = segue.destinationViewController;
        [destViewController setSelectedIndex:1];
    }
}

- (IBAction)registerNewUser:(id)sender {
    
    if([_password.text isEqualToString:_passwordConfirmation.text]){
        PFUser *user = [PFUser user];
        user.username = _email.text;
        user.password = _password.text;
        user.email = _email.text;
        
        // other fields can be set just like with PFObject
        user[@"name"] = _name.text;
        user[@"lastName"] = _lastName.text;
        user[@"career"] = _career.text;
        user[@"company"] = _company.text;

        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                // Hooray! Let them use the app now.
                [PFUser logInWithUsernameInBackground:_email.text password:_password.text
                                                block:^(PFUser *user, NSError *error) {
                                                    if (user) {
                                                        // Do stuff after successful login.
                                                        [self performSegueWithIdentifier: @"goToHome" sender:sender];

                                                    } else {
                                                        // The login failed. Check error to see why.
                                                    }
                                                }];
            } else {
                NSString *errorString = [error userInfo][@"error"];
                // Show the errorString somewhere and let the user try again.
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alerta!"
                                                    message:errorString
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
                [alert show];
            }
        }];
        
        
    }
    else{
        // La clave y el confirm no son iguales
        _password.layer.borderColor = [[UIColor redColor]CGColor];
        _password.layer.borderWidth = 2.0F;
        _password.layer.cornerRadius = 4.0F;
        
        _passwordConfirmation.layer.borderColor = [[UIColor redColor]CGColor];
        _passwordConfirmation.layer.borderWidth = 2.0F;
        _passwordConfirmation.layer.cornerRadius = 4.0F;
        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alerta!"
//                                                        message:@"Login o clave están mal"
//                                                       delegate:nil
//                                              cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil];
//        [alert show];

    }
    
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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.name resignFirstResponder];
    [self.lastName resignFirstResponder];
    [self.email resignFirstResponder];
    [self.password resignFirstResponder];
    [self.passwordConfirmation resignFirstResponder];
    [self.company resignFirstResponder];
    [self.career resignFirstResponder];

}

@end
