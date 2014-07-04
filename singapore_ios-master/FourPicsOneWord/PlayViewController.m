//
//  PlayViewController.m
//  FourPicsOneWord
//
//  Created by  on 10/14/13.
//  Copyright (c) 2013 Vojtec. All rights reserved.
//

#import "PlayViewController.h"
#import "ImagesModel.h"
#import <Social/Social.h>
#import "GetPremiumViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <RevMobAds/RevMobAds.h>
#import <AudioToolbox/AudioToolbox.h>


@interface PlayViewController (){
   BOOL bonus;

   PicsAndWord *current;
   BOOL blinkAnimate;

   UIImageView *imgView1;
   UIImageView *imgView2;
   UIImageView *imgView3;
   UIImageView *imgView4;

   UIView *winView;

   NSArray *productIds;

   UILabel *numAnsweredLabel;

    UILabel *labelCategory;
    UILabel *labelCoin;
    UILabel *labelLevel;
    UIImageView *imageLevelRed;
    
   int numAnsweredInRow;

   SystemSoundID letterSound;
   SystemSoundID successSound;
}
@end

@implementation PlayViewController

#pragma mark - Init Function
-(id) initAsBonus:(BOOL)bonus_;{
   self = [super initWithNibName:nil bundle:nil];
   if (self) {
      // Custom initialization
      bonus = bonus_;
      numAnsweredInRow = 3;
   }
   return self;
}
-(id) init{
   return [self initAsBonus:NO];
}
-(float) topOffset{
   float offset = 0;
   if ([self respondsToSelector:@selector(topLayoutGuide)]) {
      //      offset = self.topLayoutGuide.length;
//      offset = 45;
      offset = 0;
   }
   return offset;
}

#pragma mark - Main Init
-(void) viewDidLoad{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

   NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"letters" ofType:@"caf"]];
   AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url), &letterSound);
   url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"success" ofType:@"m4a"]];
   AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url), &successSound);

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    imageView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:imageView];
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        [imageView setImage:[UIImage imageNamed:@"backgroundipad.png"]];
//    } else {
//        [imageView setImage:[UIImage imageNamed:@"bg.jpg"]];
//    }
   
//   self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];

//   UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//   [backBtn setTitle:@"< Back" forState:UIControlStateNormal];
//   backBtn.frame = CGRectMake(0.0, 0.0, 20, 20);
//   [backBtn addTarget:self action:@selector(popVC) forControlEvents:UIControlEventTouchUpInside];
//   UIBarButtonItem *bi = [[UIBarButtonItem alloc]
//                          initWithCustomView:backBtn];
//   self.navigationItem.backBarButtonItem = bi;
    
    labelCategory = [[UILabel alloc] init];
    [labelCategory setBackgroundColor:[UIColor clearColor]];
    [labelCategory setTextColor:[UIColor whiteColor]];
    [labelCategory setFont:[UIFont systemFontOfSize:20]];
    [labelCategory setTextAlignment:NSTextAlignmentCenter];
    [labelCategory setFrame:CGRectMake(0, 70, 320, 30)];
    //    [labelCategory setText:@"labelCategory"];
    [self.view addSubview:labelCategory];

   if (!bonus) {
      UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"badge.png"]];
      [titleView setContentMode:UIViewContentModeScaleAspectFit];
      numAnsweredLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleView.frame.size.width/2.0f - 20.0f, titleView.frame.size.height/2.0f - 20.0f, 40.0f, 40.0f)];
      numAnsweredLabel.text = [NSString stringWithFormat:@"%d/%d", [[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex]+1, [[ImagesModel sharedModel] numberOfAllPicsInPackage:[ImagesModel sharedModel].currentPackageIndex]];
      numAnsweredLabel.textColor = [UIColor whiteColor];
      numAnsweredLabel.backgroundColor = [UIColor clearColor];
      numAnsweredLabel.textAlignment = NSTextAlignmentCenter;
      [titleView addSubview:numAnsweredLabel];
      self.navigationItem.titleView = titleView;
   }

   if (bonus) {
      current = [[ImagesModel sharedModel] nextBonusForPreviousID:[ImagesModel sharedModel].numberOfBonusAnswered-1];
   } else {
      current = [[ImagesModel sharedModel] picsAndWordForID:[[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex] inPackage:[ImagesModel sharedModel].currentPackageIndex];
   }

   float imagesLength = self.view.frame.size.width*0.5f;
   float gap = 5.0f;

   imgView1 = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0f - imagesLength - gap/2.0f, 80.0f-45.0f+[self topOffset], imagesLength, imagesLength)];
   imgView2 = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0f + gap/2.0f, 80.0f-45.0f+[self topOffset], imagesLength, imagesLength)];
   imgView3 = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0f - imagesLength - gap/2.0f, 80.0f + gap + imagesLength-45.0f+[self topOffset], imagesLength, imagesLength)];
   imgView4 = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0f + gap/2.0f, 80.0f + gap + imagesLength-45.0f+[self topOffset], imagesLength, imagesLength)];

    [imgView1 setCenter:CGPointMake(self.view.frame.size.width/2.0, self.view.frame.size.height/2.0 - 80)];
   imgView1.layer.cornerRadius = 3;
   imgView1.layer.borderColor = [UIColor darkGrayColor].CGColor;
   imgView2.layer.borderWidth = 5;
   imgView2.layer.borderColor = [UIColor darkGrayColor].CGColor;
   imgView3.layer.borderWidth = 5;
   imgView3.layer.borderColor = [UIColor darkGrayColor].CGColor;
   imgView4.layer.borderWidth = 5;
   imgView4.layer.borderColor = [UIColor darkGrayColor].CGColor;

   imgView1.image = current.picture1;
