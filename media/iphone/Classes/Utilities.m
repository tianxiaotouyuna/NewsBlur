//
//  Utilities.m
//  NewsBlur
//
//  Created by Samuel Clay on 10/17/11.
//  Copyright (c) 2011 NewsBlur. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities

static NSMutableDictionary *imageCache;

+ (void)saveImage:(UIImage *)image feedId:(NSString *)filename {
    if (!imageCache) {
        imageCache = [[NSMutableDictionary dictionary] retain];
    }
    
    // Save image to memory-based cache, for performance when reading.
//    NSLog(@"Saving %@", [imageCache allKeys]);
    [imageCache setObject:image forKey:filename];
}

+ (UIImage *)getImage:(NSString *)filename {
    UIImage *image;
    image = [imageCache objectForKey:filename];
    
    if (!image) {
        // Image not in cache, search on disk.
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cacheDirectory = [paths objectAtIndex:0];
        NSString *path = [cacheDirectory stringByAppendingPathComponent:filename];
        
        image = [UIImage imageWithContentsOfFile:path];
    }
    
    if (image) {  
        return image;
    } else {
        return [UIImage imageNamed:@"world.png"];
    }
}

+ (void)saveimagesToDisk {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
    
    dispatch_async(queue, [[^{
        for (NSString *filename in [imageCache allKeys]) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *cacheDirectory = [paths objectAtIndex:0];
            NSString *path = [cacheDirectory stringByAppendingPathComponent:filename];
            
            // Save image to disk
            UIImage *image = [imageCache objectForKey:filename];
            [UIImageJPEGRepresentation(image, 1.0) writeToFile:path atomically:YES];
        }
    } copy] autorelease]);
}

+ (NSURL *)convertToAbsoluteURL:(NSString *)url {
    NSString *firstTwoChars = [url substringToIndex:2];
    NSString *firstChar = [url substringToIndex:1];
    NSURL *imageURL;
    if ([firstTwoChars isEqualToString:@"//"]) {
        imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http:%@",
                                         url]];
    } else if ([firstChar isEqualToString:@"/"]) {
        imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@", 
                                         NEWSBLUR_URL, 
                                         url]];
    } else {
        imageURL = [NSURL URLWithString:url];
    }
    
    return imageURL;
}

@end
