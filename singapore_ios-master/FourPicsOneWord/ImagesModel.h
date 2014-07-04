//
//  ImagesModel.h
//  FourPicsOneWord
//
//  Created by  on 10/14/13.
//  Copyright (c) 2013 Vojtec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface PicsAndWord : NSObject
{
//   UIImage *picture1, *picture2, *picture3, *picture4;
//   NSString *word;
}

-(id)initWithDictionary:(NSDictionary*)dict;

-(NSArray*)chosenLetters;
-(NSArray*)availableLetters;
-(NSArray*)letterAvailability;
-(NSSet*)revealedLetters;

-(int)nextFreeIndex;

-(void)removeLetterFromChosenLetters:(int)index;
-(void)chooseLetterFromAvailableLetters:(int)index;

-(BOOL)wordIsFull;
-(NSString*)solution;
-(BOOL)solutionIsCorrect;

//power ups
-(int)deleteIncorrectLetters;
-(BOOL)showCorrectLetter;

-(UIImage*)packedImage;


@property (strong, readonly, nonatomic) UIImage *picture1, *picture2, *picture3, *picture4;
@property (strong, readonly, nonatomic) NSString *word;
@property (strong, readonly, nonatomic) NSString *category;
@property (readonly) int identifier;

@end

#define kBonusTime (60*60*8)

@interface ImagesModel : NSObject <SKPaymentTransactionObserver>

+(ImagesModel*)sharedModel;
//-(PicsAndWord*)nextPicsAndWordForPreviousID:(int)identifier;
-(PicsAndWord*)picsAndWordForID:(int)identifier inPackage:(int)package;
-(PicsAndWord*)nextBonusForPreviousID:(int)identifier;

-(int)numberOfPackages;
-(int)numberOfAllPicsInPackage:(int)package;

-(int)numberOfAllBonuses;
//-(int)numberOfAnswered;
-(int)numberOfBonusAnswered;

-(int)currentPackageIndex;
-(int)currentWordIndexInPackage:(int)package;
-(void)setIndexOfCurrentWord:(int)index inPackage:(int)package;

//-(void)setNumberOfAnswered:(int)numberOfAnswered;
-(void)setNumberOfBonusAnswered:(int)numberOfAnswered;

-(int)coins;
-(void)payCoins:(int)coins;

//-(void)win;
-(void)winWithID:(int)identifier inPackage:(int)package;
-(void)winBonus;
-(void)winWatchVideoReward:(int)amount;

-(BOOL)isWon:(int)identifier inPackage:(int)package;

-(BOOL)wordIsUnlocked:(int)identifier inPackage:(int)package;
-(void)unlockPackage:(int)package;
-(void)unlockLevel:(int)identifier inPackage:(int)package;

-(NSDate*)lastAnsweredBonusDate;
-(void)setLastAnsweredBonus:(NSDate*)date;

-(BOOL)premium;

@end
