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
    
    #warning add your own keys. If you don't know your keys visit http://myioslearning.blogspot.com/2016/08/gravity-forms-api-with-ios.html
    api_key = @"PUT_YOUR_KEY_HERE";
    api_private_key = @"PUT_YOUR_PRIVATE_KEY_HERE";
    
    [self getRequest];  //to call GET Request of GFAPI
   // [self getASingleEntry];  //to call GET Request to fetch a single entry from form
   // [self postRequest];  //to call POST Request of GFAPI

}

-(void)getRequest
{
    
    http_method = @"GET";
    route = @"forms/2/entries";  //This is the route which will be added next to the base url. Here I'm sayin GET forms with ID 1 entries. You should see what your form ID is.
    expires = @"1577923200";    //This is the UNIX time
    
    //Get the Signature
    NSString *signature = [self calculateSignaturewithAPIKey:api_key apiKeyPrivate:api_private_key httpMethod:http_method route:route andExpiresIn:expires];
    NSString *string = [NSString stringWithFormat:@"%@%@?api_key=%@&signature=%@&expires=%@",BaseURLString,route,api_key,signature,expires];
    //By default, only 10 results are retrieved.  If you have more entries in your form you should uncomment the line below and change the 20 to which ever number you want to get in one call.
    //NSString *string = [NSString stringWithFormat:@"%@%@?api_key=%@&signature=%@&expires=%@&paging[page_size]=20",BaseURLString,route,api_key,signature,expires];
    NSString *escapedPath = [string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager GET:escapedPath  parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        self.printJSONResponseTextView.backgroundColor = [UIColor greenColor];
        self.printJSONResponseTextView.textColor = [UIColor blackColor];
        self.printJSONResponseTextView.text = [NSString stringWithFormat:@"%@",responseObject];
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        self.printJSONResponseTextView.backgroundColor = [UIColor redColor];
        self.printJSONResponseTextView.text = [NSString stringWithFormat:@"Error: %@ READ THIS FOR HELP http://myioslearning.blogspot.com/2016/08/gravity-forms-api-with-ios.html and see Possible Errors",[error localizedDescription]];
    }];

}
-(void)getASingleEntry
{
    http_method = @"GET";
    route = @"forms/1/entries";
    expires = @"1577933200";
    
    NSString *signature = [self calculateSignaturewithAPIKey:api_key apiKeyPrivate:api_private_key httpMethod:http_method route:route andExpiresIn:expires];
    
    //We are going to retrive a value based on a text feild with ID 2 which is the email feild.
    NSString *searchparam = [NSString stringWithFormat:@"{\"field_filters\": [{\"key\": \"2\", \"value\" : \"umar@gameral.com\", \"operator\" : \"contains\"}]}"];
    NSString *string = [NSString stringWithFormat:@"%@%@?api_key=%@&signature=%@&expires=%@&search=%@",BaseURLString,route,api_key,signature,expires,searchparam];
    
    NSString *escapedPath = [string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSLog(@"URL is %@",escapedPath);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager GET:escapedPath  parameters:searchparam progress:nil success:^(NSURLSessionTask *task, id responseObject) {

        self.printJSONResponseTextView.backgroundColor = [UIColor greenColor];
        self.printJSONResponseTextView.textColor = [UIColor blackColor];
        self.printJSONResponseTextView.text = [NSString stringWithFormat:@"%@",responseObject];
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        self.printJSONResponseTextView.backgroundColor = [UIColor redColor];
        self.printJSONResponseTextView.text = [NSString stringWithFormat:@"Error: %@ READ THIS FOR HELP http://myioslearning.blogspot.com/2016/08/gravity-forms-api-with-ios.html and see Possible Errors",[error localizedDescription]];
    }];

}
-(void)postRequest
{
    http_method = @"POST";
    route = @"forms/1/submissions";
    //remember there is no expire time for this call
    //and there is no need to add signature.
    NSString *string = [NSString stringWithFormat:@"%@%@",BaseURLString,route];
    NSString *escapedPath = [string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    AFHTTPSessionManager* manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    
    //for example if your field ID is 1 you will write it as input_1 and similarly with 2 it'll be input_2 and so on. My form have 3 fields with ID's 1,2,3 so that is why I've used input_1 to input_3.
    
    #warning this code below might crash the app. This is just sample code. You need to carefully change it as per your own form. For more information visit http://myioslearning.blogspot.com/2016/08/gravity-forms-api-with-ios.html
    
    NSDictionary *params = @{@"input_1": self.name.text,
                             @"input_2": self.email.text,
                             @"input_3": self.password.text};
    
    NSMutableDictionary *modify = [NSMutableDictionary new];
    [modify  setObject:params forKey:@"input_values"];

    [manager POST:escapedPath parameters:modify progress:nil success:^(NSURLSessionTask *task, id responseObject)
     {
         self.printJSONResponseTextView.backgroundColor = [UIColor greenColor];
         self.printJSONResponseTextView.textColor = [UIColor blackColor];
         self.printJSONResponseTextView.text = [NSString stringWithFormat:@"%@",responseObject];
         
     } failure:^(NSURLSessionTask *operation, NSError *error) {
         self.printJSONResponseTextView.backgroundColor = [UIColor redColor];
         self.printJSONResponseTextView.text = [NSString stringWithFormat:@"Error: %@ READ THIS FOR HELP http://myioslearning.blogspot.com/2016/08/gravity-forms-api-with-ios.html and see Possible Errors",[error localizedDescription]];
     }];

}

- (NSString *)calculateSignaturewithAPIKey:(NSString *)apiKey apiKeyPrivate:(NSString *)apiKeyPrivate httpMethod:(NSString *)httpMethod route:(NSString *)theRoute andExpiresIn:(NSString *)expireTime {
    NSString *string_to_sign = [NSString stringWithFormat:@"%@:%@:%@:%@",apiKey,httpMethod,theRoute,expireTime];
    
    const char *cKey  = [apiKeyPrivate cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [string_to_sign cStringUsingEncoding:NSASCIIStringEncoding];
    
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    
    NSString *signature = [HMAC base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return signature;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