//   imgView2.image = current.picture2;
//   imgView3.image = current.picture3;
//   imgView4.image = current.picture4;
//
//   [self.view addSubview:imgView1];
//   [self.view addSubview:imgView2];
//   [self.view addSubview:imgView3];
   [self.view addSubview:imgView1];


   float letterWidth = 38.0f;
    float letterHeight = 24.0f;

   gap = 5.0f;

   for (int i = 0; i < current.word.length; i++) {
      UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0f - (letterHeight+gap)*current.word.length/2.0f + i * (letterHeight+gap), self.view.frame.size.height - 220  , letterHeight, letterWidth)];
//       self.view.frame.size.height - 40 -  (letterBtnHeight+5.0f)*(2-j)  
      [btn setBackgroundImage:[UIImage imageNamed:@"lettersilver.png"] forState:UIControlStateNormal];
       [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
       [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
      [btn setTitle:@"" forState:UIControlStateNormal];
      btn.tag = 100 + i;
      [btn addTarget:self action:@selector(removeLetter:) forControlEvents:UIControlEventTouchUpInside];
      [self.view addSubview:btn];
   }

   float letterBtnHeight = 38.0f;
    float letterBtnWidth = 26.0f;

   for (int i = 0; i < NUMBER_LETTER; i++) {
      for (int j = 0; j < 2; j++) {
//         if (i < 6) {
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0f - (letterBtnWidth+gap)*NUMBER_LETTER/2.0f + i * (letterBtnWidth+gap),self.view.frame.size.height - 40 -  (letterBtnHeight+5.0f)*(2-j)  , letterBtnWidth, letterBtnHeight)];
            [btn setBackgroundImage:[UIImage imageNamed:@"letteryellow.png"] forState:UIControlStateNormal];
          
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
          [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
            [btn addTarget:self action:@selector(chooseLetter:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = 1000 + i + NUMBER_LETTER*j;
            [btn setTitle:[current availableLetters][i + NUMBER_LETTER*j] forState:UIControlStateNormal];
            [self.view addSubview:btn];
//         } else {
//            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0f - (letterBtnHeight+gap)*7.0f/2.0f + i * (letterBtnHeight+gap), 110.0f + letterWidth + imagesLength*2.0f + (letterBtnHeight+5.0f)*j-45.0f+[self topOffset], letterBtnHeight, letterBtnHeight)];
//            if (j == 0) {
//               [btn addTarget:self action:@selector(showCorrectLetters) forControlEvents:UIControlEventTouchUpInside];
//               [btn setBackgroundImage:[UIImage imageNamed:@"showLetterBtn.png"] forState:UIControlStateNormal];
//            }
//            if (j == 1) {
//               [btn addTarget:self action:@selector(deleteLetters) forControlEvents:UIControlEventTouchUpInside];
//               [btn setBackgroundImage:[UIImage imageNamed:@"deleteLetterBtn.png"] forState:UIControlStateNormal];
//            }
//            [self.view addSubview:btn];
//         }
      }
   }

   UIButton *fbBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0f - (letterBtnHeight+gap)*7.0f/2.0f + 6 * (letterBtnHeight+gap), 110.0f + letterWidth + imagesLength*2.0f + (letterBtnHeight+5.0f)*-1-45.0f+[self topOffset], letterBtnHeight, letterBtnHeight)];
//   fbBtn.backgroundColor = [UIColor greenColor];
   [fbBtn setBackgroundImage:[UIImage imageNamed:@"fbBtn.png"] forState:UIControlStateNormal];
   [fbBtn addTarget:self action:@selector(shareFb) forControlEvents:UIControlEventTouchUpInside];
//   [self.view addSubview:fbBtn];


   UIButton *coinsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
   [coinsBtn setTitle:[NSString stringWithFormat:@"       %d", [ImagesModel sharedModel].coins] forState:UIControlStateNormal];
   coinsBtn.frame = CGRectMake(0.0, 0.0, 70, 20);
   coinsBtn.titleLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
