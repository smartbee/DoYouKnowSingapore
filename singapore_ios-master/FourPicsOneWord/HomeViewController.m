//
//  HomeViewController.m
//  FourPicsOneWord
//
//  Created by  on 10/14/13.
//  Copyright (c) 2013 Vojtec. All rights reserved.
//

#import "HomeViewController.h"
#import "SettingsViewController.h"
#import "PlayViewController.h"
#import "GetPremiumViewController.h"
#import "ImagesModel.h"
#import "Chartboost.h"
//#import <iAd/iAd.h>
#import <AdColony/AdColony.h>


@interface HomeViewController () </*ADBannerViewDelegate, */UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource, SKProductsRequestDelegate>{
    
   UILabel *numAnsweredLabel;
   NSTimer *timer;

   UIImageView *bgImgView;
   UIImageView *currentImageView;
   UIButton *playBtn;


   UIImageView *swipe_next_bgImgView;
   UIImageView *swipe_next_currentImageView;
   UIButton *swipe_next_playBtn;

   UIImageView *swipe_prev_bgImgView;
   UIImageView *swipe_prev_currentImageView;
   UIButton *swipe_prev_playBtn;

   NSArray *productIds;
    
}

-(void)nextPack;
-(void)previousPack;

@end

@implementation HomeViewController

#pragma mark  - Init
-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
       self.title = NSLocalizedString(@"AppName", nil);
    }
    return self;
}
-(float)topOffset{
   float offset = 0;
   if ([self respondsToSelector:@selector(topLayoutGuide)]) {
//      offset = self.topLayoutGuide.length;
//      NSLog(@"offset");
//      offset = 45;
      offset = 0;
   }
   return offset;
}

#pragma mark - Main Init
-(void)viewDidLoad{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.

   self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStylePlain target:nil action:nil];
   if ([[UIDevice currentDevice].systemVersion floatValue] < 7) {
//      [[UIBarButtonItem appearance] performSelector:@selector(setTextColor:) withObject:[UIColor blackColor]];
      [[UIBarButtonItem appearance] setTintColor:[UIColor blackColor]];
//      [[UIBarButtonItem appearance] setTitleTextAttributes:@{UITextAttributeTextColor: [UIColor blackColor]} forState:UIControlStateNormal];
   }

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    imageView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:imageView];
   if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
      [imageView setImage:[UIImage imageNamed:@"backgroundipad.png"]];
   } else {
       if (self.view.frame.size.height == 480) {
           [imageView setImage:[UIImage imageNamed:@"bg.png"]];
       }else{
           [imageView setImage:[UIImage imageNamed:@"bg5.png"]];
       }
   }

   [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"topbar.png"] forBarMetrics:UIBarMetricsDefault];
   [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
   self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};

   UIButton *settingsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//   [settingsBtn setTitle:@"Settings" forState:UIControlStateNormal];
   [settingsBtn setImage:[UIImage imageNamed:@"settingsBtn.png"] forState:UIControlStateNormal];
   settingsBtn.frame = CGRectMake(0.0, 0.0, 20, 20);
   [settingsBtn addTarget:self action:@selector(showSettings) forControlEvents:UIControlEventTouchUpInside];
   UIBarButtonItem *bi = [[UIBarButtonItem alloc]
                          initWithCustomView:settingsBtn];
   self.navigationItem.rightBarButtonItem = bi;

   UIImageView *badgeView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0f - 30.0f, 50.0f-45.0f+[self topOffset], 60.0f, 60.0f)];
   badgeView.image = [UIImage imageNamed:@"badge.png"];
//   [self.view addSubview:badgeView];

   numAnsweredLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0f - 20.0f, 60.0f-45.0f+[self topOffset], 40.0f, 40.0f)];
//   numAnsweredLabel.text = [NSString stringWithFormat:@"%d/%d", [ImagesModel sharedModel].currentWordIndex+1, [ImagesModel sharedModel].numberOfAllPics];
   numAnsweredLabel.text = [NSString stringWithFormat:@"%d/%d", [[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex]+1, [[ImagesModel sharedModel] numberOfAllPicsInPackage:[ImagesModel sharedModel].currentPackageIndex]];
   numAnsweredLabel.textColor = [UIColor whiteColor];
   numAnsweredLabel.textAlignment = NSTextAlignmentCenter;
   numAnsweredLabel.backgroundColor = [UIColor clearColor];
//   [self.view addSubview:numAnsweredLabel];

   bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 110-45.0f+[self topOffset], self.view.frame.size.width-100, self.view.frame.size.width-120)];
   bgImgView.image = [UIImage imageNamed:@"startBGImage.png"];
//   [self.view addSubview:bgImgView];

//   PicsAndWord* current = [[ImagesModel sharedModel] picsAndWordForID:[ImagesModel sharedModel].currentWordIndex];
   PicsAndWord* current = [[ImagesModel sharedModel] picsAndWordForID:[[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex] inPackage:[ImagesModel sharedModel].currentPackageIndex];
   currentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(70, 130-45.0f+[self topOffset], self.view.frame.size.width-140, self.view.frame.size.width-160)];
   currentImageView.image = current.packedImage;
   currentImageView.userInteractionEnabled = YES;
//   [self.view addSubview:currentImageView];

   playBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0f - 80.0f, 110.0f + (self.view.frame.size.width-160)/2.0f-45.0f+[self topOffset], 160.0f, 40.0f)];
   [playBtn addTarget:self action:@selector(startPlay) forControlEvents:UIControlEventTouchUpInside];
   [playBtn setBackgroundImage:[UIImage imageNamed:@"button1.png"] forState:UIControlStateNormal];
//   [self.view addSubview:playBtn];

   if ([[ImagesModel sharedModel] wordIsUnlocked:[[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex] inPackage:[ImagesModel sharedModel].currentPackageIndex]) {
      if (([[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex] == [[ImagesModel sharedModel] numberOfAllPicsInPackage:[ImagesModel sharedModel].currentPackageIndex] -1) &&
          ([[ImagesModel sharedModel] isWon:[[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex] inPackage:[ImagesModel sharedModel].currentPackageIndex]))
      {
         [playBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"RePlay", nil), [ImagesModel sharedModel].currentPackageIndex+1] forState:UIControlStateNormal];
      } else {
         [playBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"StartPlay", nil), [ImagesModel sharedModel].currentPackageIndex+1] forState:UIControlStateNormal];
      }
      [playBtn setBackgroundImage:[UIImage imageNamed:@"button1.png"] forState:UIControlStateNormal];
   } else {
      [playBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"Unlock", nil), [ImagesModel sharedModel].currentPackageIndex+1] forState:UIControlStateNormal];
      [playBtn setBackgroundImage:[UIImage imageNamed:@"button4.png"] forState:UIControlStateNormal];
   }

   UIPanGestureRecognizer *rec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
   [currentImageView addGestureRecognizer:rec];


   UIButton *prevBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 130-45.0f+[self topOffset] + (self.view.frame.size.width-160)/2.0f-25, 50, 50)];
   [prevBtn setTitle:@"<" forState:UIControlStateNormal];
   prevBtn.titleLabel.font = [UIFont systemFontOfSize:25];
   [prevBtn addTarget:self action:@selector(previousPack) forControlEvents:UIControlEventTouchUpInside];
//   [self.view addSubview:prevBtn];

   UIButton *nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 50, 130-45.0f+[self topOffset] + (self.view.frame.size.width-160)/2.0f-25, 50, 50)];
   [nextBtn setTitle:@">" forState:UIControlStateNormal];
   nextBtn.titleLabel.font = [UIFont systemFontOfSize:25];
   [nextBtn addTarget:self action:@selector(nextPack) forControlEvents:UIControlEventTouchUpInside];
