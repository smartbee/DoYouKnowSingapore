//
//  ImagesModel.m
//  FourPicsOneWord
//
//  Created by  on 10/14/13.
//  Copyright (c) 2013 Vojtec. All rights reserved.
//

#import "ImagesModel.h"

@interface PicsAndWord ()
{
    NSMutableArray *chosenLetters;
    NSMutableArray *availableLetters;
    NSMutableDictionary *available_chosenMapping;
    NSMutableArray *availabilityOfLetters;
    
    NSMutableSet* revealedLetters;
    
    //   int nextFreeIndex;
}

@end

@implementation PicsAndWord

-(id) initWithDictionary:(NSDictionary*)dict{
    if (self = [super init]) {
        
        //      NSLog(@"%@",dict);
        if (![dict objectForKey:@"Word"] || ![[dict objectForKey:@"Word"] isKindOfClass:[NSString class]]) {
            NSLog(@"Error: Images.plist file is not correctly formatted. A Word is missing");
            return nil;
        }
        _word = [dict objectForKey:@"Word"];
        _word = [_word uppercaseString];
        
        if (![dict objectForKey:@"Category"] || ![[dict objectForKey:@"Category"] isKindOfClass:[NSString class]]) {
            NSLog(@"Error: Images.plist file is not correctly formatted. A Category is missing");
            return nil;
        }
        _category = [dict objectForKey:@"Category"];
        
        
        if ([dict objectForKey:@"Pics"] == nil) {
            NSLog(@"Error: Images.plist file is not correctly formatted. The word '%@' doesn't have a picture array", [dict objectForKey:@"Word"]);
            return nil;
        }
        if ([[[dict objectForKey:@"Pics"] class] isKindOfClass:[NSArray class]]) {
            NSLog(@"Error: Images.plist file is not correctly formatted. The word '%@' doesn't have a picture array", [dict objectForKey:@"Word"]);
            return nil;
        }
        NSArray *pics = [dict objectForKey:@"Pics"];
        if (pics.count < 4) {
            NSLog(@"Error: Images.plist file is not correctly formatted. The word '%@' has less than 4 images in the picture array", [dict objectForKey:@"Word"]);
            return nil;
        }
        
        _picture1 = [UIImage imageNamed:pics[0]];
        if (!_picture1) {
            NSLog(@"Error: Image number %d on the word '%@' can't be found", 0, [dict objectForKey:@"Word"]);
            return nil;
        }
        _picture2 = [UIImage imageNamed:pics[1]];
        if (!_picture2) {
            NSLog(@"Error: Image number %d on the word '%@' can't be found", 2, [dict objectForKey:@"Word"]);
            return nil;
        }
        _picture3 = [UIImage imageNamed:pics[2]];
        if (!_picture3) {
            NSLog(@"Error: Image number %d on the word '%@' can't be found", 3, [dict objectForKey:@"Word"]);
            return nil;
        }
        _picture4 = [UIImage imageNamed:pics[3]];
        if (!_picture4) {
            NSLog(@"Error: Image number %d on the word '%@' can't be found", 4, [dict objectForKey:@"Word"]);
            return nil;
        }
        
        
        
        
        chosenLetters = [[NSMutableArray alloc] init];
        for (int i = 0; i < _word.length; i++) {
            [chosenLetters addObject:@""];
        }
        
        availableLetters = [[NSMutableArray alloc] init];
        availabilityOfLetters = [[NSMutableArray alloc] init];
        available_chosenMapping = [[NSMutableDictionary alloc] init];
        revealedLetters = [[NSMutableSet alloc] init];
        
        for (int i = 0; i < NUMBER_LETTER*2; i++) {
            availabilityOfLetters[i] = @(YES);
            
            if (i < _word.length) {
                [availableLetters addObject:[NSString stringWithFormat:@"%c", [_word characterAtIndex:i]]];
            } else {
                [availableLetters addObject:[NSString stringWithFormat:@"%c", 65 + (rand()%26)]];
            }
        }
        
        for (int i = 0; i < 100; i++) {
            int firstIndex = rand() % NUMBER_LETTER*2;
            int secondIndex = rand() % NUMBER_LETTER*2;
            
            if (firstIndex == secondIndex) {
                firstIndex++;
                firstIndex = firstIndex % NUMBER_LETTER*2;
            }
            
            NSString *tmp = availableLetters[firstIndex];
            availableLetters[firstIndex] = availableLetters[secondIndex];
            availableLetters[secondIndex] = tmp;
        }
        
    }
    return self;
}
-(NSMutableArray*) chosenLetters{
    return chosenLetters;
}
-(NSArray*) availableLetters{
    return  availableLetters;
}
-(NSMutableArray*) letterAvailability{
    return availabilityOfLetters;
}
-(NSSet*) revealedLetters{
    return revealedLetters;
}
-(int) nextFreeIndex{
    for (int i = 0; i < _word.length; i++) {
        if ([chosenLetters[i] isEqualToString:@""]) {
            return i;
        }
    }
    return -1;
}
-(void) removeLetterFromChosenLetters:(int)index{
    NSNumber *removeKey;
    for (NSNumber *key in available_chosenMapping) {
        if (((NSNumber*)available_chosenMapping[key]).intValue == index) {
            removeKey = key;
            break;
        }
    }
    for (NSNumber* num in revealedLetters) {
        if (num.intValue == index) {
            removeKey = nil;
        }
    }
    if (removeKey) {
        availabilityOfLetters[removeKey.intValue] = @(YES);
        [available_chosenMapping removeObjectForKey:removeKey];
        chosenLetters[index] = @"";
    }
}
-(void) chooseLetterFromAvailableLetters:(int)index{
    int nextFree = [self nextFreeIndex];
    if (nextFree != -1 && index < availableLetters.count) {
        for (NSNumber *key in available_chosenMapping) {
            if (key.intValue == index) {
                return;
            }
        }
        available_chosenMapping[[NSNumber numberWithInt:index]] = [NSNumber numberWithInt:nextFree];
        chosenLetters[nextFree] = availableLetters[index];
        availabilityOfLetters[index] = @(NO);
    }
}
-(BOOL) wordIsFull{
    return _word.length == available_chosenMapping.count;
}
-(NSString*) solution{
    NSMutableString *sol = [[NSMutableString alloc] init];
    for (NSString *letter in chosenLetters) {
        [sol appendString:letter];
    }
    
    return [NSString stringWithString:sol];
}
-(BOOL) solutionIsCorrect{
    NSString *sol = [self solution];
    return [sol isEqualToString:_word];
}
-(int) deleteIncorrectLetters{
    NSMutableString *w = [NSMutableString stringWithString:_word];
    for (NSNumber *key in available_chosenMapping) {
        NSRange r = [w rangeOfString:availableLetters[key.intValue]];
        if (r.location != NSNotFound) {
            [w deleteCharactersInRange:r];
        }
    }
    
    NSMutableArray *availability = [NSMutableArray arrayWithArray:[self letterAvailability]];
    int numAvailable = 0;
    for (int i = 0; i < NUMBER_LETTER*2; i++) {
        if (((NSNumber*)availability[i]).boolValue) {
            numAvailable++;
            
            NSRange r = [w rangeOfString:availableLetters[i]];
            if (r.location != NSNotFound) {
                [w deleteCharactersInRange:r];
                availability[i] = [NSNumber numberWithBool:NO];
                numAvailable--;
            }
        }
    }
    
    int numDeleted = 0;
    int numToDelete = 16;
    
    for (int i = 0; i < numToDelete && numAvailable > 0; i++) {
        int index = rand() % NUMBER_LETTER*2;
        for (int j = 0; j < NUMBER_LETTER*2; j++) {
            if (((NSNumber*)availability[(index+j)%NUMBER_LETTER*2]).boolValue) {
                numAvailable--;
                availabilityOfLetters[(index+j)%NUMBER_LETTER*2] = @(NO);
                availability[(index+j)%NUMBER_LETTER*2] = @(NO);
                numDeleted++;
                break;
            }
        }
    }
    return numDeleted;
}
-(BOOL) showCorrectLetter{
    if (![self wordIsFull]) {
        
        NSMutableString *w = [NSMutableString stringWithString:_word];
        for (NSNumber *key in available_chosenMapping) {
            NSRange r = [w rangeOfString:availableLetters[key.intValue]];
            if (r.location != NSNotFound) {
                [w deleteCharactersInRange:r];
            }
        }
        
        int index = rand() % NUMBER_LETTER*2;
        for (int i = 0; i < NUMBER_LETTER*2; i++) {
            if (((NSNumber*)[self letterAvailability][(index+i)%NUMBER_LETTER*2]).boolValue) {
                NSRange r = [w rangeOfString:availableLetters[(index+i)%NUMBER_LETTER*2]];
                if (r.location != NSNotFound) {
                    
                    int avidx = (index+i)%NUMBER_LETTER*2;
                    for (int j = 0; j < _word.length; j++) {
                        if ([chosenLetters[j] isEqualToString:@""] && [[NSString stringWithFormat:@"%c", [_word characterAtIndex:j]] isEqualToString:availableLetters[avidx]]) {
                            int wordidx = j;
                            
                            available_chosenMapping[[NSNumber numberWithInt:avidx]] = [NSNumber numberWithInt:wordidx];
                            chosenLetters[wordidx] = availableLetters[avidx];
                            availabilityOfLetters[avidx] = @(NO);
                            
                            [revealedLetters addObject:@(wordidx)];
                            
                            return YES;
                        }
                    }
                    
                    
                }
            }
        }
    }
    return NO;
}
-(UIImage*) packedImage{
    CGSize newSize = CGSizeMake(300, 300);
    UIGraphicsBeginImageContext( newSize );
    
    [_picture1 drawInRect:CGRectMake(0,0,300,300)];
    //   [_picture2 drawInRect:CGRectMake(150,0,150,150)];
    //   [_picture3 drawInRect:CGRectMake(0,150,150,150)];
    //   [_picture4 drawInRect:CGRectMake(150,150,150,150)];
    //   [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height) blendMode:kCGBlendModeNormal alpha:0.8];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return newImage;
}