//   [coinsBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
   coinsBtn.layer.cornerRadius = 10;
   coinsBtn.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
   [coinsBtn addTarget:self action:@selector(getCoins) forControlEvents:UIControlEventTouchUpInside];

   UIImageView *coinsImgView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 2, 15, 15)];
   coinsImgView.image = [UIImage imageNamed:@"morecoins.png"];
//   [coinsBtn addSubview:coinsImgView];

   UIBarButtonItem *bi = [[UIBarButtonItem alloc]
                          initWithCustomView:coinsBtn];
   self.navigationItem.rightBarButtonItem = bi;

   [self updateLetters];
    
    UIButton *buttonBack = [[UIButton alloc] initWithFrame:CGRectMake(10 , 8 , 40.0f, 35.0f)];
    //[moreGamesBtn setTitle:NSLocalizedString(@"MoreGames", nil) forState:UIControlStateNormal];
    buttonBack.titleLabel.font = [UIFont systemFontOfSize:12];
    [buttonBack setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [buttonBack addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    //   [moreGamesBtn.titleLabel setTextAlignment:NSTextAlignmentNatural];
    buttonBack.tag = 1010;
    buttonBack.hidden = [ImagesModel sharedModel].premium;
    [self.view addSubview:buttonBack];

    UIButton *buttonFacebook = [[UIButton alloc] initWithFrame:CGRectMake(10 , self.view.frame.size.height - 170 , 140.0f, 32.0f)];
    //[moreGamesBtn setTitle:NSLocalizedString(@"MoreGames", nil) forState:UIControlStateNormal];
    buttonFacebook.titleLabel.font = [UIFont systemFontOfSize:12];
    [buttonFacebook setBackgroundImage:[UIImage imageNamed:@"useface.png"] forState:UIControlStateNormal];
//    [buttonFacebook addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    //   [moreGamesBtn.titleLabel setTextAlignment:NSTextAlignmentNatural];
    buttonFacebook.tag = 1010;
    buttonFacebook.hidden = [ImagesModel sharedModel].premium;
    [self.view addSubview:buttonFacebook];

    UIButton *buttonBoost = [[UIButton alloc] initWithFrame:CGRectMake( self.view.frame.size.width/2 + 10 , self.view.frame.size.height - 170 , 140.0f, 32.0f)];
    //[moreGamesBtn setTitle:NSLocalizedString(@"MoreGames", nil) forState:UIControlStateNormal];
    buttonBoost.titleLabel.font = [UIFont systemFontOfSize:12];
    [buttonBoost setBackgroundImage:[UIImage imageNamed:@"useboost.png"] forState:UIControlStateNormal];
//    [buttonBoost addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    //   [moreGamesBtn.titleLabel setTextAlignment:NSTextAlignmentNatural];
    buttonBoost.tag = 1010;
    buttonBoost.hidden = [ImagesModel sharedModel].premium;
    [self.view addSubview:buttonBoost];
    [labelCategory setText:current.category];
    
    UIImageView *imageCoin = [[UIImageView alloc] init];
    [imageCoin setFrame:CGRectMake(70, 5, 125, 45)];
    [imageCoin setImage:[UIImage imageNamed:@"coin_background.png"]];
    [self.view addSubview:imageCoin];
    labelCoin = [[UILabel alloc] init];
    [labelCoin setBackgroundColor:[UIColor clearColor]];
    [labelCoin setTextColor:[UIColor blackColor]];
    [labelCoin setFont:[UIFont boldSystemFontOfSize:16]];
    [labelCoin setTextAlignment:NSTextAlignmentCenter];
    [labelCoin setFrame:CGRectMake(0, 8, 125, 25)];
    [labelCoin setText:[NSString stringWithFormat:@"%d",[ImagesModel sharedModel].coins]];
    [imageCoin addSubview:labelCoin];
    
    UIImageView *imageLevel = [[UIImageView alloc] init];
    [imageLevel setFrame:CGRectMake(210, 12, 105, 30)];
    [imageLevel setImage:[UIImage imageNamed:@"black_level.png"]];
    [self.view addSubview:imageLevel];
    
    imageLevelRed = [[UIImageView alloc] init];
    
    float level = [[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex];
    float totallevel = [[ImagesModel sharedModel] numberOfAllPicsInPackage:[ImagesModel sharedModel].currentPackageIndex];
    float scale = level/totallevel;
//    NSLog(@"%f %f", level, totallevel);
    [imageLevelRed setFrame:CGRectMake(210, 12, 105.0*scale, 30)];
    [imageLevelRed setImage:[UIImage imageNamed:@"red_level.png"]];
    [self.view addSubview:imageLevelRed];

    UIImageView *imageStarLevel = [[UIImageView alloc] init];
    [imageStarLevel setFrame:CGRectMake(200, 7, 40, 40)];
    [imageStarLevel setImage:[UIImage imageNamed:@"star_level.png"]];
    [self.view addSubview:imageStarLevel];

    labelLevel = [[UILabel alloc] init];
    [labelLevel setBackgroundColor:[UIColor clearColor]];
    [labelLevel setTextColor:[UIColor blackColor]];
    [labelLevel setFont:[UIFont boldSystemFontOfSize:16]];
    [labelLevel setTextAlignment:NSTextAlignmentCenter];
    [labelLevel setFrame:CGRectMake(5, 8, 30, 25)];
    
    [labelLevel setText:[NSString stringWithFormat:@"%d", [[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex]+1]];
    [imageStarLevel addSubview:labelLevel];

}
-(void) back{
    [[self navigationController] popViewControllerAnimated:YES];
}

#pragma mark - Dealloc Funciton
-(void) dealloc{
   AudioServicesDisposeSystemSoundID(letterSound);
   AudioServicesDisposeSystemSoundID(successSound);
}

-(void) popVC{
   [self.navigationController popViewControllerAnimated:YES];
}
-(void) animateLetters{
   for (int i = 0; i < NUMBER_LETTER; i++) {
      for (int j = 0; j < 2; j++) {
         UIButton *btn = (UIButton*)[self.view viewWithTag:1000 + i + NUMBER_LETTER*j];
         [btn setHidden:YES];
      }
   }

   NSArray *availability = [current letterAvailability];
   for (int i = 0; i < NUMBER_LETTER; i++) {
      for (int j = 0; j < 2; j++) {
         UIButton *btn = (UIButton*)[self.view viewWithTag:1000 + i + NUMBER_LETTER*j];
         if (((NSNumber*)availability[i + NUMBER_LETTER*j]).boolValue) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.15*(i + NUMBER_LETTER*j) * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
               [btn setHidden:NO];
            });
         }

         [UIView animateWithDuration:0.2 delay:0.15*(i + NUMBER_LETTER*j) options:UIViewAnimationOptionAllowUserInteraction animations:^(void) {
            btn.frame = CGRectMake(btn.frame.origin.x-5.0f, btn.frame.origin.y-5.0f, btn.frame.size.width+10.0f, btn.frame.size.height+10.0f);
         } completion:^(BOOL finished) {
            btn.frame = CGRectMake(btn.frame.origin.x+5.0f, btn.frame.origin.y+5.0f, btn.frame.size.width-10.0f, btn.frame.size.height-10.0f);
         }];
      }
   }
}