//   [self.view addSubview:nextBtn];



   PicsAndWord *next = [[ImagesModel sharedModel] picsAndWordForID:[[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex+1] inPackage:[ImagesModel sharedModel].currentPackageIndex+1];
   if (next) {
      swipe_next_bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width + 50, 110-45.0f+[self topOffset], self.view.frame.size.width-100, self.view.frame.size.width-120)];
      swipe_next_bgImgView.image = [UIImage imageNamed:@"startBGImage.png"];
//      [self.view addSubview:swipe_next_bgImgView];

      swipe_next_currentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width + 70, 130-45.0f+[self topOffset], self.view.frame.size.width-140, self.view.frame.size.width-160)];
      swipe_next_currentImageView.image = next.packedImage;
//      [self.view addSubview:swipe_next_currentImageView];

      swipe_next_playBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width + self.view.frame.size.width/2.0f - 40.0f, 110.0f + (self.view.frame.size.width-160)/2.0f-45.0f+[self topOffset], 80.0f, 40.0f)];
      [swipe_next_playBtn addTarget:self action:@selector(startPlay) forControlEvents:UIControlEventTouchUpInside];
      [swipe_next_playBtn setBackgroundImage:[UIImage imageNamed:@"button1.png"] forState:UIControlStateNormal];
//      [self.view addSubview:swipe_next_playBtn];

      if ([[ImagesModel sharedModel] wordIsUnlocked:[[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex+1] inPackage:[ImagesModel sharedModel].currentPackageIndex+1]) {


         if (([[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex+1] == [[ImagesModel sharedModel] numberOfAllPicsInPackage:[ImagesModel sharedModel].currentPackageIndex+1] -1) &&
             ([[ImagesModel sharedModel] isWon:[[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex+1] inPackage:[ImagesModel sharedModel].currentPackageIndex+1]))
         {
            [swipe_next_playBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"RePlay", nil), [ImagesModel sharedModel].currentPackageIndex+2] forState:UIControlStateNormal];
         } else {
            [swipe_next_playBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"StartPlay", nil), [ImagesModel sharedModel].currentPackageIndex+2] forState:UIControlStateNormal];
         }
         [swipe_next_playBtn setBackgroundImage:[UIImage imageNamed:@"button1.png"] forState:UIControlStateNormal];
      } else {
         [swipe_next_playBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"Unlock", nil), [ImagesModel sharedModel].currentPackageIndex+2] forState:UIControlStateNormal];
         [playBtn setBackgroundImage:[UIImage imageNamed:@"button4.png"] forState:UIControlStateNormal];
      }
   }

   PicsAndWord *previous = [[ImagesModel sharedModel] picsAndWordForID:[[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex-1] inPackage:[ImagesModel sharedModel].currentPackageIndex-1];
   if (previous) {
      swipe_prev_bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(-self.view.frame.size.width + 50, 110-45.0f+[self topOffset], self.view.frame.size.width-100, self.view.frame.size.width-120)];
      swipe_prev_bgImgView.image = [UIImage imageNamed:@"startBGImage.png"];
//      [self.view addSubview:swipe_prev_bgImgView];

      swipe_prev_currentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-self.view.frame.size.width + 70, 130-45.0f+[self topOffset], self.view.frame.size.width-140, self.view.frame.size.width-160)];
      swipe_prev_currentImageView.image = previous.packedImage;
//      [self.view addSubview:swipe_prev_currentImageView];

      swipe_prev_playBtn = [[UIButton alloc] initWithFrame:CGRectMake(-self.view.frame.size.width + self.view.frame.size.width/2.0f - 40.0f, 110.0f + (self.view.frame.size.width-160)/2.0f-45.0f+[self topOffset], 80.0f, 40.0f)];
      [swipe_prev_playBtn setTitle:NSLocalizedString(@"StartPlay", nil) forState:UIControlStateNormal];
      [swipe_prev_playBtn setBackgroundImage:[UIImage imageNamed:@"button1.png"] forState:UIControlStateNormal];
//      [self.view addSubview:swipe_prev_playBtn];

      if ([[ImagesModel sharedModel] wordIsUnlocked:[[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex-1] inPackage:[ImagesModel sharedModel].currentPackageIndex-1]) {



         if (([[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex-1] == [[ImagesModel sharedModel] numberOfAllPicsInPackage:[ImagesModel sharedModel].currentPackageIndex-1] -1) &&
             ([[ImagesModel sharedModel] isWon:[[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex-1] inPackage:[ImagesModel sharedModel].currentPackageIndex-1]))
         {
            [swipe_prev_playBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"RePlay", nil), [ImagesModel sharedModel].currentPackageIndex] forState:UIControlStateNormal];
         } else {
            [swipe_prev_playBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"StartPlay", nil), [ImagesModel sharedModel].currentPackageIndex] forState:UIControlStateNormal];
         }

         [swipe_prev_playBtn setBackgroundImage:[UIImage imageNamed:@"button1.png"] forState:UIControlStateNormal];
      } else {
         [swipe_prev_playBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"Unlock", nil), [ImagesModel sharedModel].currentPackageIndex] forState:UIControlStateNormal];
         [swipe_prev_playBtn setBackgroundImage:[UIImage imageNamed:@"button4.png"] forState:UIControlStateNormal];
      }
   }


   UILabel *leftTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0f - 150.0f, [self topOffset]+self.view.frame.size.width-55.0f, 300, 20)];
   leftTimeLabel.textAlignment = NSTextAlignmentCenter;
   leftTimeLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
   leftTimeLabel.textColor = [UIColor whiteColor];
   leftTimeLabel.tag = 312;
   leftTimeLabel.backgroundColor = [UIColor clearColor];
   [self update];
//   [self.view addSubview:leftTimeLabel];

   UIButton *bonusBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0f-150.0f, [self topOffset]+self.view.frame.size.width-55.0f, 300, 60)];
   [bonusBtn setTitle:NSLocalizedString(@"BonusChallenge", nil) forState:UIControlStateNormal];
   [bonusBtn addTarget:self action:@selector(startBonus) forControlEvents:UIControlEventTouchUpInside];
   [bonusBtn setBackgroundImage:[UIImage imageNamed:@"button2.png"] forState:UIControlStateNormal];
   bonusBtn.tag = 313;
