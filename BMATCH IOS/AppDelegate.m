//
//  AppDelegate.m
//  BMATCH IOS
//
//  Created by María Camila Angel on 30/05/14.
//  Copyright (c) 2014 María Camila Angel. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "ChatViewController.h"
#import "LoginViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //parse
    [Parse setApplicationId:@"9dP58JXjR2kZ4YYOtxqAg6wvTmQQjK4dHXwVZBAs"
                  clientKey:@"gxSDz7iOaxd7pZQHmSaTm8S0TLEms2qkLeduTeEO"];
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
     UIRemoteNotificationTypeAlert|
     UIRemoteNotificationTypeSound];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    //parse
    
    NSLog(@"\n\nDID FINISHH LAUNCHIIINGGGG!!!\n\n");
    
    // Extract the notification data
    NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];

    if (notificationPayload) {
        if ([PFUser currentUser]) {
            NSLog(@"\n\nDID FINISHH LAUNCHIIINGGGG2!!!\n\n");
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                     bundle: nil];
            ChatViewController *controller = (ChatViewController*)[mainStoryboard
                                                                   instantiateViewControllerWithIdentifier: @"chatVC"];
            NSString *chatId = [notificationPayload objectForKey:@"chat"];
            PFObject *chat = [PFObject objectWithoutDataWithClassName:@"Chat" objectId:chatId];
            [chat fetchIfNeeded];
            NSString *chatUserId = [notificationPayload objectForKey:@"chatUser"];
            PFQuery *query2 = [PFUser query];
            PFObject *chatUser = [query2 getObjectWithId:chatUserId];
            [chatUser fetchIfNeeded];
            [controller setChat:chat];
            [controller setChatUser:chatUser];
            application.applicationIconBadgeNumber = 0;
            UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
            controller.hidesBottomBarWhenPushed = YES;
            [navigationController pushViewController:controller animated:YES];
        }
    }
    
    return YES;    
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"\n\nDID RECIEVE ROMOTE NOTIF SIN HANDLER!!!\n\n");
    [PFPush handlePush:userInfo];
    
    if ([PFUser currentUser]) {
        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        
        NSString *chatId = [userInfo objectForKey:@"chat"];
        PFObject *chat = [PFObject objectWithoutDataWithClassName:@"Chat" objectId:chatId];
        [chat fetchIfNeeded];
        NSString *chatUserId = [userInfo objectForKey:@"chatUser"];
        PFQuery *query2 = [PFUser query];
        PFObject *chatUser = [query2 getObjectWithId:chatUserId];
        [chatUser fetchIfNeeded];
        
        if ([navigationController.visibleViewController isMemberOfClass:[ChatViewController class]]){
            NSLog(@"\n\nES UN CHAT!!!\n\n");
            ChatViewController *chatController = navigationController.visibleViewController;
            if ([chatController.chat.objectId isEqualToString:chat.objectId]){
                //Ya esta cargado el chat
                printf("\n\nES EL CHAT!!!\n\n");
                [chatController recieveMessage:[userInfo objectForKey:@"msg"] sender:chatUser[@"name"]];
            }
        }
        else{
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                     bundle: nil];
            ChatViewController *controller = (ChatViewController*)[mainStoryboard
                                                                   instantiateViewControllerWithIdentifier: @"chatVC"];
            [controller setChat:chat];
            [controller setChatUser:chatUser];
            application.applicationIconBadgeNumber = 0;
            controller.hidesBottomBarWhenPushed = YES;
            [navigationController pushViewController:controller animated:YES];
        }
    }
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))handler {
    NSLog(@"\n\nDID RECIEVE ROMOTE NOTIF!!!\n\n");
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