#pragma mark - Appear Function
-(void) viewWillAppear:(BOOL)animated{
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCoins) name:@"updatedCoinsAndPremium" object:nil];
}
-(void) viewDidAppear:(BOOL)animated{
   [self animateLetters];
}
-(void) viewWillDisappear:(BOOL)animated{
   [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Letters Function
-(void) updateLetters{
   for (int i = 0; i < current.word.length; i++) {
      UIButton *btn = (UIButton*) [self.view viewWithTag:100+i];
       
      [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
       NSString *str = [current chosenLetters][i];
       if (str.length>0) {
           [btn setBackgroundImage:[UIImage imageNamed:@"letteryellow.png"] forState:UIControlStateNormal];
       }else{
           [btn setBackgroundImage:[UIImage imageNamed:@"lettersilver.png"] forState:UIControlStateNormal];
       }
      [btn setTitle:[current chosenLetters][i] forState:UIControlStateNormal];
   }
   NSArray *available = [current letterAvailability];
   for (int i = 0; i < NUMBER_LETTER*2; i++) {
      UIButton *btn = (UIButton*) [self.view viewWithTag:1000+i];
      [btn setHidden:!((NSNumber*)available[i]).boolValue];
   }
   for (NSNumber* num in [current revealedLetters]) {
      UIButton *btn = (UIButton*) [self.view viewWithTag:100+num.intValue];
      [btn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
   }
}
-(void) chooseLetter:(UIButton*)sender{
   blinkAnimate = NO;

   [current chooseLetterFromAvailableLetters:sender.tag-1000];
   [self updateLetters];
   if (((NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:@"sounds"]).boolValue) {
      AudioServicesPlaySystemSound(letterSound);
   }

   if ([current wordIsFull]) {
      if ([current solutionIsCorrect]) {
         BOOL coinsWon = YES;
         if (!bonus) {
            coinsWon = ![[ImagesModel sharedModel] isWon:[[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex] inPackage:[ImagesModel sharedModel].currentPackageIndex];
            [[ImagesModel sharedModel] winWithID:[[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex] inPackage:[ImagesModel sharedModel].currentPackageIndex];
//            [[ImagesModel sharedModel] setIndexOfCurrentWord:[ImagesModel sharedModel].currentWordIndex+1];
         } else {
            [ImagesModel sharedModel].numberOfBonusAnswered++;
            [[ImagesModel sharedModel] winBonus];
            [[ImagesModel sharedModel] setLastAnsweredBonus:[NSDate date]];
         }
         numAnsweredInRow++;

         [((UIButton*)self.navigationItem.rightBarButtonItem.customView) setTitle:[NSString stringWithFormat:@"       %d", [ImagesModel sharedModel].coins] forState:UIControlStateNormal];
          [labelCoin setText:[NSString stringWithFormat:@"%d",[ImagesModel sharedModel].coins]];


         if (((NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:@"sounds"]).boolValue) {
            AudioServicesPlaySystemSound(successSound);
         }

         winView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height+45.0f)];
         winView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6f];
//         UILabel *congratsLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0f - 100.0f, 100.0f, 200.0f, 40.0f)];
//         congratsLabel.backgroundColor = [UIColor clearColor];
//         congratsLabel.textAlignment = NSTextAlignmentCenter;
//         congratsLabel.textColor = [UIColor whiteColor];
//         congratsLabel.font = [UIFont boldSystemFontOfSize:25];
//         congratsLabel.text = NSLocalizedString(@"Congrats", nil);
//         [winView addSubview:congratsLabel];
//
//         UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0f - 150.0f, 140.0f-90.0f, 300.0f, 40.0f)];
//         rightLabel.backgroundColor = [UIColor clearColor];
//         rightLabel.textAlignment = NSTextAlignmentCenter;
//         rightLabel.textColor = [UIColor whiteColor];
//         rightLabel.text = NSLocalizedString(@"Right", nil);
//         rightLabel.font = [UIFont systemFontOfSize:15];
//         [winView addSubview:rightLabel];
//
//         float letterWidth = 30.0f;
//         float gap = 5.0f;
//
//         for (int i = 0; i < current.word.length; i++) {
//
//            UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0f - (letterWidth+gap)*current.word.length/2.0f + i * (letterWidth+gap), 200-45.0f, letterWidth, letterWidth)];
//            lbl.text = [NSString stringWithFormat:@"%c", [current.word characterAtIndex:i]];
//            lbl.backgroundColor = [UIColor blackColor];
//            lbl.textColor = [UIColor whiteColor];
//            lbl.textAlignment = NSTextAlignmentCenter;
//            [winView addSubview:lbl];
//         }
//          float imagesLength = self.view.frame.size.width*0.5f;

          UIImageView *imageNice = [[UIImageView alloc] init];
          [imageNice setFrame:CGRectMake(0, 0, 220, 80)];
          [imageNice setImage:[UIImage imageNamed:@"nice_it.png"]];
          [imageNice setCenter:imgView1.center];
          [winView addSubview:imageNice];
          
         if (!bonus) {
            UILabel *badgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0f - 150.0f, 250.0f-45.0f, 300.0f, 40.0f)];
            badgeLabel.backgroundColor = [UIColor clearColor];
            badgeLabel.textAlignment = NSTextAlignmentCenter;
            badgeLabel.textColor = [UIColor whiteColor];
            badgeLabel.text = [NSString stringWithFormat:@"%d", [[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex]+1];
            badgeLabel.font = [UIFont systemFontOfSize:28];
//            [winView addSubview:badgeLabel];

//            if (coinsWon) {
//               for (int i = 0; i < 4; i++) {
//                  UIImageView *coinImg = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0f - ((float)i-1.5f)*30-10, self.view.frame.size.height+10, 20, 20)];
//                  coinImg.image = [UIImage imageNamed:@"coins.png"];
//                  [winView addSubview:coinImg];
//
//                  [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void) {
//                     coinImg.frame = CGRectMake(self.view.frame.size.width/2.0f - ((float)i-1.5f)*30-10, 290-45.0f, 20, 20);
//                  } completion:^(BOOL finished) {
//                     [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void) {
//                        coinImg.frame = CGRectMake(self.view.frame.size.width/2.0f - ((float)i-1.5f)*30-10, 310-45.0f, 20, 20);
//                     } completion:^(BOOL finished) {
//                        [UIView animateWithDuration:0.5 delay:i*0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^(void) {
//                           coinImg.frame = CGRectMake(self.view.frame.size.width-25, 15, 5, 5);
//                        } completion:^(BOOL finished) {
//                           [coinImg removeFromSuperview];
//                        }];
//                     }];
//                  }];
//               }
//            }
         } else {
            for (int j = 0; j < 4; j++) {
               for (int i = 0; i < 5; i++) {
                  UIImageView *coinImg = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0f - ((float)i-2.0f)*30-10, self.view.frame.size.height+10, 20, 20)];
                  coinImg.image = [UIImage imageNamed:@"coins.png"];
                  [winView addSubview:coinImg];

                  [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void) {
                     coinImg.frame = CGRectMake(self.view.frame.size.width/2.0f - ((float)i-2.0f)*30-10, 220 + j*30-45.0f, 20, 20);
                  } completion:^(BOOL finished) {
                     [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void) {
                        coinImg.frame = CGRectMake(self.view.frame.size.width/2.0f - ((float)i-2.0f)*30-10, 250 + j*30-45.0f, 20, 20);
                     } completion:^(BOOL finished) {
                        [UIView animateWithDuration:0.5 delay:(i+j)*0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^(void) {
                           coinImg.frame = CGRectMake(self.view.frame.size.width-25, 15, 5, 5);
                        } completion:^(BOOL finished) {
                           [coinImg removeFromSuperview];
                        }];
                     }];
                  }];
               }
            }
         }

         UIButton *continueBtn = [UIButton buttonWithType:UIButtonTypeCustom];
         continueBtn.frame = CGRectMake(self.view.frame.size.width/2.0f - 150.0f, 370+45.0f, 300, 60);
//         [continueBtn setTitle:NSLocalizedString(@"Continue", nil) forState:UIControlStateNormal];
         [continueBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
         [continueBtn setBackgroundImage:[UIImage imageNamed:@"continue.png"] forState:UIControlStateNormal];
         if (!bonus) {
            [continueBtn addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
         } else {
            [continueBtn addTarget:self action:@selector(dismissBonus) forControlEvents:UIControlEventTouchUpInside];
         }
         [winView addSubview:continueBtn];

         [self.view.window addSubview:winView];
      } else {
         blinkAnimate = YES;
         for (int i = 0; i < current.word.length; i++) {
            UIButton *btn = (UIButton*) [self.view viewWithTag:100+i];
            [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
         }
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            if (blinkAnimate) {
               for (int i = 0; i < current.word.length; i++) {
                  UIButton *btn = (UIButton*) [self.view viewWithTag:100+i];
                  [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
               }
               dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                  if (blinkAnimate) {
                     for (int i = 0; i < current.word.length; i++) {
                        UIButton *btn = (UIButton*) [self.view viewWithTag:100+i];
                        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                     }
                     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        if (blinkAnimate) {
                           for (int i = 0; i < current.word.length; i++) {
                              UIButton *btn = (UIButton*) [self.view viewWithTag:100+i];
                              [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                           }
                           dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                              if (blinkAnimate) {
                                 for (int i = 0; i < current.word.length; i++) {
                                    UIButton *btn = (UIButton*) [self.view viewWithTag:100+i];
                                    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                                 }
                              }
                           });
                        }
                     });
                  }
               });
            }
         });
      }
   }
}
-(void) removeLetter:(UIButton*)sender{
   blinkAnimate = NO;

   if (((NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:@"sounds"]).boolValue) {
      AudioServicesPlaySystemSound(letterSound);
   }
   [current removeLetterFromChosenLetters:sender.tag-100];
   [self updateLetters];
}
-(void) dismissBonus{
   [winView removeFromSuperview];
   [self.navigationController popViewControllerAnimated:YES];
}
-(void) next{
   if (numAnsweredInRow == 5 && ![ImagesModel sharedModel].premium) {
      [[RevMobAds session] showFullscreen];
   }
   numAnsweredInRow = numAnsweredInRow % 5;
   if ([[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex]+1 >= [[ImagesModel sharedModel] numberOfAllPicsInPackage:[ImagesModel sharedModel].currentPackageIndex]) {
      [[ImagesModel sharedModel] unlockPackage:[ImagesModel sharedModel].currentPackageIndex+1];
      if ([ImagesModel sharedModel].currentPackageIndex+1 >= [ImagesModel sharedModel].numberOfPackages) {
         [winView removeFromSuperview];
         [self.navigationController popViewControllerAnimated:YES];
         return;
      } else {
         [[ImagesModel sharedModel] setIndexOfCurrentWord:0 inPackage:[ImagesModel sharedModel].currentPackageIndex+1];
      }
   } else {
      [[ImagesModel sharedModel] setIndexOfCurrentWord:[[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex]+1 inPackage:[ImagesModel sharedModel].currentPackageIndex];
   }
   [winView removeFromSuperview];

   PicsAndWord *old = current;
   current = [[ImagesModel sharedModel] picsAndWordForID:[[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex] inPackage:[ImagesModel sharedModel].currentPackageIndex];
   numAnsweredLabel.text = [NSString stringWithFormat:@"%d/%d", [[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex]+1, [[ImagesModel sharedModel] numberOfAllPicsInPackage:[ImagesModel sharedModel].currentPackageIndex]];

   imgView1.image = current.picture1;
   imgView2.image = current.picture2;
   imgView3.image = current.picture3;
   imgView4.image = current.picture4;

   for (int i = 0; i < old.word.length; i++) {
      UIButton *btn = (UIButton*)[self.view viewWithTag:100+i];
      [btn removeFromSuperview];
   }

   float imagesLength = self.view.frame.size.width*0.4f - 20.0f;
    float letterWidth = 38.0f;
    float letterHeight = 24.0f;
   float gap = 5.0f;

   for (int i = 0; i < current.word.length; i++) {
//      UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0f - (letterWidth+gap)*current.word.length/2.0f + i * (letterWidth+gap), 100.0f + imagesLength*2.0f-[self topOffset], letterWidth, letterWidth)];

//      UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0f - (letterWidth+gap)*current.word.length/2.0f + i * (letterWidth+gap)-25, 140.0f + imagesLength*2.0f-45.0f, letterWidth, letterWidth)];

      UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0f - (letterHeight+gap)*current.word.length/2.0f + i * (letterHeight+gap)-25, 100.0f + imagesLength*2.0f+[self topOffset], letterHeight, letterWidth)];
//      btn.backgroundColor = [UIColor blackColor];
      [btn setBackgroundImage:[UIImage imageNamed:@"selectedLetterBG.png"] forState:UIControlStateNormal];
      [btn setTitle:@"" forState:UIControlStateNormal];
      btn.tag = 100 + i;
      [btn addTarget:self action:@selector(removeLetter:) forControlEvents:UIControlEventTouchUpInside];
      [self.view addSubview:btn];
   }
   for (int i = 0; i < NUMBER_LETTER*2; i++) {
      UIButton *btn = (UIButton*)[self.view viewWithTag:1000+i];
      [btn setTitle:[current availableLetters][i] forState:UIControlStateNormal];
   }
   [self updateLetters];
   [self animateLetters];
    [labelLevel setText:[NSString stringWithFormat:@"%d", [[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex]+1]];

}
-(void) deleteLetters{
   if ([ImagesModel sharedModel].coins > 80) {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"DeleteInfo", nil) delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
      alert.tag = 10001;
      [alert show];
   } else {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Not enough coins", nil) message:[NSString stringWithFormat:NSLocalizedString(@"Not enough coins details", nil), @(80)] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
      alert.tag = 10003;
      [alert show];
   }
}
-(void) showCorrectLetters{
   if ([ImagesModel sharedModel].coins > 60) {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"ShowInfo", nil) delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
      alert.tag = 10002;
      [alert show];
   } else {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Not enough coins", nil) message:[NSString stringWithFormat:NSLocalizedString(@"Not enough coins details", nil), @(60)] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
      alert.tag = 10003;
      [alert show];
   }
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
   if (alertView.tag == 10001) {
      if (buttonIndex == 1) {
         //del 3. cost 80
         int num = [current deleteIncorrectLetters];
         if (num > 0) {
            [[ImagesModel sharedModel] payCoins:80];
         }
         [self updateLetters];
         
      }
   } else if (alertView.tag == 10002) {
      if (buttonIndex == 1) {
         //show 1. cost 60
         BOOL replaced = [current showCorrectLetter];
         if (replaced) {
            [[ImagesModel sharedModel] payCoins:60];
         }
         [self updateLetters];
//         int randPos = rand() % current.word.length;
//         NSString *randChar = [NSString stringWithFormat:@"%c", [current.word characterAtIndex:randPos]];
//         for (int i = 0; i < 6; i++) {
//            for (int j = 0; j < 2; j++) {
//               UIButton *btn = (UIButton*)[self.view viewWithTag:1000 + i + 6*j];
//               if (![btn isHidden] && [btn.titleLabel.text isEqualToString:randChar]) {
//
//               }
//            }
//         }
      }
   } else if (alertView.tag == 10003) {
      [self getCoins];

   }

   [self updateCoins];
}
-(void) getCoins{
   if ([SKPaymentQueue canMakePayments]) {

      UIView *buyCoinsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height+[self topOffset]+[self topOffset]+300)];
      buyCoinsView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];


      UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(10, 20, self.view.frame.size.width-20, self.view.frame.size.height-40+45.0f-[self topOffset])];
      bgView.backgroundColor = [UIColor whiteColor];
      bgView.tag = 88888;
      [buyCoinsView addSubview:bgView];


      UIActivityIndicatorView *actview = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(bgView.frame.size.width/2.0f-20, 70, 40, 40)];
      actview.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
      actview.tag = 555555;
      [actview startAnimating];
      [bgView addSubview:actview];

      UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
      cancelBtn.frame = CGRectMake(bgView.frame.size.width/2.0f - 100.0f, bgView.frame.size.height-50, 200, 40);
      [cancelBtn setTitle:NSLocalizedString(@"CancelBuy", nil) forState:UIControlStateNormal];
      [cancelBtn addTarget:self action:@selector(cancelBuy:) forControlEvents:UIControlEventTouchUpInside];
      [cancelBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
      [bgView addSubview:cancelBtn];
      
      [self.view.window addSubview:buyCoinsView];

      [self performSelectorInBackground:@selector(fetchProducts) withObject:nil];
   } else {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"In-App Purchases unavailable" message:@"Please enable In-App purchases in the settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
      [alert show];
   }
}
-(void) fetchProducts{
   NSArray * productIdentifiers = @[
                                    @"coins350",
                                    @"premium",
                                    @"coins750",
                                    @"coins2000",
                                    @"coins4500",
                                    @"coins10000",
                                    ];

   SKProductsRequest *productsRequest = [[SKProductsRequest alloc]
                                         initWithProductIdentifiers:[NSSet setWithArray:productIdentifiers]];
   productsRequest.delegate = self;
   [productsRequest start];
}
-(void) productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
//   [activeBuyRequest stopAnimating];
//   [activeBuyRequest removeFromSuperview];

   productIds = [response.products sortedArrayUsingComparator:^NSComparisonResult(SKProduct* a, SKProduct* b) {
      if (a.price == b.price) {
         return  [a.localizedTitle compare:b.localizedTitle];
      }
      return [a.price compare:b.price];
   }];

   for (NSString * invalidProductIdentifier in response.invalidProductIdentifiers) {
      // Handle any invalid product identifiers.
   }

   dispatch_async(dispatch_get_main_queue(), ^(void){
      UIView *buyCoinsView = [self.view.window viewWithTag:88888];
      if (buyCoinsView) {
         UIView *actview = [buyCoinsView viewWithTag:555555];
         [actview removeFromSuperview];


         UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 40, buyCoinsView.frame.size.width-20, buyCoinsView.frame.size.height-120)];
         tableView.delegate = self;
         tableView.dataSource = self;
         tableView.clipsToBounds = YES;
         [buyCoinsView addSubview:tableView];
      }
   });

