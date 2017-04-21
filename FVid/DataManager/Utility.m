//
//  Utility.m
//  FVid
//
//  Created by RahuulMiishra on 24/02/17.
//  Copyright © 2017 RahuulMiishra. All rights reserved.
//

#import "Utility.h"
#import "TFHpple.h"
@implementation Utility


+ (NSString *)getVideoURLForUserURL:(NSString *)userURL
{
    NSData  * data      = [NSData dataWithContentsOfURL:[NSURL URLWithString:userURL]];
    
    
    NSString* myString;
    myString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    
    
    TFHpple * doc       = [[TFHpple alloc] initWithHTMLData:data];
    
  //  NSArray * elements  = [doc searchWithXPathQuery:@"//div/div/div/div/div/div/div/div/div/div/div/a"];
    
    NSArray * elements  = [doc searchWithXPathQuery:@"//div/div/div/div/div/div/div/a"];
    
    
    if([elements count] == 0)
        return nil;
    
    TFHppleElement * element = [elements objectAtIndex:0];
    
    NSString *videoJunkURL = [element objectForKey:@"href"];
    
    NSString *videoURL = [videoJunkURL stringByReplacingOccurrencesOfString:@"/video_redirect/?src=" withString:@""];
    
    
    return videoURL;
}


+ (NSString *)getGifURLForUserURL:(NSString *)userURL
{
    NSData  * data      = [NSData dataWithContentsOfURL:[NSURL URLWithString:userURL]];
    
    TFHpple * doc       = [[TFHpple alloc] initWithHTMLData:data];
    
    NSString* myString;
    myString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    
    NSArray * elements  = [doc searchWithXPathQuery:@"//a/div/table/tbody/tr/td/img"];
    
    
    if([elements count] == 0)
        return nil;
    
    TFHppleElement * element = [elements objectAtIndex:0];
    
    NSString *gifJunkURL = [element objectForKey:@"src"];
    
    NSString *gifURL = [gifJunkURL stringByReplacingOccurrencesOfString:@"/video_redirect/?src=" withString:@""];
    
    return gifURL;
}


+ (NSString *)extractGIFUrlFromURL:(NSString*)tempURL
{
    NSRange indexofStarting = [tempURL rangeOfString:@"url="];
    
    NSString *str= [tempURL substringFromIndex:indexofStarting.location+indexofStarting.length];
    
    NSRange indexOfGif = [str rangeOfString:@".gif&"];
    
    str = [str substringToIndex:indexOfGif.location+4];
    
    return str;
}


+ (NSString *)getDecodedURL:(NSString *)videoURL
{
    //Setting colon
    NSString *videoURLDecoded = [videoURL stringByReplacingOccurrencesOfString:@"%3A" withString:@":"];
    
    //Setting farward slash
    videoURLDecoded = [videoURLDecoded stringByReplacingOccurrencesOfString:@"%2F" withString:@"/"];
    
    //Setting Question mark
    videoURLDecoded = [videoURLDecoded stringByReplacingOccurrencesOfString:@"%3F" withString:@"?"];
    
    //Setting =
    videoURLDecoded = [videoURLDecoded stringByReplacingOccurrencesOfString:@"%3D" withString:@"="];
    
    //Setting &
    videoURLDecoded = [videoURLDecoded stringByReplacingOccurrencesOfString:@"%26" withString:@"&"];
    
    return videoURLDecoded;

}


+ (NSString *)fileNameForParsingType:(TypeOfParsing)parsingType
{
    NSString *timestampString = [NSString stringWithFormat:@"%d",(int)[[NSDate date] timeIntervalSince1970]];
    
    if(parsingType == GIFParsing)
        timestampString = [NSString stringWithFormat:@"%@.gif",timestampString];
    else
         timestampString = [NSString stringWithFormat:@"%@.mp4",timestampString];
        
        
    return timestampString;
    
}


@end
