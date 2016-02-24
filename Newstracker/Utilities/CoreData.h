//
//  coreData.h
//  
//
//  Created by Micheal on 18/11/15.
//
//

#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import "FoodItems.h"

@interface CoreData : NSManagedObject
+ (NSManagedObjectContext *)managedObjectContext;
+ (void)saveFoodItems:(FoodItems *)sentModel;
+ (NSArray *)fetchFoodItemsWithPredicate:(NSPredicate *)predicate;
+ (void)deleteFoodItemsWithPredicate:(NSPredicate *)predicate;
@end