@end

@interface ImagesModel (){
    NSArray *imagesModel;
    NSArray *bonusImages;
    NSDate *lastAnsweredBonus;
    //   int _numberOfAnswered;
    int _numberOfBonusAnswered;
    int _coins;
    //   int _currentWord;
    NSMutableDictionary *_currentWords;
    int _currentPackage;
    
    BOOL _premium;
    
    NSMutableDictionary *answeredDict;
    NSMutableDictionary *unlockedDict;
}

@end

@implementation ImagesModel

static ImagesModel *sharedModel = nil;

+(ImagesModel*)sharedModel{
    if (sharedModel == nil) {
        sharedModel = [[ImagesModel alloc] init];
    }
    return sharedModel;
}
-(id)init{
    if (self = [super init]) {
        NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Images" ofType:@"plist"]];
        imagesModel = plist[@"PicsAndWords"];
        bonusImages = plist[@"Bonus"];
        
        if (![[NSUserDefaults standardUserDefaults] objectForKey:@"wordIndex"]) {
            //      if (YES) {
            [[NSUserDefaults standardUserDefaults] setObject:@{} forKey:@"wordIndex"];
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"packIndex"];
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"numAnsweredBonuses"];
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"numCoins"];
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastAnsweredBonus"];
            [[NSUserDefaults standardUserDefaults] setObject:@(NO) forKey:@"premium"];
            [[NSUserDefaults standardUserDefaults] setObject:@{} forKey:@"answered"];
            [[NSUserDefaults standardUserDefaults] setObject:@{@"0": @{@"0": @(YES)}} forKey:@"unlocked"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        //      _numberOfAnswered = ((NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:@"numAnsweredLevels"]).intValue;
        //      _currentWord = _numberOfAnswered;
        _currentWords = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"wordIndex"]];
        _currentPackage = ((NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:@"packIndex"]).intValue;
        _numberOfBonusAnswered = ((NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:@"numAnsweredBonuses"]).intValue;
        lastAnsweredBonus = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastAnsweredBonus"];
        _coins = ((NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:@"numCoins"]).intValue;
        _premium = ((NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:@"premium"]).boolValue;
        answeredDict = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"answered"]];
        NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:answeredDict];
        for (NSString *key in tmp) {
            answeredDict[key] = [NSMutableDictionary dictionaryWithDictionary:tmp[key]];
        }
        unlockedDict = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"unlocked"]];
        tmp = [NSMutableDictionary dictionaryWithDictionary:unlockedDict];;
        for (NSString *key in tmp) {
            unlockedDict[key] = [NSMutableDictionary dictionaryWithDictionary:tmp[key]];
        }
        
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}
-(void) paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}
-(void) completeTransaction: (SKPaymentTransaction *)transaction{
    if ([transaction.payment.productIdentifier isEqualToString:@"coins350"]) {
        _coins += 350;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:_coins] forKey:@"numCoins"];
    } else if([transaction.payment.productIdentifier isEqualToString:@"coins750"]) {
        _coins += 750;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:_coins] forKey:@"numCoins"];
    } else if([transaction.payment.productIdentifier isEqualToString:@"coins2000"]) {
        _coins += 2000;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:_coins] forKey:@"numCoins"];
    } else if([transaction.payment.productIdentifier isEqualToString:@"coins4500"]) {
        _coins += 4500;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:_coins] forKey:@"numCoins"];
    } else if([transaction.payment.productIdentifier isEqualToString:@"coins10000"]) {
        _coins += 10000;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:_coins] forKey:@"numCoins"];
    } else if([transaction.payment.productIdentifier isEqualToString:@"premium"]) {
        _coins += 500;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:_coins] forKey:@"numCoins"];
        [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"premium"];
        _premium = YES;
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updatedCoinsAndPremium" object:nil];
}
-(void) restoreTransaction: (SKPaymentTransaction *)transaction{
    if([transaction.payment.productIdentifier isEqualToString:@"premium"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"premium"];
        _premium = YES;
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}
-(void) failedTransaction: (SKPaymentTransaction *)transaction{
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}
-(int) coins{
    return _coins;
}
-(void) payCoins:(int)coins{
    _coins -= coins;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:_coins] forKey:@"numCoins"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
-(BOOL) isWon:(int)identifier inPackage:(int)package{
    return answeredDict[[NSString stringWithFormat:@"%d", package]] && answeredDict[[NSString stringWithFormat:@"%d", package]][[NSString stringWithFormat:@"%d", identifier]] && ((NSNumber*)answeredDict[[NSString stringWithFormat:@"%d", package]][[NSString stringWithFormat:@"%d", identifier]]).boolValue;
}
-(void) winWithID:(int)identifier inPackage:(int)package{
    if (!answeredDict[[NSString stringWithFormat:@"%d", package]]) {
        answeredDict[[NSString stringWithFormat:@"%d", package]] = [NSMutableDictionary dictionary];
        answeredDict[[NSString stringWithFormat:@"%d", package]][[NSString stringWithFormat:@"%d", identifier]] = @(YES);
        _coins += 4;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:_coins] forKey:@"numCoins"];
    } else if (!answeredDict[[NSString stringWithFormat:@"%d", package]][[NSString stringWithFormat:@"%d", identifier]] ||
               !((NSNumber*)answeredDict[[NSString stringWithFormat:@"%d", package]][[NSString stringWithFormat:@"%d", identifier]]).boolValue) {
        
        _coins += 4;
        answeredDict[[NSString stringWithFormat:@"%d", package]][[NSString stringWithFormat:@"%d", identifier]] = @(YES);
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:_coins] forKey:@"numCoins"];
    }
    
    if (identifier+1 < [self numberOfAllPicsInPackage:self.currentPackageIndex]) {
        unlockedDict[[NSString stringWithFormat:@"%d", package]][[NSString stringWithFormat:@"%d", identifier+1]] = @(YES);
    } else {
        if (!unlockedDict[[NSString stringWithFormat:@"%d", package+1]]) {
            unlockedDict[[NSString stringWithFormat:@"%d", package+1]] = [NSMutableDictionary dictionary];
        }
        unlockedDict[[NSString stringWithFormat:@"%d", package+1]][@"0"] = @(YES);
    }
    
    
    NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:answeredDict];
    for (NSString *key in answeredDict) {
        tmp[key] = [NSDictionary dictionaryWithDictionary:answeredDict[key]];
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithDictionary:tmp]] forKey:@"answered"];
    
    tmp = [NSMutableDictionary dictionaryWithDictionary:unlockedDict];
    for (NSString *key in unlockedDict) {
        tmp[key] = [NSDictionary dictionaryWithDictionary:unlockedDict[key]];
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithDictionary:tmp]] forKey:@"unlocked"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//-(void)win
//{
//   _coins += 4;
//   [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:_coins] forKey:@"numCoins"];
//   [[NSUserDefaults standardUserDefaults] synchronize];
//}

