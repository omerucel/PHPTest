//
//  OUProfileTableDataSource.h
//  PHPTest
//
//  Created by Ömer ÜCEL on 5/26/13.
//  Copyright (c) 2013 Ömer ÜCEL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OUProfileTableDataSource : NSObject <NSTableViewDataSource>{
    NSMutableArray *items;
    NSManagedObjectContext *managedObjectContext;
}

- (id)init:(NSManagedObjectContext *)context;
- (void)remove:(NSInteger)index;
- (NSArray *)getItems;
- (void)create:(NSString *)name version:(NSString *)version bin:(NSString *)bin;
- (BOOL)hasItem;
- (NSManagedObject *)getItem:(NSString *)name;

@end
