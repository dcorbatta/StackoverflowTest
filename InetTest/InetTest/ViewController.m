//
//  ViewController.m
//  InetTest
//
//  Created by Daniel Nestor Corbatta Barreto on 20/11/13.
//  Copyright (c) 2013 Daniel Nestor Corbatta Barreto. All rights reserved.
//

#import "ViewController.h"
#import "DHInet.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    DHInet * inet = [[DHInet alloc] init];
    
    NSArray * connections = [inet getTCPConnections];
    
    for (NSDictionary * connection in connections) {
        for (id key in connection) {
            NSLog(@"key: %@, value: %@ \n", key, [connection objectForKey:key]);
        }
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