//   UIView *buyCoinsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height+[self topOffset])];
//   buyCoinsView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
//
//
//   UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(10, 20, self.view.frame.size.width-20, self.view.frame.size.height-40)];
//   bgView.backgroundColor = [UIColor whiteColor];
//   [buyCoinsView addSubview:bgView];
//
//
//   UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 70, self.view.frame.size.width-20, self.view.frame.size.height-150)];
//   tableView.delegate = self;
//   tableView.dataSource = self;
//   tableView.clipsToBounds = YES;
//   [buyCoinsView addSubview:tableView];
//
//   UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//   cancelBtn.frame = CGRectMake(self.view.frame.size.width/2.0f - 100.0f, self.view.frame.size.height-100, 200, 40);
//   [cancelBtn setTitle:NSLocalizedString(@"CancelBuy", nil) forState:UIControlStateNormal];
//   [cancelBtn addTarget:self action:@selector(cancelBuy:) forControlEvents:UIControlEventTouchUpInside];
//   [cancelBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
//   [buyCoinsView addSubview:cancelBtn];
//
//   [self.view.window addSubview:buyCoinsView];
}
-(void) cancelBuy:(UIButton*)sender{
   [sender.superview.superview removeFromSuperview];

}

#pragma mark - TableView Delegate
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
   return 1;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//   return 6;
   return productIds.count;
}
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@""];

   static NSNumberFormatter * numberFormatter = nil;
   if (numberFormatter == nil) {
      numberFormatter = [[NSNumberFormatter alloc] init];
      [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
      [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
   };

   SKProduct *product = productIds[indexPath.row];
   [numberFormatter setLocale:product.priceLocale];
   cell.detailTextLabel.text = [numberFormatter stringFromNumber:product.price];
   cell.imageView.image = [UIImage imageNamed:@"morecoins.png"];
   if ([product.productIdentifier isEqualToString:@"premium"]) {
      cell.imageView.image = [UIImage imageNamed:@"premiumSmall.png"];
      cell.userInteractionEnabled = ![ImagesModel sharedModel].premium;
   }

   cell.textLabel.text = product.localizedTitle;
   cell.detailTextLabel.text = [numberFormatter stringFromNumber:product.price];

   return cell;
}
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   SKProduct *product = productIds[indexPath.row];
   if ([product.productIdentifier isEqualToString:@"premium"]) {
      GetPremiumViewController *vc = [[GetPremiumViewController alloc] init];
      [self presentViewController:vc animated:YES completion:nil];
   } else {
      SKPayment *payment = [SKPayment paymentWithProduct:product];
      [[SKPaymentQueue defaultQueue] addPayment:payment];
   }
   [tableView.superview.superview removeFromSuperview];
}

-(void) updateCoins{
   [((UIButton*)self.navigationItem.rightBarButtonItem.customView) setTitle:[NSString stringWithFormat:@"       %d", [ImagesModel sharedModel].coins] forState:UIControlStateNormal];
    [labelCoin setText:[NSString stringWithFormat:@"%d",[ImagesModel sharedModel].coins]];
   
    [labelLevel setText:[NSString stringWithFormat:@"%d", [[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex]+1]];
    
    float level = [[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex];
    float totallevel = [[ImagesModel sharedModel] numberOfAllPicsInPackage:[ImagesModel sharedModel].currentPackageIndex];
    float scale = level/totallevel;
    [imageLevelRed setFrame:CGRectMake(195, 12, 125.0*scale, 30)];
}
-(void) shareFb{
   SLComposeViewController *vc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
   [vc addImage:current.packedImage];
   [vc setInitialText:NSLocalizedString(@"FBhelp", nil)];
   [self presentViewController:vc animated:YES completion:nil];
}
-(void) didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