//   [self.view addSubview:bonusBtn];

   if (kBonusTime - [[NSDate date] timeIntervalSinceDate:[ImagesModel sharedModel].lastAnsweredBonusDate] > 0) {
      leftTimeLabel.hidden = NO;
      bonusBtn.hidden = YES;
   } else {
      leftTimeLabel.hidden = YES;
      bonusBtn.hidden = NO;
   }

   if ([ImagesModel sharedModel].numberOfAllBonuses == [ImagesModel sharedModel].numberOfBonusAnswered) {
      bonusBtn.hidden = YES;
      leftTimeLabel.hidden = YES;
   }
    int widthSpace;
    if (self.view.frame.size.height == 480) {
        widthSpace = 50;
    }else{
        widthSpace = 60;
    }

    
    UIButton *buttonPlay = [[UIButton alloc] initWithFrame:CGRectMake(75, self.view.frame.size.height - 100 - 3* widthSpace, 170.0f, 42.0f)];
    //[moreGamesBtn setTitle:NSLocalizedString(@"MoreGames", nil) forState:UIControlStateNormal];
    buttonPlay.titleLabel.font = [UIFont systemFontOfSize:12];
    [buttonPlay setBackgroundImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    [buttonPlay addTarget:self action:@selector(startPlay) forControlEvents:UIControlEventTouchUpInside];
    //   [moreGamesBtn.titleLabel setTextAlignment:NSTextAlignmentNatural];
    buttonPlay.tag = 112;
    buttonPlay.hidden = [ImagesModel sharedModel].premium;
    [self.view addSubview:buttonPlay];

    UIButton *buttonFacebook = [[UIButton alloc] initWithFrame:CGRectMake(75, self.view.frame.size.height - 100 - 2* widthSpace, 170.0f, 42.0f)];
    //[moreGamesBtn setTitle:NSLocalizedString(@"MoreGames", nil) forState:UIControlStateNormal];
    buttonFacebook.titleLabel.font = [UIFont systemFontOfSize:12];
    [buttonFacebook setBackgroundImage:[UIImage imageNamed:@"facebook.png"] forState:UIControlStateNormal];
//    [buttonFacebook addTarget:self action:@selector(moreGames) forControlEvents:UIControlEventTouchUpInside];
    //   [moreGamesBtn.titleLabel setTextAlignment:NSTextAlignmentNatural];
    buttonFacebook.tag = 113;
    buttonFacebook.hidden = [ImagesModel sharedModel].premium;
    [self.view addSubview:buttonFacebook];


   UIButton *hideAdsBtn = [[UIButton alloc] initWithFrame:CGRectMake(5, [self topOffset]+self.view.frame.size.width, 160.0f, 60.0f)];
   //[hideAdsBtn setTitle:NSLocalizedString(@"HideAds", nil) forState:UIControlStateNormal];
   hideAdsBtn.titleLabel.font = [UIFont systemFontOfSize:12];
   [hideAdsBtn setBackgroundImage:[UIImage imageNamed:@"removeAdd.png"] forState:UIControlStateNormal];
   [hideAdsBtn addTarget:self action:@selector(getPremium) forControlEvents:UIControlEventTouchUpInside];
   hideAdsBtn.tag = 1011;
   hideAdsBtn.hidden = [ImagesModel sharedModel].premium;
//   [self.view addSubview:hideAdsBtn];

//   if (![ImagesModel sharedModel].premium) {
//      ADBannerView *adBanner = [[ADBannerView alloc] initWithFrame:CGRectZero];
//      adBanner.tag = 101;
//      adBanner.delegate = self;
//      adBanner.hidden = YES;
//      [self.view addSubview:adBanner];
//
//      adBanner.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, adBanner.frame.size.height);
//   }

   UIButton *videoBtn = [[UIButton alloc] initWithFrame:CGRectMake(75, self.view.frame.size.height - 100 - 1* widthSpace, 170.0f, 42.0f)];
//   [videoBtn setTitle:NSLocalizedString(@"EarnCoins", nil) forState:UIControlStateNormal];
//   videoBtn.backgroundColor = [UIColor redColor];
   [videoBtn setImage:[UIImage imageNamed:@"getcoin.png"] forState:UIControlStateNormal];
   [videoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
   [videoBtn addTarget:self action:@selector(watchVideo) forControlEvents:UIControlEventTouchUpInside];
   [self.view addSubview:videoBtn];

    UIButton *moreGamesBtn = [[UIButton alloc] initWithFrame:CGRectMake(75,  self.view.frame.size.height - 100 - 0* widthSpace, 170.0f, 42.0f)];
    //[moreGamesBtn setTitle:NSLocalizedString(@"MoreGames", nil) forState:UIControlStateNormal];
    moreGamesBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [moreGamesBtn setBackgroundImage:[UIImage imageNamed:@"moreapp.png"] forState:UIControlStateNormal];
    [moreGamesBtn addTarget:self action:@selector(moreGames) forControlEvents:UIControlEventTouchUpInside];
    //   [moreGamesBtn.titleLabel setTextAlignment:NSTextAlignmentNatural];
    moreGamesBtn.tag = 1010;
    moreGamesBtn.hidden = [ImagesModel sharedModel].premium;
    [self.view addSubview:moreGamesBtn];
    

    UIButton *buttonFacebookLeft = [[UIButton alloc] initWithFrame:CGRectMake(5,  5, 40.0f, 40.0f)];
    //[moreGamesBtn setTitle:NSLocalizedString(@"MoreGames", nil) forState:UIControlStateNormal];
    buttonFacebookLeft.titleLabel.font = [UIFont systemFontOfSize:12];
    [buttonFacebookLeft setBackgroundImage:[UIImage imageNamed:@"facebookleft.png"] forState:UIControlStateNormal];
//    [buttonFacebookLeft addTarget:self action:@selector(moreGames) forControlEvents:UIControlEventTouchUpInside];
    //   [moreGamesBtn.titleLabel setTextAlignment:NSTextAlignmentNatural];
    buttonFacebookLeft.tag = 1010;
    buttonFacebookLeft.hidden = [ImagesModel sharedModel].premium;
    [self.view addSubview:buttonFacebookLeft];

    UIButton *buttonTwitterRight = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 5 -40 , 5 , 40.0f, 40.0f)];
    //[moreGamesBtn setTitle:NSLocalizedString(@"MoreGames", nil) forState:UIControlStateNormal];
    buttonTwitterRight.titleLabel.font = [UIFont systemFontOfSize:12];
    [buttonTwitterRight setBackgroundImage:[UIImage imageNamed:@"twitterright.png"] forState:UIControlStateNormal];
//    [buttonTwitterRight addTarget:self action:@selector(moreGames) forControlEvents:UIControlEventTouchUpInside];
    //   [moreGamesBtn.titleLabel setTextAlignment:NSTextAlignmentNatural];
    buttonTwitterRight.tag = 1010;
    buttonTwitterRight.hidden = [ImagesModel sharedModel].premium;
    [self.view addSubview:buttonTwitterRight];

    UIButton *buttonShare = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 35)/2, self.view.frame.size.height - 35 -10 , 35.0f, 35.0f)];
    //[moreGamesBtn setTitle:NSLocalizedString(@"MoreGames", nil) forState:UIControlStateNormal];
    buttonShare.titleLabel.font = [UIFont systemFontOfSize:12];
    [buttonShare setBackgroundImage:[UIImage imageNamed:@"share.png"] forState:UIControlStateNormal];
//    [buttonShare addTarget:self action:@selector(moreGames) forControlEvents:UIControlEventTouchUpInside];
    //   [moreGamesBtn.titleLabel setTextAlignment:NSTextAlignmentNatural];
    buttonShare.tag = 1010;
    buttonShare.hidden = [ImagesModel sharedModel].premium;
    [self.view addSubview:buttonShare];
    
    UIButton *buttonSound = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width + 35)/2 + 20 , self.view.frame.size.height - 35 -10 , 35.0f, 35.0f)];
    //[moreGamesBtn setTitle:NSLocalizedString(@"MoreGames", nil) forState:UIControlStateNormal];
    buttonSound.titleLabel.font = [UIFont systemFontOfSize:12];
    [buttonSound setBackgroundImage:[UIImage imageNamed:@"soundoff.png"] forState:UIControlStateNormal];
    [buttonSound setBackgroundImage:[UIImage imageNamed:@"soundon.png"] forState:UIControlStateSelected];
    [buttonSound addTarget:self action:@selector(sound) forControlEvents:UIControlEventTouchUpInside];
    //   [moreGamesBtn.titleLabel setTextAlignment:NSTextAlignmentNatural];
    buttonSound.tag = 1019;
    buttonSound.hidden = [ImagesModel sharedModel].premium;
    [self.view addSubview:buttonSound];
    

