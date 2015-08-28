//
//  RosterTests.m
//  企信通
//
//  Created by apple on 13-12-3.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AppDelegate.h"
#import "XMPPvCardTemp.h"
#import "LoginUser.h"

@interface RosterTests : XCTestCase

@property (strong, nonatomic) AppDelegate *delegate;

@end

@implementation RosterTests

- (void)setUp
{
    [super setUp];
    
    _delegate = [[UIApplication sharedApplication] delegate];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testExample
{
    XMPPvCardTemp *myCard = [[_delegate xmppvCardModule] myvCardTemp];
    
    NSString *name1 = @"hello@teacher.local";
    
    BOOL exists1 = [[_delegate xmppRosterStorage] userExistsWithJID:[XMPPJID jidWithString:name1] xmppStream:[_delegate xmppStream]];
    
    NSLog(@"===== %d", exists1);
    
    NSString *name2 = @"hello1@teacher.local";
    
    BOOL exists2 = [[_delegate xmppRosterStorage] userExistsWithJID:[XMPPJID jidWithString:name2] xmppStream:[_delegate xmppStream]];
    
    NSLog(@"===== %d", exists2);
}

@end
