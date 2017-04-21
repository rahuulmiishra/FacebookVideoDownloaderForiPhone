//
//  Utility.h
//  FVid
//
//  Created by RahuulMiishra on 24/02/17.
//  Copyright © 2017 RahuulMiishra. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum  typeOfParsing
{
  GIFParsing,
    VideoParsing
    
}TypeOfParsing;

@interface Utility : NSObject

+ (NSString *)getVideoURLForUserURL:(NSString *)userURL;
+ (NSString *)getGifURLForUserURL:(NSString *)userURL;
+ (NSString *)getDecodedURL:(NSString *)videoURL;
+ (NSString *)extractGIFUrlFromURL:(NSString*)tempURL;
+ (NSString *)fileNameForParsingType:(TypeOfParsing)parsingType;
@end
