//
//  SettingsViewController.m
//  FourPicsOneWord
//
//  Created by  on 10/16/13.
//  Copyright (c) 2013 Vojtec. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void) viewDidLoad{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
   self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"background.png"]];


//   [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastAnsweredBonus"];
//   [[NSUserDefaults standardUserDefaults] synchronize];
//}
//_numberOfAnswered = ((NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:@"numAnsweredLevels"]).intValue;


//   [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"freeHintsNotif"];
//   [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"bonusChallNotif"];
//   [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"sounds"];

   //free hints notif
   UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 85, 200, 20)];
   label.backgroundColor = [UIColor clearColor];
   label.textColor = [UIColor whiteColor];
   label.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
   [self.view addSubview:label];
   label.text = NSLocalizedString(@"hintsPush", nil);

   UISwitch *theSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(220, 80, 30, 20)];
   theSwitch.onTintColor = [UIColor lightGrayColor];
   [theSwitch addTarget:self action:@selector(toggleHints:) forControlEvents:UIControlEventValueChanged];
   theSwitch.on = ((NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:@"freeHintsNotif"]).boolValue;
   [self.view addSubview:theSwitch];

   //bonus notif
   label = [[UILabel alloc] initWithFrame:CGRectMake(20, 125, 200, 20)];
   label.backgroundColor = [UIColor clearColor];
   label.textColor = [UIColor whiteColor];
   label.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
   [self.view addSubview:label];
   label.text = NSLocalizedString(@"bonusPush", nil);

   theSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(220, 120, 30, 20)];
   theSwitch.onTintColor = [UIColor lightGrayColor];
   [theSwitch addTarget:self action:@selector(toggleBonus:) forControlEvents:UIControlEventValueChanged];
   theSwitch.on = ((NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:@"bonusChallNotif"]).boolValue;
   [self.view addSubview:theSwitch];

   //sounds
   label = [[UILabel alloc] initWithFrame:CGRectMake(20, 165, 200, 20)];
   label.backgroundColor = [UIColor clearColor];
   label.textColor = [UIColor whiteColor];
   label.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
   [self.view addSubview:label];
   label.text = NSLocalizedString(@"sounds", nil);

   theSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(220, 160, 30, 20)];
   theSwitch.onTintColor = [UIColor lightGrayColor];
   [theSwitch addTarget:self action:@selector(toggleSounds:) forControlEvents:UIControlEventValueChanged];
   theSwitch.on = ((NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:@"sounds"]).boolValue;
   [self.view addSubview:theSwitch];
}
-(void) didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) toggleHints:(UISwitch*)sender{
   [[NSUserDefaults standardUserDefaults] setObject:@(sender.on) forKey:@"freeHintsNotif"];
   [[NSUserDefaults standardUserDefaults] synchronize];
}
-(void) toggleBonus:(UISwitch*)sender{
   [[NSUserDefaults standardUserDefaults] setObject:@(sender.on) forKey:@"bonusChallNotif"];
   [[NSUserDefaults standardUserDefaults] synchronize];
}
-(void) toggleSounds:(UISwitch*)sender{
   [[NSUserDefaults standardUserDefaults] setObject:@(sender.on) forKey:@"sounds"];
   [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
