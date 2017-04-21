//
//  ViewController.m
//  FVid
//
//  Created by RahuulMiishra on 17/02/17.
//  Copyright © 2017 RahuulMiishra. All rights reserved.
//

#import "ViewController.h"
#import "Utility.h"
#import <Photos/Photos.h>


#define FAILED_MESSAGE @"Failed to download."
#define SUCCESS_MESSAGE @"Download successfully. Video moved to camera roll."

@interface ViewController ()
{
    NSString *_userURL;
    
    UIActivityIndicatorView * _activityIndicator;
    TypeOfParsing _typeOfParsing;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = YES;
    [self createActivityIndicatorView];

}


- (void)parseUIRL
{
    [_activityIndicator startAnimating];
    //Step 1: Get the user url
    _userURL = [UIPasteboard generalPasteboard].string;
    
    //Step 2: Convert it into mobile website
    _userURL = [_userURL stringByReplacingOccurrencesOfString:@"https://www" withString:@"https://m"];
    
    //Step 3: Find source code and video url
    NSString *videoURL ;
    
    
    if(_typeOfParsing == GIFParsing)
       videoURL =  [Utility getGifURLForUserURL:_userURL];
    else
        videoURL = [Utility getVideoURLForUserURL:_userURL];
    
    if(!videoURL)
    {
       //show alert
        [_activityIndicator stopAnimating];
        NSLog(@"Please try again with different url");
        [self showAlertWithMessage:@"Please copy video url again and then come back."];
    }
    else
    {
         //Now at this point we have the video url but it encodeded we have to decode it.
       
        NSString *videoURLDecoded;
        
         if(_typeOfParsing == GIFParsing)
             videoURLDecoded = [Utility extractGIFUrlFromURL:videoURL];
         else
             videoURLDecoded =  [Utility getDecodedURL:videoURL];
        
        
        videoURLDecoded =  [Utility getDecodedURL:videoURLDecoded];//Remove html entities
        [self downloadVideoForURLString:videoURLDecoded];

        
    }
    
}



-(void)downloadVideoForURLString:(NSString *)urlToDownload
{
    [_activityIndicator startAnimating];
    self.view.userInteractionEnabled = NO;
    //download the file in a seperate thread.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"Downloading Started");
      
        NSURL  *url = [NSURL URLWithString:urlToDownload];
        NSData *urlData = [NSData dataWithContentsOfURL:url];
        if ( urlData )
        {
            NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString  *documentsDirectory = [paths objectAtIndex:0];
            
            
            NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,[Utility fileNameForParsingType:_typeOfParsing]];
            
            NSLog(@"%@",filePath);
            
            //saving is done on main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                [urlData writeToFile:filePath atomically:YES];
                [_activityIndicator stopAnimating];
                self.view.userInteractionEnabled = YES;
                [self showAlertWithMessage:SUCCESS_MESSAGE];
                [self manageCameraRollForFile:filePath];
                NSLog(@"File Saved !");
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_activityIndicator stopAnimating];
                self.view.userInteractionEnabled = YES;

                [self showAlertWithMessage:FAILED_MESSAGE];
            });
        }
        
    });
}


- (void)manageCameraRollForFile:(NSString *)filePath
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    if (status == PHAuthorizationStatusAuthorized) {
        // Access has been granted.
        
        if(_typeOfParsing == GIFParsing)
        {
                        NSData *data = [NSData dataWithContentsOfFile:filePath];
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
                [[PHAssetCreationRequest creationRequestForAsset] addResourceWithType:PHAssetResourceTypePhoto data:data options:options];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                NSLog(@"：%d",success);
            }];
        }
        else
        {
         UISaveVideoAtPathToSavedPhotosAlbum(filePath, nil, nil, nil);
        }
        
       
    }
    
    else if (status == PHAuthorizationStatusDenied) {
        // Access has been denied.
    }
    
    else if (status == PHAuthorizationStatusNotDetermined) {
        
        // Access has not been determined.
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
            if (status == PHAuthorizationStatusAuthorized) {
                
                [self manageCameraRollForFile:filePath];
                // Access has been granted.
            }
            
            else {
                // Access has been denied.
            }
        }];
    }
    
    else if (status == PHAuthorizationStatusRestricted) {
        // Restricted access - normally won't happen.
    }
}


- (void)createActivityIndicatorView
{
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicator.center = CGPointMake(self.view.center.x, self.view.center.y-120);
    _activityIndicator.color = [UIColor blueColor];
    _activityIndicator.hidesWhenStopped = YES;
    
    [self.view addSubview:_activityIndicator];
}


- (void)showAlertWithMessage:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"F-Save" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        // Ok action example
    }];
  
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}


- (IBAction)userPressedVideo:(id)sender {
    
    _typeOfParsing = VideoParsing;
    [self parseUIRL];
}


- (IBAction)userPressedGIF:(id)sender {
    
    _typeOfParsing = GIFParsing;
     [self parseUIRL];
}
@end
