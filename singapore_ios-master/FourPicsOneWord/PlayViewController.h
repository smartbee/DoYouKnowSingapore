//
//  PlayViewController.h
//  FourPicsOneWord
//
//  Created by  on 10/14/13.
//  Copyright (c) 2013 Vojtec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface PlayViewController : UIViewController <UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource, SKProductsRequestDelegate>

-(id)initAsBonus:(BOOL)bonus;

@end