//   UIGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
//   [currentImageView addGestureRecognizer:swipe];
}
-(void) sound{
    UIButton *buttonSound = (UIButton*) [self.view viewWithTag:1019];
    [buttonSound setSelected:!buttonSound.selected];
}
-(void)watchVideo{
   [AdColony playVideoAdForZone:[[NSBundle mainBundle] infoDictionary][@"AdColonyZoneID"]
                   withDelegate:nil
               withV4VCPrePopup:YES
               andV4VCPostPopup:YES];
}
//-(void)swipe:(UISwipeGestureRecognizer*)rec
//{
//   if (rec.direction == UISwipeGestureRecognizerDirectionLeft) {
//      [self previousWord];
//   } else if (rec.direction == UISwipeGestureRecognizerDirectionLeft) {
//      [self nextWord];
//   }
//}
-(void)handlePan:(UIPanGestureRecognizer *)gesture{
   CGPoint translate = [gesture translationInView:self.view];
   translate.y = 0.0;

   swipe_prev_bgImgView.frame = CGRectMake(50-self.view.frame.size.width + translate.x, 110-45.0f+[self topOffset], self.view.frame.size.width-100, self.view.frame.size.width-120);
   swipe_prev_currentImageView.frame = CGRectMake(70-self.view.frame.size.width + translate.x, 130-45.0f+[self topOffset], self.view.frame.size.width-140, self.view.frame.size.width-160);
   swipe_prev_playBtn.frame = CGRectMake(self.view.frame.size.width/2.0f - 80.0f-self.view.frame.size.width + translate.x, 110.0f + (self.view.frame.size.width-160)/2.0f-45.0f+[self topOffset], 160.0f, 40.0f);


   bgImgView.frame = CGRectMake(50+translate.x, 110-45.0f+[self topOffset], self.view.frame.size.width-100, self.view.frame.size.width-120);
   currentImageView.frame = CGRectMake(70+translate.x, 130-45.0f+[self topOffset], self.view.frame.size.width-140, self.view.frame.size.width-160);
   playBtn.frame = CGRectMake(self.view.frame.size.width/2.0f - 80.0f+translate.x, 110.0f + (self.view.frame.size.width-160)/2.0f-45.0f+[self topOffset], 160.0f, 40.0f);


   swipe_next_bgImgView.frame = CGRectMake(50+self.view.frame.size.width + translate.x, 110-45.0f+[self topOffset], self.view.frame.size.width-100, self.view.frame.size.width-120);
   swipe_next_currentImageView.frame = CGRectMake(70+self.view.frame.size.width + translate.x, 130-45.0f+[self topOffset], self.view.frame.size.width-140, self.view.frame.size.width-160);
   swipe_next_playBtn.frame = CGRectMake(self.view.frame.size.width/2.0f - 80.0f+self.view.frame.size.width + translate.x, 110.0f + (self.view.frame.size.width-160)/2.0f-45.0f+[self topOffset], 160.0f, 40.0f);

//   CGRect frame = lastFactView.frame;
//   lastFactView.frame = CGRectMake(10 - self.view.frame.size.width + translate.x, 90, self.view.frame.size.width - 20, 240);
//   frame = factView.frame;
//   factView.frame = CGRectMake(10 + translate.x, 90, self.view.frame.size.width - 20, 240);
//   frame = nextFactView.frame;
//   nextFactView.frame = CGRectMake(10 + self.view.frame.size.width + translate.x, 90, self.view.frame.size.width - 20, 240);
//
   if (gesture.state == UIGestureRecognizerStateCancelled ||
       gesture.state == UIGestureRecognizerStateEnded ||
       gesture.state == UIGestureRecognizerStateFailed)
   {
      CGPoint velocity = [gesture velocityInView:gesture.view];
      if (translate.x > 0.0 && (translate.x + velocity.x * 0.25) > (gesture.view.bounds.size.width / 2.0) && [[ImagesModel sharedModel] picsAndWordForID:[[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex-1] inPackage:[ImagesModel sharedModel].currentPackageIndex-1]) {
         [self previousPack];
      } else if (translate.x < 0.0 && (translate.x + velocity.x * 0.25) < -(gesture.view.frame.size.width / 2.0) && [[ImagesModel sharedModel] picsAndWordForID:[[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex+1] inPackage:[ImagesModel sharedModel].currentPackageIndex+1]) {
         [self nextPack];
      } else {
         [UIView animateWithDuration:0.1 animations:^(void) {
            swipe_prev_bgImgView.frame = CGRectMake(50-self.view.frame.size.width, 110-45.0f+[self topOffset], self.view.frame.size.width-100, self.view.frame.size.width-120);
            swipe_prev_currentImageView.frame = CGRectMake(70-self.view.frame.size.width, 130-45.0f+[self topOffset], self.view.frame.size.width-140, self.view.frame.size.width-160);
            swipe_prev_playBtn.frame = CGRectMake(self.view.frame.size.width/2.0f - 80.0f-self.view.frame.size.width, 110.0f + (self.view.frame.size.width-160)/2.0f-45.0f+[self topOffset], 160.0f, 40.0f);


            bgImgView.frame = CGRectMake(50, 110-45.0f+[self topOffset], self.view.frame.size.width-100, self.view.frame.size.width-120);
            currentImageView.frame = CGRectMake(70, 130-45.0f+[self topOffset], self.view.frame.size.width-140, self.view.frame.size.width-160);
            playBtn.frame = CGRectMake(self.view.frame.size.width/2.0f - 80.0f, 110.0f + (self.view.frame.size.width-160)/2.0f-45.0f+[self topOffset], 160.0f, 40.0f);


            swipe_next_bgImgView.frame = CGRectMake(50+self.view.frame.size.width, 110-45.0f+[self topOffset], self.view.frame.size.width-100, self.view.frame.size.width-120);
            swipe_next_currentImageView.frame = CGRectMake(70+self.view.frame.size.width, 130-45.0f+[self topOffset], self.view.frame.size.width-140, self.view.frame.size.width-160);
            swipe_next_playBtn.frame = CGRectMake(self.view.frame.size.width/2.0f - 80.0f+self.view.frame.size.width, 110.0f + (self.view.frame.size.width-160)/2.0f-45.0f+[self topOffset], 160.0f, 40.0f);
         }];
//         [UIView beginAnimations:@"next-fact" context:nil];
//
//         lastFactView.frame = CGRectMake(10 - self.view.frame.size.width, 90, self.view.frame.size.width - 20, 240);
//         nextFactView.frame = CGRectMake(10 + self.view.frame.size.width, 90, self.view.frame.size.width - 20, 240);
//         factView.frame = CGRectMake(10, 90, self.view.frame.size.width - 20, 240);
//
//         [UIView commitAnimations];
//         fact = [[Model sharedModel] nextFactForFact:fact];
      }
   }
}
//-(void)bannerViewDidLoadAd:(ADBannerView *)banner
//{
//   [UIView beginAnimations:@"ViewBanner" context:nil];
//   banner.hidden = NO;
//   float bannerheight = banner.frame.size.height;
//   banner.frame = CGRectMake(0, self.view.frame.size.height - bannerheight, self.view.frame.size.width, bannerheight);
//
//   [UIView commitAnimations];
//}
//
//-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
//{
//   float bannerheight = banner.frame.size.height;
//   banner.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, bannerheight);
//   banner.hidden = YES;
//}
//
//-(BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
//{
//   return YES;
//}

#pragma mark - Appear Function
-(void) viewWillAppear:(BOOL)animated{
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAds) name:@"updatedCoinsAndPremium" object:nil];
   [self updateAds];

//   if ([ImagesModel sharedModel].numberOfAnswered >= [ImagesModel sharedModel].numberOfAllPics) {
//      //what happens now?
//   }
//   numAnsweredLabel.text = [NSString stringWithFormat:@"%d/%d", [[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex]+1, [[ImagesModel sharedModel] numberOfAllPicsInPackage:[ImagesModel sharedModel].currentPackageIndex]];
//
//
//   [bgImgView removeFromSuperview];
//   [currentImageView removeFromSuperview];
//   [playBtn removeFromSuperview];
//
//   [swipe_prev_bgImgView removeFromSuperview];
//   [swipe_prev_currentImageView removeFromSuperview];
//   [swipe_prev_playBtn removeFromSuperview];
//
//   [swipe_next_bgImgView removeFromSuperview];
//   [swipe_next_currentImageView removeFromSuperview];
//   [swipe_next_playBtn removeFromSuperview];
//
//
//
//   bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 110-45.0f+[self topOffset], self.view.frame.size.width-100, self.view.frame.size.width-120)];
//   bgImgView.image = [UIImage imageNamed:@"startBGImage.png"];
////   [self.view addSubview:bgImgView];
//
//   PicsAndWord* current = [[ImagesModel sharedModel] picsAndWordForID:[[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex] inPackage:[ImagesModel sharedModel].currentPackageIndex];
//   currentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(70, 130-45.0f+[self topOffset], self.view.frame.size.width-140, self.view.frame.size.width-160)];
//   currentImageView.image = current.packedImage;
//   currentImageView.userInteractionEnabled = YES;
////   [self.view addSubview:currentImageView];
//
//   playBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0f - 80.0f, 110.0f + (self.view.frame.size.width-160)/2.0f-45.0f+[self topOffset], 160.0f, 40.0f)];
//   [playBtn addTarget:self action:@selector(startPlay) forControlEvents:UIControlEventTouchUpInside];
//   [playBtn setBackgroundImage:[UIImage imageNamed:@"button1.png"] forState:UIControlStateNormal];
//   [self.view addSubview:playBtn];
//
//   if ([[ImagesModel sharedModel] wordIsUnlocked:[[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex] inPackage:[ImagesModel sharedModel].currentPackageIndex]) {
//
//
//
//      if (([[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex] == [[ImagesModel sharedModel] numberOfAllPicsInPackage:[ImagesModel sharedModel].currentPackageIndex] -1) &&
//          ([[ImagesModel sharedModel] isWon:[[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex] inPackage:[ImagesModel sharedModel].currentPackageIndex]))
//      {
//         [playBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"RePlay", nil), [ImagesModel sharedModel].currentPackageIndex+1] forState:UIControlStateNormal];
//      } else {
//         [playBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"StartPlay", nil), [ImagesModel sharedModel].currentPackageIndex+1] forState:UIControlStateNormal];
//      }
//
//      [playBtn setBackgroundImage:[UIImage imageNamed:@"button1.png"] forState:UIControlStateNormal];
//   } else {
//      [playBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"Unlock", nil), [ImagesModel sharedModel].currentPackageIndex+1] forState:UIControlStateNormal];
//      [playBtn setBackgroundImage:[UIImage imageNamed:@"button4.png"] forState:UIControlStateNormal];
//   }
//
//   UIPanGestureRecognizer *rec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
//   [currentImageView addGestureRecognizer:rec];
//
//   PicsAndWord *next = [[ImagesModel sharedModel] picsAndWordForID:[[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex+1] inPackage:[ImagesModel sharedModel].currentPackageIndex+1];
//   if (next) {
//      swipe_next_bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width + 50, 110-45.0f+[self topOffset], self.view.frame.size.width-100, self.view.frame.size.width-120)];
//      swipe_next_bgImgView.image = [UIImage imageNamed:@"startBGImage.png"];
//      [self.view addSubview:swipe_next_bgImgView];
//
//      swipe_next_currentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width + 70, 130-45.0f+[self topOffset], self.view.frame.size.width-140, self.view.frame.size.width-160)];
//      swipe_next_currentImageView.image = next.packedImage;
//      [self.view addSubview:swipe_next_currentImageView];
//
//      swipe_next_playBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width + self.view.frame.size.width/2.0f - 80.0f, 110.0f + (self.view.frame.size.width-160)/2.0f-45.0f+[self topOffset], 160.0f, 40.0f)];
//      [swipe_next_playBtn addTarget:self action:@selector(startPlay) forControlEvents:UIControlEventTouchUpInside];
//      [swipe_next_playBtn setBackgroundImage:[UIImage imageNamed:@"button1.png"] forState:UIControlStateNormal];
//      [self.view addSubview:swipe_next_playBtn];
//
//      if ([[ImagesModel sharedModel] wordIsUnlocked:[[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex+1] inPackage:[ImagesModel sharedModel].currentPackageIndex+1]) {
//
//
//
//
//         if (([[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex+1] == [[ImagesModel sharedModel] numberOfAllPicsInPackage:[ImagesModel sharedModel].currentPackageIndex+1] -1) &&
//             ([[ImagesModel sharedModel] isWon:[[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex+1] inPackage:[ImagesModel sharedModel].currentPackageIndex+1]))
//         {
//            [swipe_next_playBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"RePlay", nil), [ImagesModel sharedModel].currentPackageIndex+2] forState:UIControlStateNormal];
//         } else {
//            [swipe_next_playBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"StartPlay", nil), [ImagesModel sharedModel].currentPackageIndex+2] forState:UIControlStateNormal];
//         }
//
//
//         [swipe_next_playBtn setBackgroundImage:[UIImage imageNamed:@"button1.png"] forState:UIControlStateNormal];
//
////         [swipe_next_playBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"StartPlay", nil), [ImagesModel sharedModel].currentPackageIndex+2] forState:UIControlStateNormal];
//      } else {
//         [swipe_next_playBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"Unlock", nil), [ImagesModel sharedModel].currentPackageIndex+2] forState:UIControlStateNormal];
//         [swipe_next_playBtn setBackgroundImage:[UIImage imageNamed:@"button4.png"] forState:UIControlStateNormal];
//      }
//   }
//
//
//
//   PicsAndWord *previous = [[ImagesModel sharedModel] picsAndWordForID:[[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex-1] inPackage:[ImagesModel sharedModel].currentPackageIndex-1];
//   if (previous) {
//      swipe_prev_bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(-self.view.frame.size.width + 50, 110-45.0f+[self topOffset], self.view.frame.size.width-100, self.view.frame.size.width-120)];
//      swipe_prev_bgImgView.image = [UIImage imageNamed:@"startBGImage.png"];
//      [self.view addSubview:swipe_prev_bgImgView];
//
//      swipe_prev_currentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-self.view.frame.size.width + 70, 130-45.0f+[self topOffset], self.view.frame.size.width-140, self.view.frame.size.width-160)];
//      swipe_prev_currentImageView.image = previous.packedImage;
//      [self.view addSubview:swipe_prev_currentImageView];
//
//      swipe_prev_playBtn = [[UIButton alloc] initWithFrame:CGRectMake(-self.view.frame.size.width + self.view.frame.size.width/2.0f - 80.0f, 110.0f + (self.view.frame.size.width-160)/2.0f-45.0f+[self topOffset], 160.0f, 40.0f)];
//      [swipe_prev_playBtn addTarget:self action:@selector(startPlay) forControlEvents:UIControlEventTouchUpInside];
//      [swipe_prev_playBtn setBackgroundImage:[UIImage imageNamed:@"button1.png"] forState:UIControlStateNormal];
//      [self.view addSubview:swipe_prev_playBtn];
//
//      if ([[ImagesModel sharedModel] wordIsUnlocked:[[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex-1] inPackage:[ImagesModel sharedModel].currentPackageIndex-1]) {
//
//
//
//         if (([[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex-1] == [[ImagesModel sharedModel] numberOfAllPicsInPackage:[ImagesModel sharedModel].currentPackageIndex-1] -1) &&
//             ([[ImagesModel sharedModel] isWon:[[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex-1] inPackage:[ImagesModel sharedModel].currentPackageIndex-1]))
//         {
//
//            [swipe_prev_playBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"RePlay", nil), [ImagesModel sharedModel].currentPackageIndex] forState:UIControlStateNormal];
//         } else {
//            [swipe_prev_playBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"StartPlay", nil), [ImagesModel sharedModel].currentPackageIndex] forState:UIControlStateNormal];
//         }
//
//
//         [swipe_prev_playBtn setBackgroundImage:[UIImage imageNamed:@"button1.png"] forState:UIControlStateNormal];
//
////         [swipe_prev_playBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"StartPlay", nil), [ImagesModel sharedModel].currentPackageIndex] forState:UIControlStateNormal];
//      } else {
//         [swipe_prev_playBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"Unlock", nil), [ImagesModel sharedModel].currentPackageIndex] forState:UIControlStateNormal];
//         [swipe_prev_playBtn setBackgroundImage:[UIImage imageNamed:@"button4.png"] forState:UIControlStateNormal];
//      }
//   }
////   if ([[ImagesModel sharedModel] wordIsUnlocked:[ImagesModel sharedModel].currentWordIndex]) {
////      [playBtn setTitle:NSLocalizedString(@"StartPlay", nil) forState:UIControlStateNormal];
////   } else {
////      [playBtn setTitle:NSLocalizedString(@"Unlock", nil) forState:UIControlStateNormal];
////   }
////
////   PicsAndWord* current = [[ImagesModel sharedModel] picsAndWordForID:[ImagesModel sharedModel].currentWordIndex];
////   currentImageView.image = current.packedImage;
//
//   [self update];
//   if (kBonusTime - [[NSDate date] timeIntervalSinceDate:[ImagesModel sharedModel].lastAnsweredBonusDate]) {
//      timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(update) userInfo:nil repeats:YES];
//   }
}
-(void) viewWillDisappear:(BOOL)animated{
   [[NSNotificationCenter defaultCenter] removeObserver:self];

   if (timer) {
      [timer invalidate];
      timer = nil;
   }
}
-(void) didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) update{
   UILabel *lbl = (UILabel*) [self.view viewWithTag:312];
   UIButton *btn = (UIButton*) [self.view viewWithTag:313];
   
   int difference = kBonusTime - [[NSDate date] timeIntervalSinceDate:[ImagesModel sharedModel].lastAnsweredBonusDate];
   if (difference > 0) {
      int hours = difference / (60*60);
      int minutes = (difference - hours*60*60) / 60;
      int seconds = difference - hours*60*60 - minutes*60;

      lbl.text = [NSString stringWithFormat:@"Bonues Challenge in %02d:%02d:%02d", hours, minutes, seconds];
      lbl.hidden = NO;
      btn.hidden = YES;
   } else {
      [timer invalidate];
      timer = nil;

      lbl.hidden = YES;
      btn.hidden = NO;
   }

   if ([ImagesModel sharedModel].numberOfAllBonuses == [ImagesModel sharedModel].numberOfBonusAnswered) {
      btn.hidden = YES;
      lbl.hidden = YES;
   }
}
-(void) updateAds{
   UIView *view = [self.view viewWithTag:1010];
   view.hidden = [ImagesModel sharedModel].premium;

   view = [self.view viewWithTag:1011];
   view.hidden = [ImagesModel sharedModel].premium;

   view = [self.view viewWithTag:101];
   if (view) {
      if ([ImagesModel sharedModel].premium) {
         [view removeFromSuperview];
      }
   }
}
-(void) startPlay{
   if ([[ImagesModel sharedModel] wordIsUnlocked:[[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex] inPackage:[ImagesModel sharedModel].currentPackageIndex]) {
      if (([[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex] == [[ImagesModel sharedModel] numberOfAllPicsInPackage:[ImagesModel sharedModel].currentPackageIndex] -1) &&
          ([[ImagesModel sharedModel] isWon:[[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex] inPackage:[ImagesModel sharedModel].currentPackageIndex])) {
         [[ImagesModel sharedModel] setIndexOfCurrentWord:0 inPackage:[ImagesModel sharedModel].currentPackageIndex];
      }
      PlayViewController *vc = [[PlayViewController alloc] init];
      [self.navigationController pushViewController:vc animated:YES];
   } else {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"UnlockTitle", nil) message:NSLocalizedString(@"UnlockMessage", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"NO", nil) otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
      alert.tag = 8888;
      [alert show];
   }
}
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
   if (alertView.tag == 8888) {
      if (buttonIndex == 1) {
         if ([ImagesModel sharedModel].coins >= 4000) {
            [[ImagesModel sharedModel] payCoins:4000];
            [[ImagesModel sharedModel] unlockLevel:0 inPackage:[ImagesModel sharedModel].currentPackageIndex];
            [[ImagesModel sharedModel] setIndexOfCurrentWord:0 inPackage:[ImagesModel sharedModel].currentPackageIndex];

            if ([[ImagesModel sharedModel] wordIsUnlocked:[[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex] inPackage:[ImagesModel sharedModel].currentPackageIndex]) {
               [playBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"StartPlay", nil), [ImagesModel sharedModel].currentPackageIndex+1] forState:UIControlStateNormal];
               [playBtn setBackgroundImage:[UIImage imageNamed:@"button1.png"] forState:UIControlStateNormal];
            } else {
               [playBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"Unlock", nil), [ImagesModel sharedModel].currentPackageIndex+1] forState:UIControlStateNormal];
               [playBtn setBackgroundImage:[UIImage imageNamed:@"button4.png"] forState:UIControlStateNormal];
            }
         } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Not enough coins", nil) message:[NSString stringWithFormat:NSLocalizedString(@"Not enough coins details", nil), @(4000)] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            alert.tag = 9999;
            [alert show];
         }
      }
   } else if (alertView.tag == 9999) {
      [self getCoins];
   }
}
-(void) startBonus{
   PlayViewController *vc = [[PlayViewController alloc] initAsBonus:YES];
   [self.navigationController pushViewController:vc animated:YES];
}
-(void) showSettings{
   SettingsViewController *vc = [[SettingsViewController alloc] init];
   [self.navigationController pushViewController:vc animated:YES];
}
-(void) moreGames{
   Chartboost *cb = [Chartboost sharedChartboost];
   [cb showMoreApps];
}
-(void) getPremium{
   GetPremiumViewController *vc = [[GetPremiumViewController alloc] init];
   [self presentViewController:vc animated:YES completion:nil];
}
-(void) previousPack{
   if ([ImagesModel sharedModel].currentPackageIndex > 0) {
      [[ImagesModel sharedModel] setIndexOfCurrentWord:[[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex-1] inPackage:[ImagesModel sharedModel].currentPackageIndex-1];

      numAnsweredLabel.text = [NSString stringWithFormat:@"%d/%d", [[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel]. currentPackageIndex]+1, [[ImagesModel sharedModel] numberOfAllPicsInPackage:[ImagesModel sharedModel].currentPackageIndex]];

      UIView *tmp1 = bgImgView, *tmp2 = currentImageView, *tmp3 = playBtn;
      CGRect rect1 = bgImgView.frame, rect2 = currentImageView.frame, rect3 = playBtn.frame;

      [UIView animateWithDuration:0.2 animations:^(void)
       {
          swipe_prev_bgImgView.frame = CGRectMake(50, 110-45.0f+[self topOffset], self.view.frame.size.width-100, self.view.frame.size.width-120);
          swipe_prev_currentImageView.frame = CGRectMake(70, 130-45.0f+[self topOffset], self.view.frame.size.width-140, self.view.frame.size.width-160);
          swipe_prev_playBtn.frame = CGRectMake(self.view.frame.size.width/2.0f - 80.0f, 110.0f + (self.view.frame.size.width-160)/2.0f-45.0f+[self topOffset], 160.0f, 40.0f);

          tmp1.frame = CGRectMake(rect1.origin.x + self.view.frame.size.width, rect1.origin.y, rect1.size.width, rect1.size.height);
          tmp2.frame = CGRectMake(rect2.origin.x + self.view.frame.size.width, rect2.origin.y, rect2.size.width, rect2.size.height);
          tmp3.frame = CGRectMake(rect3.origin.x + self.view.frame.size.width, rect3.origin.y, rect3.size.width, rect3.size.height);
       } completion:^(BOOL finished){
          [tmp1 removeFromSuperview];
          [tmp2 removeFromSuperview];
          [tmp3 removeFromSuperview];
       }];

      bgImgView = swipe_prev_bgImgView;
      currentImageView = swipe_prev_currentImageView;
      playBtn = swipe_prev_playBtn;

      currentImageView.userInteractionEnabled = YES;
      UIPanGestureRecognizer *rec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
      [currentImageView addGestureRecognizer:rec];

      swipe_prev_bgImgView = nil;
      swipe_prev_currentImageView = nil;
      swipe_prev_playBtn = nil;

      PicsAndWord *previous = [[ImagesModel sharedModel] picsAndWordForID:[[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex-1] inPackage:[ImagesModel sharedModel].currentPackageIndex-1];
      if (previous) {
         swipe_prev_bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(-self.view.frame.size.width + 50, 110-45.0f+[self topOffset], self.view.frame.size.width-100, self.view.frame.size.width-120)];
         swipe_prev_bgImgView.image = [UIImage imageNamed:@"startBGImage.png"];
         [self.view addSubview:swipe_prev_bgImgView];

         swipe_prev_currentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-self.view.frame.size.width + 70, 130-45.0f+[self topOffset], self.view.frame.size.width-140, self.view.frame.size.width-160)];
         swipe_prev_currentImageView.image = previous.packedImage;
         [self.view addSubview:swipe_prev_currentImageView];

         swipe_prev_playBtn = [[UIButton alloc] initWithFrame:CGRectMake(-self.view.frame.size.width + self.view.frame.size.width/2.0f - 80.0f, 110.0f + (self.view.frame.size.width-160)/2.0f-45.0f+[self topOffset], 160.0f, 40.0f)];
         [swipe_prev_playBtn addTarget:self action:@selector(startPlay) forControlEvents:UIControlEventTouchUpInside];
         [swipe_prev_playBtn setBackgroundImage:[UIImage imageNamed:@"button1.png"] forState:UIControlStateNormal];
         [self.view addSubview:swipe_prev_playBtn];

         if ([[ImagesModel sharedModel] wordIsUnlocked:[[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex-1] inPackage:[ImagesModel sharedModel].currentPackageIndex-1]) {



            if (([[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex-1] == [[ImagesModel sharedModel] numberOfAllPicsInPackage:[ImagesModel sharedModel].currentPackageIndex-1] -1) &&
                ([[ImagesModel sharedModel] isWon:[[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex-1] inPackage:[ImagesModel sharedModel].currentPackageIndex-1]))
            {

               [swipe_prev_playBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"RePlay", nil), [ImagesModel sharedModel].currentPackageIndex] forState:UIControlStateNormal];
            } else {
               [swipe_prev_playBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"StartPlay", nil), [ImagesModel sharedModel].currentPackageIndex] forState:UIControlStateNormal];
            }



            [swipe_prev_playBtn setBackgroundImage:[UIImage imageNamed:@"button1.png"] forState:UIControlStateNormal];
//            [swipe_prev_playBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"StartPlay", nil), [ImagesModel sharedModel].currentPackageIndex] forState:UIControlStateNormal];
         } else {
            [swipe_prev_playBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"Unlock", nil), [ImagesModel sharedModel].currentPackageIndex] forState:UIControlStateNormal];
            [swipe_prev_playBtn setBackgroundImage:[UIImage imageNamed:@"button4.png"] forState:UIControlStateNormal];
         }
      }

      [swipe_next_bgImgView removeFromSuperview];
      [swipe_next_currentImageView removeFromSuperview];
      [swipe_next_playBtn removeFromSuperview];

      PicsAndWord *next = [[ImagesModel sharedModel] picsAndWordForID:[[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex+1] inPackage:[ImagesModel sharedModel].currentPackageIndex+1];
      if (next) {
         swipe_next_bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width + 50, 110-45.0f+[self topOffset], self.view.frame.size.width-100, self.view.frame.size.width-120)];
         swipe_next_bgImgView.image = [UIImage imageNamed:@"startBGImage.png"];
         [self.view addSubview:swipe_next_bgImgView];

         swipe_next_currentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width + 70, 130-45.0f+[self topOffset], self.view.frame.size.width-140, self.view.frame.size.width-160)];
         swipe_next_currentImageView.image = next.packedImage;
         [self.view addSubview:swipe_next_currentImageView];

         swipe_next_playBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width + self.view.frame.size.width/2.0f - 80.0f, 110.0f + (self.view.frame.size.width-160)/2.0f-45.0f+[self topOffset], 160.0f, 40.0f)];
         [swipe_next_playBtn addTarget:self action:@selector(startPlay) forControlEvents:UIControlEventTouchUpInside];
         [swipe_next_playBtn setBackgroundImage:[UIImage imageNamed:@"button1.png"] forState:UIControlStateNormal];
         [self.view addSubview:swipe_next_playBtn];

         if ([[ImagesModel sharedModel] wordIsUnlocked:[[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex+1] inPackage:[ImagesModel sharedModel].currentPackageIndex+1]) {




            if (([[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex+1] == [[ImagesModel sharedModel] numberOfAllPicsInPackage:[ImagesModel sharedModel].currentPackageIndex+1] -1) &&
                ([[ImagesModel sharedModel] isWon:[[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex+1] inPackage:[ImagesModel sharedModel].currentPackageIndex+1]))
            {

               [swipe_next_playBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"RePlay", nil), [ImagesModel sharedModel].currentPackageIndex+2] forState:UIControlStateNormal];
            } else {
               [swipe_next_playBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"StartPlay", nil), [ImagesModel sharedModel].currentPackageIndex+2] forState:UIControlStateNormal];
            }


            [swipe_next_playBtn setBackgroundImage:[UIImage imageNamed:@"button1.png"] forState:UIControlStateNormal];