-(void) winBonus{
    _coins += 20;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:_coins] forKey:@"numCoins"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
-(void) winWatchVideoReward:(int)amount{
    _coins += amount;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:_coins] forKey:@"numCoins"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
-(BOOL) wordIsUnlocked:(int)identifier inPackage:(int)package{
    if (unlockedDict[[NSString stringWithFormat:@"%d", package]]) {
        if (unlockedDict[[NSString stringWithFormat:@"%d", package]][[NSString stringWithFormat:@"%d", identifier]]) {
            return ((NSNumber*)unlockedDict[[NSString stringWithFormat:@"%d", package]][[NSString stringWithFormat:@"%d", identifier]]).boolValue;
        }
    }
    return NO;
}
-(void) unlockPackage:(int)package{
    if (!unlockedDict[[NSString stringWithFormat:@"%d", package]]) {
        unlockedDict[[NSString stringWithFormat:@"%d", package]] = [NSMutableDictionary dictionary];
        
        NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:unlockedDict];
        for (NSString *key in unlockedDict) {
            tmp[key] = [NSDictionary dictionaryWithDictionary:unlockedDict[key]];
        }
        [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithDictionary:tmp]] forKey:@"unlocked"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
-(void) unlockLevel:(int)identifier inPackage:(int)package{
    if (!unlockedDict[[NSString stringWithFormat:@"%d", package]]) {
        unlockedDict[[NSString stringWithFormat:@"%d", package]] = [NSMutableDictionary dictionary];
    }
    unlockedDict[[NSString stringWithFormat:@"%d", package]][[NSString stringWithFormat:@"%d", identifier]] = @(YES);
    
    NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:unlockedDict];
    for (NSString *key in unlockedDict) {
        tmp[key] = [NSDictionary dictionaryWithDictionary:unlockedDict[key]];
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithDictionary:tmp]] forKey:@"unlocked"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
-(PicsAndWord*) picsAndWordForID:(int)identifier inPackage:(int)package{
    if (identifier < 0) {
        return nil;
    }
    if (package < 0) {
        return nil;
    }
    if (package < imagesModel.count) {
        if (identifier < ((NSArray*)imagesModel[package]).count) {
            return [[PicsAndWord alloc] initWithDictionary:imagesModel[package][identifier]];
        }
    }
    return nil;
}

