//
//  ViewController.m
//  FMDBTest
//
//  Created by Daniel Nestor Corbatta Barreto on 19/11/13.
//  Copyright (c) 2013 Daniel Nestor Corbatta Barreto. All rights reserved.
//

#import "ViewController.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "FMResultSet+OrderedDict.h"

@interface ViewController ()
@property (strong, nonatomic) NSMutableData* receivedData;
@property (strong, nonatomic) NSURLConnection *urlConnection;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self sendLogin];
}
- (void)sendLogin
    {
    NSError *jsonError;
    NSData *requestdata;
    //get login
    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [docPaths objectAtIndex:0];
    NSString *dbPath = [documentsDir   stringByAppendingPathComponent:@"tar.sqlite"];
    
    FMDatabase *database = [FMDatabase databaseWithPath:dbPath];
    [database open];
    FMResultSet *Loginresults = [database executeQuery:@"SELECT * FROM surveys"];
    NSMutableArray *results = [NSMutableArray array];
    while ([Loginresults next]) {
        [results addObject:[Loginresults resultOrderDictionary]];
    }
    requestdata = [NSJSONSerialization dataWithJSONObject:results options:0 error:&jsonError];
    [database close];
    
    NSURL *url = [NSURL URLWithString:@"http://www.viasur.cl/MyMapp/insert.php"];
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"%d", [requestdata length]] forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:requestdata];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
     
}
/*
- (void)sendFile
{
    NSString *fileName = @"tar.sqlite";
    NSString *directoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
    NSString *serverURL = @"http://www.viasur.cl/MyMapp/upload.php";
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    if (!fileData) {
        NSLog(@"Error: file error");
        return;
    }
    
    if (self.urlConnection) {
        [self.urlConnection cancel];
        self.urlConnection = nil;
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                    initWithURL:[NSURL URLWithString:serverURL]];
    [request setTimeoutInterval:30.0];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"0xKhTmLbOuNdArY";
    NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    
    
    // Header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; charset=%@; boundary=%@", charset,boundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    // Body
    NSMutableData *postData = [NSMutableData data];
    [postData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[[NSString stringWithFormat:@"Content-Disposition:form-data; name=\"file\"; filename=\"database.sqlite\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:fileData];
    [postData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:postData];
    
    self.urlConnection = [NSURLConnection connectionWithRequest:request delegate:self];
}
*/

- (void)sendFile
{
    NSString *fileName = @"tar.sqlite";
    NSString *directoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
    NSString *serverURL = @"http://www.viasur.cl/MyMapp/upload.php";
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    if (!fileData) {
        NSLog(@"Error: file error");
        return;
    }
    
    if (self.urlConnection) {
        [self.urlConnection cancel];
        self.urlConnection = nil;
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                    initWithURL:[NSURL URLWithString:serverURL]];
    [request setTimeoutInterval:30.0];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"780808070779786865757";
    
    /* Header */
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    /* Body */
    NSMutableData *postData = [NSMutableData data];
    [postData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[[NSString stringWithFormat:@"Content-Disposition:form-data; name=\"userfile\"; filename=\"database.sqlite\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:fileData];
    [postData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:postData];
    
    self.urlConnection = [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if (self.receivedData) {
        self.receivedData = nil;
    }
    self.receivedData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"finish requesting: %@", [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding]);
    self.urlConnection = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"requesting error: %@", [error localizedDescription]);
    self.urlConnection = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
