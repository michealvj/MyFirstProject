//
//  coreData.m
//  
//
//  Created by Micheal on 18/11/15.
//
//

#import "CoreData.h"

#pragma mark - DB FoodItems

#define kEntityName @"FoodItems"
#define kItemName @"itemname"
#define kQuantity @"quantity"
#define kDescValue @"descvalue"
#define kImageUrl @"imageurl"
#define kPrice @"price"

@implementation CoreData

+ (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)])
    {
        context = [delegate managedObjectContext];
    }
    
    return context;
}

+ (void)saveFoodItems:(FoodItems *)sentModel
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:kEntityName];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemname = %@", sentModel.itemname];
    fetchRequest.predicate=predicate;
    NSManagedObject *updateObject = [[context executeFetchRequest:fetchRequest error:nil] lastObject];
    NSLog(@"%@", [updateObject valueForKey:kItemName]);
    if([[updateObject valueForKey:kItemName] isEqualToString:sentModel.itemname])
    {
        [updateObject setValue:sentModel.itemname forKey:kItemName];
        [updateObject setValue:sentModel.quantity forKey:kQuantity];
        [updateObject setValue:sentModel.descvalue forKey:kDescValue];
        [updateObject setValue:sentModel.price forKey:kPrice];
        [updateObject setValue:sentModel.imageurl forKey:kImageUrl];
        [self saveToDatabase];
    }
    else
    {
        NSManagedObject *new = [NSEntityDescription insertNewObjectForEntityForName:kEntityName inManagedObjectContext:context];
        [new setValue:sentModel.itemname forKey:kItemName];
        [new setValue:sentModel.quantity forKey:kQuantity];
        [new setValue:sentModel.descvalue forKey:kDescValue];
        [new setValue:sentModel.price forKey:kPrice];
        [new setValue:sentModel.imageurl forKey:kImageUrl];
        
        [self saveToDatabase];
    }
   }

+ (NSArray *)fetchFoodItemsWithPredicate:(NSPredicate *)predicate
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:kEntityName];
    
    if (predicate!=nil)
    {
        fetchRequest.predicate = predicate;
    }
    
    NSArray *allValues = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    //Storing in FoodItems
    NSMutableArray *modelArray = [[NSMutableArray alloc] init];
    if (allValues.count>0)
    {
        for (NSManagedObject *object in allValues)
        {
            FoodItems *item = [[FoodItems alloc] init];
            item.itemname = [object valueForKey:kItemName];
            item.quantity = [object valueForKey:kQuantity];
            item.descvalue = [object valueForKey:kDescValue];
            item.imageurl = [object valueForKey:kImageUrl];
            item.price = [object valueForKey:kPrice];
            [modelArray addObject:item];
        }
    }
    NSLog(@"Total datas: %lu", (unsigned long)allValues.count);
    
    return modelArray;
}


+ (void)deleteFoodItemsWithPredicate:(NSPredicate *)predicate
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:kEntityName];
    if (predicate!=nil)
    {
        fetchRequest.predicate = predicate;
    }
    NSArray *allValues = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];

    
    for (NSManagedObject *object in allValues) {
        [context deleteObject:object];
    }
    [self saveToDatabase];
}

+(void)saveToDatabase
{
    // Save the object to persistent store
    NSManagedObjectContext *context = [self managedObjectContext];
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
}

@end
