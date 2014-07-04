//
//  GetPremiumViewController.m
//  FourPicsOneWord
//
//  Created by  on 10/16/13.
//  Copyright (c) 2013 Vojtec. All rights reserved.
//

#import "GetPremiumViewController.h"
#import <StoreKit/StoreKit.h>

@interface GetPremiumViewController () <SKProductsRequestDelegate>

@end

@implementation GetPremiumViewController

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
       self.title = NSLocalizedString(@"UpgradePremium", nil);
    }
    return self;
}
-(void) viewDidLoad{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
   self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"background.png"]];

   UIImageView *topbar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 45)];
   topbar.image = [UIImage imageNamed:@"topbar.png"];
   [self.view addSubview:topbar];

   UIImageView *premiumImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 45, 320, 320)];
   premiumImage.image = [UIImage imageNamed:@"premium.png"];
   [self.view addSubview:premiumImage];

   UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0f-150.0f, 15, 300.0f, 20)];
   titleLabel.text = NSLocalizedString(@"UpgradePremium", nil);
   titleLabel.textColor = [UIColor whiteColor];
   titleLabel.textAlignment = NSTextAlignmentCenter;
   titleLabel.backgroundColor = [UIColor clearColor];
   [topbar addSubview:titleLabel];

   UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
   btn.frame = CGRectMake(self.view.frame.size.width/2.0f-150.0f, self.view.frame.size.height-140, 300, 60);
   [btn setTitle:NSLocalizedString(@"Upgrade", nil) forState:UIControlStateNormal];
   [btn addTarget:self action:@selector(getPremium) forControlEvents:UIControlEventTouchUpInside];
   [btn setBackgroundImage:[UIImage imageNamed:@"button2.png"] forState:UIControlStateNormal];
   [self.view addSubview:btn];

   btn = [UIButton buttonWithType:UIButtonTypeCustom];
   btn.frame = CGRectMake(self.view.frame.size.width/2.0f-150.0f, self.view.frame.size.height-70, 300, 60);
   [btn setTitle:NSLocalizedString(@"Continue", nil) forState:UIControlStateNormal];
   [btn addTarget:self action:@selector(hideVC) forControlEvents:UIControlEventTouchUpInside];
   [btn setBackgroundImage:[UIImage imageNamed:@"button3.png"] forState:UIControlStateNormal];
   [self.view addSubview:btn];
}
-(void) didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) hideVC{
   [self dismissViewControllerAnimated:YES completion:nil];
}
-(void) getPremium{
   NSArray * productIdentifiers = @[
                                    @"premium",
                                    ];

   SKProductsRequest *productsRequest = [[SKProductsRequest alloc]
                                         initWithProductIdentifiers:[NSSet setWithArray:productIdentifiers]];
   productsRequest.delegate = self;
   [productsRequest start];
}
-(void) productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
   if (response.products.count < 1 || ![((SKProduct*)response.products[0]).productIdentifier isEqualToString:@"premium"]) {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error while trying do upgrade to premium version" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
      [alert show];
      [self dismissViewControllerAnimated:YES completion:nil];
      return;
   }

   SKPayment *payment = [SKPayment paymentWithProduct:response.products[0]];
   [[SKPaymentQueue defaultQueue] addPayment:payment];
   [self dismissViewControllerAnimated:YES completion:nil];
}

@end
