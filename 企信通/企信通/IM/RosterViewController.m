//
//  RosterViewController.m
//  企信通
//
//  Created by apple on 13-12-1.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "RosterViewController.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "ChatMessageViewController.h"

@interface RosterViewController () <NSFetchedResultsControllerDelegate, UIAlertViewDelegate>
{
    NSFetchedResultsController  *_fetchedResultsController;
    // 要删除的表格行索引
    NSIndexPath                 *_removedIndexPath;
}

@end

@implementation RosterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupFetchedController];
}

#pragma mark - 实例化NSFetchedResultsController
- (void)setupFetchedController
{
    // 1. 如果要针对CoreData做数据访问，无论怎么包装，都离不开NSManagedObjectContext
    // 实例化NSManagedObjectContext
    NSManagedObjectContext *context = [[xmppDelegate xmppRosterStorage] mainThreadManagedObjectContext];
    
    // 2. 实例化NSFetchRequest
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
    
    // 3. 实例化一个排序
    NSSortDescriptor *sort1 = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    NSSortDescriptor *sort2 = [NSSortDescriptor sortDescriptorWithKey:@"jidStr" ascending:YES];
    
    [request setSortDescriptors:@[sort1, sort2]];
    
    // 4. 实例化_fetchedResultsController
    _fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:@"sectionNum" cacheName:nil];
    
    // 5. 设置FetchedResultsController的代理
    [_fetchedResultsController setDelegate:self];
    
    // 6. 查询数据
    NSError *error = nil;
    if (![_fetchedResultsController performFetch:&error]) {
        NSLog(@"%@", error.localizedDescription);
    };
}

#pragma mark - NSFetchedResultsController代理方法
#pragma mark 控制器数据发生改变（因为Roster是添加了代理的）
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // 当数据发生变化时，重新刷新表格
    [self.tableView reloadData];
}

#pragma mark 准备Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(NSIndexPath *)indexPath
{
    // 判断是否跳往聊天界面
    if ([segue.identifier isEqualToString:@"ChatSegue"]) {
        ChatMessageViewController *controller = segue.destinationViewController;
        
        // 获取当前选中的用户
        XMPPUserCoreDataStorageObject *user = [_fetchedResultsController objectAtIndexPath:indexPath];
        
        controller.bareJidStr = user.jidStr;
        controller.bareImage = user.photo;
        // 取出对话方的头像数据
        NSData *barePhoto = [[xmppDelegate xmppvCardAvatarModule] photoDataForJID:user.jid];
        controller.bareImage = [UIImage imageWithData:barePhoto];
        
        NSString *myStr = [LoginUser sharedLoginUser].myJIDName;
        XMPPJID *myJID = [XMPPJID jidWithString:myStr];
        NSData *myPhoto = [[xmppDelegate xmppvCardAvatarModule] photoDataForJID:myJID];
        controller.myImage = [UIImage imageWithData:myPhoto];
    }
}

#pragma mark - UITableView数据源方法
#pragma mark 表格分组数量
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // 返回查询结果的分组数量
    return _fetchedResultsController.sections.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    // 1. 取出控制器中的所有分组
    NSArray *array = [_fetchedResultsController sections];
    // 2. 根据section值取出对应的分组信息对象
    id <NSFetchedResultsSectionInfo> info = array[section];
    
    NSString *stateName = nil;
    NSInteger state = [[info name] integerValue];
    
    switch (state) {
        case 0:
            stateName = @"在线";
            break;
        case 1:
            stateName = @"离开";
            break;
        case 2:
            stateName = @"下线";
            break;
        default:
            stateName = @"未知";
            break;
    }
    
    return stateName;
}

#pragma mark 对应分组中表格的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sectionData = [_fetchedResultsController sections];
    
    if (sectionData.count > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = sectionData[section];
        
        return [sectionInfo numberOfObjects];
    }
    
    return 0;
}

#pragma mark 加载用户头像
- (UIImage *)loadUserImage:(XMPPUserCoreDataStorageObject *)user
{
    // 1. 判断user中是否包含头像，如果有，直接返回
    if (user.photo) {
        return user.photo;
    }
    
    // 2. 如果没有头像，从用户的头像模块中提取用户头像
    NSData *photoData = [[xmppDelegate xmppvCardAvatarModule] photoDataForJID:user.jid];
    
    if (photoData) {
        return [UIImage imageWithData:photoData];
    }
    
    return [UIImage imageNamed:@"DefaultProfileHead"];
}

#pragma mark 表格行内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"RosterCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    
    // 设置单元格
    XMPPUserCoreDataStorageObject *user = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = user.displayName;
    cell.imageView.image = [self loadUserImage:user];
    
    return cell;
}

#pragma mark - 表格代理方法
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"ChatSegue" sender:indexPath];
}

/**
 *  要允许表格支持滑动删除，需要做两件事情
 *  1. 实现tableView:canEditRowAtIndexPath:方法，允许表格边界
 *  2. 实现tableView:commitEditingStyle:forRowAtIndexPath:，提交表格编辑
 */
#pragma mark 允许表格编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark 提交表格编辑
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 提示，如果没有另行执行，editingStyle就是删除
    if (UITableViewCellEditingStyleDelete == editingStyle) {
        /*
         在OC开发中，是MVC架构的，数据绑定到表格，如果要删除表格中的数据，应该：
         1. 删除数据
         2. 刷新表格
         
         注意不要直接删除表格行，而不删除数据。
         */
        // 删除数据
        // 1. 取出当前的用户数据
        XMPPUserCoreDataStorageObject *user = [_fetchedResultsController objectAtIndexPath:indexPath];
        
        // 发现问题，删除太快，没有任何提示，不允许用户后悔
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"是否删除好友" message:user.jidStr delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        
        // 记录住要删除的表格行索引
        _removedIndexPath = indexPath;
        
        [alert show];
    }
}

#pragma mark - UIAlertView代理方法
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 2. 将用户数据删除
    if (1 == buttonIndex) {
        // 用indexPathForSelectedRow是获取不到被删除的行的
        XMPPUserCoreDataStorageObject *user = [_fetchedResultsController objectAtIndexPath:_removedIndexPath];
        
        [[xmppDelegate xmppRoster] removeUser:user.jid];
    }
}

@end