//            [swipe_next_playBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"StartPlay", nil), [ImagesModel sharedModel].currentPackageIndex+2] forState:UIControlStateNormal];
         } else {
            [swipe_next_playBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"Unlock", nil), [ImagesModel sharedModel].currentPackageIndex+2] forState:UIControlStateNormal];
            [swipe_next_playBtn setBackgroundImage:[UIImage imageNamed:@"button4.png"] forState:UIControlStateNormal];
         }
      }
   }
}
-(void) nextPack{
   if ([ImagesModel sharedModel].currentPackageIndex < [ImagesModel sharedModel].numberOfPackages-1) {
      [[ImagesModel sharedModel] setIndexOfCurrentWord:[[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex+1] inPackage:[ImagesModel sharedModel].currentPackageIndex+1];
      numAnsweredLabel.text = [NSString stringWithFormat:@"%d/%d", [[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex]+1, [[ImagesModel sharedModel] numberOfAllPicsInPackage:[ImagesModel sharedModel].currentPackageIndex]];

      UIView *tmp1 = bgImgView, *tmp2 = currentImageView, *tmp3 = playBtn;
      CGRect rect1 = bgImgView.frame, rect2 = currentImageView.frame, rect3 = playBtn.frame;

      [UIView animateWithDuration:0.2 animations:^(void)
      {
         swipe_next_bgImgView.frame = CGRectMake(50, 110-45.0f+[self topOffset], self.view.frame.size.width-100, self.view.frame.size.width-120);
         swipe_next_currentImageView.frame = CGRectMake(70, 130-45.0f+[self topOffset], self.view.frame.size.width-140, self.view.frame.size.width-160);
         swipe_next_playBtn.frame = CGRectMake(self.view.frame.size.width/2.0f - 80.0f, 110.0f + (self.view.frame.size.width-160)/2.0f-45.0f+[self topOffset], 160.0f, 40.0f);

         tmp1.frame = CGRectMake(rect1.origin.x - self.view.frame.size.width, rect1.origin.y, rect1.size.width, rect1.size.height);
         tmp2.frame = CGRectMake(rect2.origin.x - self.view.frame.size.width, rect2.origin.y, rect2.size.width, rect2.size.height);
         tmp3.frame = CGRectMake(rect3.origin.x - self.view.frame.size.width, rect3.origin.y, rect3.size.width, rect3.size.height);
      } completion:^(BOOL finished){

         [tmp1 removeFromSuperview];
         [tmp2 removeFromSuperview];
         [tmp3 removeFromSuperview];
      }];

      bgImgView = swipe_next_bgImgView;
      currentImageView = swipe_next_currentImageView;
      playBtn = swipe_next_playBtn;

      currentImageView.userInteractionEnabled = YES;
      UIPanGestureRecognizer *rec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
      [currentImageView addGestureRecognizer:rec];

      swipe_next_bgImgView = nil;
      swipe_next_currentImageView = nil;
      swipe_next_playBtn = nil;

      PicsAndWord *next = [[ImagesModel sharedModel] picsAndWordForID:[[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex+1] inPackage:[ImagesModel sharedModel].currentPackageIndex+1];
      if (next) {
         swipe_next_bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width + 50, 110-45.0f+[self topOffset], self.view.frame.size.width-100, self.view.frame.size.width-120)];
         swipe_next_bgImgView.image = [UIImage imageNamed:@"startBGImage.png"];
         [self.view addSubview:swipe_next_bgImgView];

         swipe_next_currentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width + 70, 130-45.0f+[self topOffset], self.view.frame.size.width-140, self.view.frame.size.width-160)];
         swipe_next_currentImageView.image = next.packedImage;
         [self.view addSubview:swipe_next_currentImageView];

         swipe_next_playBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width + self.view.frame.size.width/2.0f - 80.0f, 110.0f + (self.view.frame.size.width-160)/2.0f-45.0f+[self topOffset], 160.0f, 40.0f)];
         [swipe_next_playBtn addTarget:self action:@selector(startPlay) forControlEvents:UIControlEventTouchUpInside];
         [swipe_next_playBtn setBackgroundImage:[UIImage imageNamed:@"button1.png"] forState:UIControlStateNormal];
         [self.view addSubview:swipe_next_playBtn];

         if ([[ImagesModel sharedModel] wordIsUnlocked:[[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex+1] inPackage:[ImagesModel sharedModel].currentPackageIndex+1]) {





            if (([[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex+1] == [[ImagesModel sharedModel] numberOfAllPicsInPackage:[ImagesModel sharedModel].currentPackageIndex+1] -1) &&
                ([[ImagesModel sharedModel] isWon:[[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex+1] inPackage:[ImagesModel sharedModel].currentPackageIndex+1]))
            {

               [swipe_next_playBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"RePlay", nil), [ImagesModel sharedModel].currentPackageIndex+2] forState:UIControlStateNormal];
            } else {
               [swipe_next_playBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"StartPlay", nil), [ImagesModel sharedModel].currentPackageIndex+2] forState:UIControlStateNormal];
            }


            [swipe_next_playBtn setBackgroundImage:[UIImage imageNamed:@"button1.png"] forState:UIControlStateNormal];

