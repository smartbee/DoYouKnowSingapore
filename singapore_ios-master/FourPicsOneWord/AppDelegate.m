//
//  AppDelegate.m
//  FourPicsOneWord
//
//  Created by  on 10/14/13.
//  Copyright (c) 2013 Vojtec. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "Chartboost.h"
#import "ImagesModel.h"
#import <RevMobAds/RevMobAds.h>
#import <AdColony/AdColony.h>

@interface AppDelegate () <UIAlertViewDelegate, AdColonyDelegate, ChartboostDelegate>{
   NSTimer *rateTimer;
}
@end

@implementation AppDelegate

#pragma mark - Application Function
-(BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
   srand(((NSDate*)[NSDate date]).timeIntervalSinceReferenceDate);

   if (![[NSUserDefaults standardUserDefaults] objectForKey:@"freeHintsNotif"]) {
      [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"freeHintsNotif"];
      [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"bonusChallNotif"];
      [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"sounds"];
      [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"rate"];
      [[NSUserDefaults standardUserDefaults] synchronize];
   }


//   [[UIButton appearance] setContentMode:UIViewContentModeScaleAspectFit];
//   [[UILabel appearance] setTextAlignment:NSTextAlignmentCenter];

//   [RevMobAds startSessionWithAppID:@"copy your RevMob App ID here"];
   [RevMobAds startSessionWithAppID:[[NSBundle mainBundle] infoDictionary][@"RevMobID"]];

   [AdColony configureWithAppID:[[NSBundle mainBundle] infoDictionary][@"AdColonyAppID"]
                        zoneIDs:@[[[NSBundle mainBundle] infoDictionary][@"AdColonyZoneID"]]
                       delegate:self
                        logging:YES];


   [UIApplication sharedApplication].statusBarHidden = YES;
   HomeViewController *vc = [[HomeViewController alloc] init];
   UINavigationController *navVc = [[UINavigationController alloc] initWithRootViewController:vc];
    [navVc setNavigationBarHidden:YES];
   self.window.rootViewController = navVc;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}
-(void) applicationWillResignActive:(UIApplication *)application{
   // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
   // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}
-(void) applicationDidEnterBackground:(UIApplication *)application{
   // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
   // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

   if (rateTimer) {
      [rateTimer invalidate];
      rateTimer = nil;
   }

   [[UIApplication sharedApplication] cancelAllLocalNotifications];

   UILocalNotification *notification;
   if (((NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:@"bonusChallNotif"]).boolValue) {
      if ([ImagesModel sharedModel].numberOfBonusAnswered < [ImagesModel sharedModel].numberOfAllBonuses) {
         if (kBonusTime - [[NSDate date] timeIntervalSinceDate:[ImagesModel sharedModel].lastAnsweredBonusDate] > 0) {
            notification = [[UILocalNotification alloc] init];
            notification.fireDate = [[ImagesModel sharedModel].lastAnsweredBonusDate dateByAddingTimeInterval:kBonusTime];
            notification.alertBody = @"The bonus challenge is now available! Get extra coins now!";
            notification.soundName = UILocalNotificationDefaultSoundName;
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
         }
      }
   }


   if (((NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:@"freeHintsNotif"]).boolValue) {
      notification = [[UILocalNotification alloc] init];
      notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:60*60*24*1];
      NSString *word = [[ImagesModel sharedModel] picsAndWordForID:[[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex] inPackage:[ImagesModel sharedModel].currentPackageIndex].word;
//      NSString *word = [[ImagesModel sharedModel] picsAndWordForID:[ImagesModel sharedModel].currentWordIndex].word;
      NSMutableString *msg = [NSMutableString stringWithString:@"The first letter of the word is: "];
      [msg appendString:((NSString*)[NSString stringWithFormat:@"%c", [word characterAtIndex:0]]).uppercaseString];
      for (int i = 1; i < word.length; i++) {
         [msg appendString:@" _"];
      }
      [msg appendString:@" :)"];
      notification.alertBody = msg;
      notification.soundName = UILocalNotificationDefaultSoundName;
      [[UIApplication sharedApplication] scheduleLocalNotification:notification];
   }

}
-(void) applicationWillEnterForeground:(UIApplication *)application{
   // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}
-(void) applicationDidBecomeActive:(UIApplication *)application{
   // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
   
   Chartboost *cb = [Chartboost sharedChartboost];
//   cb.appId = @"YOUR_CHARTBOOST_APP_ID";
//   cb.appSignature = @"YOUR_CHARTBOOST_APP_SIGNATURE";
   cb.appId = [[NSBundle mainBundle] infoDictionary][@"ChartboostAppID"];
   cb.appSignature = [[NSBundle mainBundle] infoDictionary][@"ChartboostAppSignature"];

   cb.delegate = self;

   [cb startSession];
   [cb cacheMoreApps];
//   [cb showMoreApps];
//   [cb showInterstitial];

   //[[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"rate"];
   if (((NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:@"rate"]).boolValue) {
      rateTimer = [NSTimer scheduledTimerWithTimeInterval:60*4 target:self selector:@selector(showRate) userInfo:nil repeats:NO];
   }

   [[RevMobAds session] showFullscreen];
}
-(void) applicationWillTerminate:(UIApplication *)application{
   // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Other Fucntion
-(void) onAdColonyV4VCReward:(BOOL)success currencyName:(NSString*)currencyName currencyAmount:(int)amount inZone:(NSString*)zoneID{
    if (success) {
        [[ImagesModel sharedModel] winWatchVideoReward:amount];
    }
}
-(void) showRate{
   [rateTimer invalidate];
   rateTimer = nil;

   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Rate this app" message:@"If you enjoy this app, would you mind taking a moment to rate it?" delegate:self cancelButtonTitle:@"No, Thanks" otherButtonTitles:@"Rate", @"Remind me later", nil];
   [alert show];
}
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
   if (buttonIndex == 1) {
      NSString *reviewURL = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", [[NSBundle mainBundle] infoDictionary][@"iTunesAppID"]];
      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:reviewURL]];
      [[NSUserDefaults standardUserDefaults] setObject:@(NO) forKey:@"rate"];
      [[NSUserDefaults standardUserDefaults] synchronize];
   } else if (buttonIndex == 2) {
//      rateTimer = [NSTimer scheduledTimerWithTimeInterval:60*4 target:self selector:@selector(showRate) userInfo:nil repeats:NO];
   } else {
      [[NSUserDefaults standardUserDefaults] setObject:@(NO) forKey:@"rate"];
      [[NSUserDefaults standardUserDefaults] synchronize];
   }
}

@end