//-(PicsAndWord*)nextPicsAndWordForPreviousID:(int)identifier
//{
//   int newIndex = identifier + 1;
////   newIndex = newIndex % imagesModel.count;
//   if (newIndex < imagesModel.count) {
//      return [[PicsAndWord alloc] initWithDictionary:imagesModel[newIndex]];
//   }
//   return nil;
//}

-(PicsAndWord*) nextBonusForPreviousID:(int)identifier{
    int newIndex = identifier + 1;
    //   newIndex = newIndex % bonusImages.count;
    if (newIndex < bonusImages.count) {
        return [[PicsAndWord alloc] initWithDictionary:bonusImages[newIndex]];
    }
    return nil;
}
-(int) currentPackageIndex{
    return _currentPackage;
}
-(int) currentWordIndexInPackage:(int)package{
    if (_currentWords[[NSString stringWithFormat:@"%d", package]]) {
        return ((NSNumber*)_currentWords[[NSString stringWithFormat:@"%d", package]]).intValue;
    }
    return 0;
}
-(void) setIndexOfCurrentWord:(int)index inPackage:(int)package{
    _currentPackage = package;
    _currentWords[[NSString stringWithFormat:@"%d", package]] = @(index);
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:_currentPackage] forKey:@"packIndex"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithDictionary:_currentWords] forKey:@"wordIndex"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//-(void)setNumberOfAnswered:(int)numberOfAnswered
//{
//   _numberOfAnswered = numberOfAnswered;
//   [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:numberOfAnswered] forKey:@"numAnsweredLevels"];
//   [[NSUserDefaults standardUserDefaults] synchronize];
//}

-(void) setNumberOfBonusAnswered:(int)numberOfAnswered{
    _numberOfBonusAnswered = numberOfAnswered;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:_numberOfBonusAnswered] forKey:@"numAnsweredBonuses"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
-(int) numberOfPackages{
    return imagesModel.count;
}
-(int) numberOfAllPicsInPackage:(int)package{
    return ((NSArray*)imagesModel[package]).count;
    //   return 10;
}
-(int) numberOfAllBonuses{
    return bonusImages.count;
}

//-(int)numberOfAnswered
//{
//   return _numberOfAnswered;
//}

-(int) numberOfBonusAnswered{
    return _numberOfBonusAnswered;
}
-(NSDate*) lastAnsweredBonusDate{
    return lastAnsweredBonus;
}
-(void) setLastAnsweredBonus:(NSDate*)date{
    lastAnsweredBonus = date;
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:@"lastAnsweredBonus"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
-(BOOL) premium{
    return _premium;
}

@end
