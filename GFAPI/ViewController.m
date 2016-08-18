//
//  ViewController.m
//  GFAPI
//
//  Created by Talha on 8/11/16.
//  Copyright © 2016 MindGem Studios. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"    //Note if there is an error here that means you need to update pods. Open Terminal > $cd *Path to project* > $pod update
#import <CommonCrypto/CommonHMAC.h>
#include <CommonCrypto/CommonDigest.h>

static NSString * const BaseURLString = @"http://YOUR_DOMAIN.com/gravityformsapi/";  //Enter Your YOUR_DOMAIN name here
NSString *api_key;
NSString *api_private_key;
NSString *http_method;
NSString *route;
NSString *expires;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self getRequest];
}

-(void)getRequest
{
    api_key = @"PUT_YOUR_KEY_HERE";
    api_private_key = @"PUT_YOUR_PRIVATE_KEY_HERE";
    http_method = @"GET";
    route = @"forms/1/entries";  //This is the route which will be added next to the base url. Here I'm sayin GET forms with ID 1 entries. You should see what your form ID is.
    expires = @"1577923200";    //This is the UNIX time
    
    //SIGNATURE MAKING START
    NSString *string_to_sign = [NSString stringWithFormat:@"%@:%@:%@:%@",api_key,http_method,route,expires];
    
    const char *cKey  = [api_private_key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [string_to_sign cStringUsingEncoding:NSASCIIStringEncoding];
    
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    NSString *signature = [HMAC base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    //SIGNATURE MAKING ENDS
    [self authURLWithSignature:signature];

}

-(void)authURLWithSignature:(NSString *)signature
{
   // sample URL is http://mydomain.com/gravityformsapi/forms/1?api_key=fd144510ac&signature=Nj6zoDHF0wAxuFynQPFF29U3%2FEE%3D&expires=1424785599
    
    NSString *string = [NSString stringWithFormat:@"%@%@?api_key=%@&signature=%@&expires=%@",BaseURLString,route,api_key,signature,expires];
    //By default, only 10 results are retrieved.  If you have more entries in your form you should uncomment the line below and change the 20 to which ever number you want to get in one call.
    //NSString *string = [NSString stringWithFormat:@"%@%@?api_key=%@&signature=%@&expires=%@&paging[page_size]=20",BaseURLString,route,api_key,signature,expires];
    NSString *escapedPath = [string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager GET:escapedPath  parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        NSLog(@"Response Object");
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@ READ THIS FOR HELP http://myioslearning.blogspot.com/2016/08/gravity-forms-api-with-ios.html", [error localizedDescription]);
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