//            [swipe_next_playBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"StartPlay", nil), [ImagesModel sharedModel].currentPackageIndex+2] forState:UIControlStateNormal];
         } else {
            [swipe_next_playBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"Unlock", nil), [ImagesModel sharedModel].currentPackageIndex+2] forState:UIControlStateNormal];
            [swipe_next_playBtn setBackgroundImage:[UIImage imageNamed:@"button4.png"] forState:UIControlStateNormal];
         }
      }


      [swipe_prev_bgImgView removeFromSuperview];
      [swipe_prev_currentImageView removeFromSuperview];
      [swipe_prev_playBtn removeFromSuperview];

      PicsAndWord *previous = [[ImagesModel sharedModel] picsAndWordForID:[[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex-1] inPackage:[ImagesModel sharedModel].currentPackageIndex-1];
      if (previous) {
         swipe_prev_bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(-self.view.frame.size.width + 50, 110-45.0f+[self topOffset], self.view.frame.size.width-100, self.view.frame.size.width-120)];
         swipe_prev_bgImgView.image = [UIImage imageNamed:@"startBGImage.png"];
         [self.view addSubview:swipe_prev_bgImgView];

         swipe_prev_currentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-self.view.frame.size.width + 70, 130-45.0f+[self topOffset], self.view.frame.size.width-140, self.view.frame.size.width-160)];
         swipe_prev_currentImageView.image = previous.packedImage;
         [self.view addSubview:swipe_prev_currentImageView];

         swipe_prev_playBtn = [[UIButton alloc] initWithFrame:CGRectMake(-self.view.frame.size.width + self.view.frame.size.width/2.0f - 80.0f, 110.0f + (self.view.frame.size.width-160)/2.0f-45.0f+[self topOffset], 160.0f, 40.0f)];
         [swipe_prev_playBtn addTarget:self action:@selector(startPlay) forControlEvents:UIControlEventTouchUpInside];
         [swipe_prev_playBtn setBackgroundImage:[UIImage imageNamed:@"button1.png"] forState:UIControlStateNormal];
         [self.view addSubview:swipe_prev_playBtn];

         if ([[ImagesModel sharedModel] wordIsUnlocked:[[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex-1] inPackage:[ImagesModel sharedModel].currentPackageIndex-1]) {




            if (([[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex-1] == [[ImagesModel sharedModel] numberOfAllPicsInPackage:[ImagesModel sharedModel].currentPackageIndex-1] -1) &&
                ([[ImagesModel sharedModel] isWon:[[ImagesModel sharedModel] currentWordIndexInPackage:[ImagesModel sharedModel].currentPackageIndex-1] inPackage:[ImagesModel sharedModel].currentPackageIndex-1]))
            {

               [swipe_prev_playBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"RePlay", nil), [ImagesModel sharedModel].currentPackageIndex] forState:UIControlStateNormal];
            } else {
               [swipe_prev_playBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"StartPlay", nil), [ImagesModel sharedModel].currentPackageIndex] forState:UIControlStateNormal];
            }


            [swipe_prev_playBtn setBackgroundImage:[UIImage imageNamed:@"button1.png"] forState:UIControlStateNormal];
//            [swipe_prev_playBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"StartPlay", nil), [ImagesModel sharedModel].currentPackageIndex] forState:UIControlStateNormal];
         } else {
            [swipe_prev_playBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"Unlock", nil), [ImagesModel sharedModel].currentPackageIndex]forState:UIControlStateNormal];
            [swipe_prev_playBtn setBackgroundImage:[UIImage imageNamed:@"button4.png"] forState:UIControlStateNormal];
         }
      }
   }
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
}
-(void) cancelBuy:(UIButton*)sender{
   [sender.superview.superview removeFromSuperview];

}

#pragma mark - Table Delegate
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

@end
