//
//  OUProfileTableDataSource.m
//  PHPTest
//
//  Created by Ömer ÜCEL on 5/26/13.
//  Copyright (c) 2013 Ömer ÜCEL. All rights reserved.
//

#import "OUProfileTableDataSource.h"

@implementation OUProfileTableDataSource

- (id)init:(NSManagedObjectContext *)context{
    if (self = [super init])
    {
        items = [NSMutableArray array];
        managedObjectContext = context;

        NSError *error;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Profile" inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        NSArray *records = [managedObjectContext executeFetchRequest:[NSFetchRequest fetchRequestWithEntityName:@"Profile"] error:&error];
        for(NSManagedObject *info in records)
            [items addObject:[info valueForKey:@"name"]];
    }

    return self;
}

- (NSArray *)getItems{
    return [NSArray arrayWithArray:items];
}

- (void)remove:(NSInteger)index{
    NSString *name = (NSString *)[items objectAtIndex:index];

    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Profile" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"name == '%@'", name]]];
    NSArray *records = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if ([records count] > 0)
    {
        [managedObjectContext deleteObject:[records objectAtIndex:0]];
        [items removeObjectAtIndex:index];
    }
}

- (void)create:(NSString *)name version:(NSString *)version bin:(NSString *)bin{
    NSManagedObject *profile = [NSEntityDescription insertNewObjectForEntityForName:@"Profile" inManagedObjectContext:managedObjectContext];
    [profile setValue:name forKey:@"name"];
    [profile setValue:version forKey:@"version"];
    [profile setValue:bin forKey:@"bin"];
    [managedObjectContext insertObject:profile];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    if ([[tableColumn identifier] isEqualToString:@"name"])
        return [items objectAtIndex:row];

    return nil;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [items count];
}

@end
