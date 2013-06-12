//
//  ToMUtilities.m
//  TaskoMatic
//
//  Created by Mike Garwood on 6/10/13.
//  Copyright (c) 2013 Neterata. All rights reserved.
//

#import "ToMUtilities.h"

@implementation ToMUtilities

+ (NSString *)normalizeTime: (int)minutes
{
    int hours = minutes / 60;
    int mins = minutes - hours * 60;
    NSMutableString *value = [[NSMutableString alloc] init];
    if (hours)
    {
        [value setString:[NSString stringWithFormat:@"%d hour", hours]];
        if (hours != 1)
        {
            [value appendString:@"s"];
        }
        if (mins)
        {
            [value appendFormat:@", %d minute", mins];
            if (mins != 1)
            {
                [value appendString:@"s"];
            }
        }
    }
    else
    {
        if (mins)
        {
            [value setString:[NSString stringWithFormat:@"%d minute", mins]];
            if (mins != 1)
            {
                [value appendString:@"s"];
            }
        }
    }
    return value;
}
@end
