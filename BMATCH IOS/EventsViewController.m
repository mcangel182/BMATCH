//
//  EventsViewController.m
//  BMATCH IOS
//
//  Created by María Camila Angel on 2/06/14.
//  Copyright (c) 2014 María Camila Angel. All rights reserved.
//

#import "EventsViewController.h"
#import "UsersListViewController.h"
#import "ChatsListViewController.h"
#import <Parse/Parse.h>

@interface EventsViewController ()

@property (weak, nonatomic) IBOutlet UIView *viewPreview;
@property (weak, nonatomic) IBOutlet UIButton *buttonScanQR;
@property (weak, nonatomic) IBOutlet UILabel *labelScanQR;
@property (nonatomic) BOOL isReading;

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

-(BOOL)startReading;
-(void)stopReading;

@property (weak, nonatomic) IBOutlet UITextField *eventId;
@property (strong, nonatomic) PFObject* selectedEvent;
@end

@implementation EventsViewController
@synthesize selectedEvent = _selectedEvent;

- (IBAction)startStopReading:(id)sender {
    if (!_isReading) {
        if ([self startReading]) {
            [_buttonScanQR setTitle:@"" forState:UIControlStateNormal];
            [_labelScanQR setText:@""];
        }
    }
    else{
        [self stopReading];
        [_buttonScanQR setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
        [_labelScanQR setText:@"Escanee el código"];
    }
    _isReading = !_isReading;
}
- (BOOL)startReading {
    NSError *error;
    
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input) {
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    
    _captureSession = [[AVCaptureSession alloc] init];
    [_captureSession addInput:input];
    
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [_captureSession addOutput:captureMetadataOutput];
    
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_videoPreviewLayer setFrame:_viewPreview.layer.bounds];
    [_viewPreview.layer addSublayer:_videoPreviewLayer];
    
    [_captureSession startRunning];
    
    return YES;
}

-(void)stopReading{
    [_captureSession stopRunning];
    _captureSession = nil;
    
    [_videoPreviewLayer removeFromSuperlayer];
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            [_eventId performSelectorOnMainThread:@selector(setText:) withObject:[metadataObj stringValue] waitUntilDone:NO];
            
            [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
            //[_buttonScanQR performSelectorOnMainThread:@selector(setTitle:) withObject:@"Start!" waitUntilDone:NO];
            _isReading = NO;
        }
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepareForSegue: %@", segue.identifier);
    UITabBarController *destViewController = segue.destinationViewController;
    
    //Creo eventUser
    PFObject *eventUser = [PFObject objectWithClassName:@"EventUser"];
    eventUser[@"user"] = [PFUser currentUser];
    eventUser[@"event"] = _selectedEvent;
    [eventUser saveInBackground];
    
    UsersListViewController *controller = destViewController.childViewControllers[0];
    ChatsListViewController *controller2 = destViewController.childViewControllers[1];
    [controller setEvent:_selectedEvent];
    [controller2 setEvent:_selectedEvent];
}

- (IBAction)registerInEvent:(id)sender {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    _selectedEvent = [query getObjectWithId: _eventId.text];
    
    PFQuery *query2 = [PFQuery queryWithClassName:@"EventUser"];
    [query2 whereKey:@"event" equalTo:_selectedEvent];
    [query2 whereKey:@"user" equalTo:[PFUser currentUser]];
    PFObject *eventoExistente = [query2 getFirstObject];
    
    if (eventoExistente){
        // Ya se encuentra registrado en el evento revise el historial de eventos
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alerta!"
                                                        message:@"Ya se encuentra registrado en este evento. Revise el historial"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else{
        [self performSegueWithIdentifier: @"goToUserList" sender:sender];
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
    //_viewPreview.layer.borderColor = CFBridgingRetain([UIColor grayColor]);
    //_viewPreview.layer.borderWidth = 2.0f;
    _isReading = NO;
    _captureSession = nil;
    _eventId.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//Teclado

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    [self registerInEvent:self];
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

-(void)keyboardWillShow {
    // Animate the current view out of the way
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}

-(void)keyboardWillHide {
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}



//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= 80.0;
        rect.size.height += 80.0;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += 80.0;
        rect.size.height -= 80.0;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_eventId resignFirstResponder];
}


//Temporal- hay que borrar

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    [self adjustFrames];
    return YES;
}
-(void) adjustFrames
{
    UITextView *calculationView = [[UITextView alloc] init];
    [calculationView setText:_eventId.text];
    CGSize size = [calculationView sizeThatFits:CGSizeMake(_eventId.frame.size.width, FLT_MAX)];
    
    CGRect textFrame = _eventId.frame;
    textFrame.size.height = size.height;
    _eventId.frame = textFrame;
}

@end
