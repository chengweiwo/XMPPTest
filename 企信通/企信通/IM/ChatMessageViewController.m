//
//  ChatMessageViewController.m
//  企信通
//
//  Created by apple on 13-12-4.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "ChatMessageViewController.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "ChatMessageCell.h"
#import "NSData+XMPP.h"

@interface ChatMessageViewController () <UITextFieldDelegate, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    // 查询结果控制器
    NSFetchedResultsController *_fetchedResultsController;
}

@property (weak, nonatomic) IBOutlet UITextField *inputText;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noInputTextConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

// 点击添加照片按钮
- (IBAction)clickAddPhoto;

@end

@implementation ChatMessageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 1. 利用通知中心监听键盘的变化（打开、关闭、中英文切换）
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    // 2. 初始化查询结果控制器
    [self setupFetchedResultsController];
}

#pragma mark - 初始化查询结果控制器
- (void)setupFetchedResultsController
{
    // 1. 实例化数据存储上下文
    NSManagedObjectContext *context = [[xmppDelegate xmppMessageArchivingCoreDataStorage] mainThreadManagedObjectContext];
    
    // 2. 定义查询请求
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    
    // 3. 定义排序
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    
    // 4. 定义查询条件(谓词，NSPredicate)
    // 查询来自与hello发给admin的消息
    NSLog(@"%@", [LoginUser sharedLoginUser].myJIDName);
    request.predicate = [NSPredicate predicateWithFormat:@"bareJidStr CONTAINS[cd] %@ AND streamBareJidStr CONTAINS[cd] %@", _bareJidStr, [LoginUser sharedLoginUser].myJIDName];
    [request setSortDescriptors:@[sort]];
    
    // 5. 实例化查询结果控制器
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    
    // 6. 设置代理
    _fetchedResultsController.delegate = self;
    
    // 7. 执行查询
    NSError *error = nil;
    if (![_fetchedResultsController performFetch:&error]) {
        NSLog(@"查询数据出错 - %@", error.localizedDescription);
    } else {
        [self scrollToTableBottom];
    }
}

#pragma mark - 查询结果控制器代理方法
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // 刷新表格
    [self.tableView reloadData];
    
    // 滚动到表格末尾
    [self scrollToTableBottom];
}

#pragma mark - 键盘边框大小变化
- (void)keyboardChangeFrame:(NSNotification *)notification
{
    // 根据跟踪发现，使用userInfo的UIKeyboardFrameEndUserInfoKey数据可以判断键盘的大小和目标位置
    
    // 1. 获取键盘的目标区域
    NSDictionary *info = notification.userInfo;
    CGRect rect = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration = [info[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    // 2. 根据rect的orgion.y可以判断键盘是开启还是关闭
    if (rect.origin.y == [UIScreen mainScreen].bounds.size.height) {
        // 关闭键盘
        _noInputTextConstraint.constant = 0.0;
    } else {
        // 打开键盘
        _noInputTextConstraint.constant = rect.size.height;
    }
    
    // 用自动布局系统实现动画，调整位置
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self scrollToTableBottom];
    }];
}

#pragma mark - UITextField代理方法
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // 关闭键盘
//    [textField resignFirstResponder];
    // 发送消息
    // 1. 取出文本并截断空白字符串
    NSString *str = [textField.text trimString];
    
    // 2. 实例化XMPPMessage，以便发送
    NSString *jidStr = _bareJidStr;
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:[XMPPJID jidWithString:jidStr]];
    
    [message addBody:str];
    
    [[xmppDelegate xmppStream] sendElement:message];
    
    return YES;
}

#pragma mark - 表格操作方法
#pragma mark 滚动到表格的末尾
- (void)scrollToTableBottom
{
    // 要选中滚动到最末一条记录
    // 1. 知道所有的记录行数
    id <NSFetchedResultsSectionInfo> info = _fetchedResultsController.sections[0];
    NSInteger count = [info numberOfObjects];
    
    if (count <= 0) {
        return;
    }
    
    // 2. 根据行数实例化indexPath
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(count - 1) inSection:0];
    // 3. 选中并滚动到末尾
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
}

#pragma mark - UITableView数据源方法
#pragma mark 表格行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> info = _fetchedResultsController.sections[section];
    
    return [info numberOfObjects];
}

#pragma mark 表格行
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *FromID = @"ChatFromCell";
    static NSString *ToID = @"ChatToCell";
    
    XMPPMessageArchiving_Message_CoreDataObject *message = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    ChatMessageCell *cell = nil;
    
    if (message.isOutgoing) {
        cell = [tableView dequeueReusableCellWithIdentifier:FromID];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:ToID];
    }
    
    // 设置单元格
//    [cell.messageButton setTitle:message.body forState:UIControlStateNormal];
    [cell setMessage:message.body isOutgoing:message.isOutgoing];
    
    if (message.isOutgoing) {
        cell.headImageView.image = self.myImage;
    } else {
        cell.headImageView.image = self.bareImage;
    }
    
    return cell;
}

#pragma mark 表格行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 提示，在此不能直接调用表格行控件的高度，否则会死循环
    // 1. 取出显示行的文本
    XMPPMessageArchiving_Message_CoreDataObject *message = [_fetchedResultsController objectAtIndexPath:indexPath];
    NSString *str = message.body;
    
    // 2. 计算文本的占用空间
    CGSize size = [str sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(180, 10000.0)];
    
    // 3. 根据文本空间计算行高
    if (size.height + 50.0 > 80.0) {
        return size.height + 50.0;
    }
    
    return 80;
}

#pragma mark - UIImagePicker代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // 1. 获取选择的图像
    UIImage *image = info[UIImagePickerControllerEditedImage];
    
    // 2. 关闭照片选择器
    [self dismissViewControllerAnimated:YES completion:^{
        // 3. 发送图像(同步发送)
        
//        // 1) 实例化一个XMPPMessage
//        XMPPMessage *message = [XMPPMessage messageWithType:@"myImageData" to:[XMPPJID jidWithString:_bareJidStr]];
//        
//        // 2) 数据转换
//        NSData *data = UIImagePNGRepresentation(image);
//        NSString *msgStr = [data base64Encoding];
//    
//        // 3) 设置内容
//        NSXMLElement *imageElement = [NSXMLElement elementWithName:@"imageData" stringValue:msgStr];
//        [message addChild:imageElement];
//        
//        // 4) 发送消息
//        [[xmppDelegate xmppStream] sendElement:message];
        
        // Socket数据传输
        // 1） 实例化Socket
        // 强调！！！一定要带上resource【计算机的名称】
        XMPPJID *toJID = [XMPPJID jidWithString:_bareJidStr resource:@"teacher"];
        
        TURNSocket *socket = [[TURNSocket alloc] initWithStream:[xmppDelegate xmppStream] toJID:toJID];
        
        [[xmppDelegate socketList] addObject:socket];
        
        // 3) 添加代理
        [socket startWithDelegate:xmppDelegate delegateQueue:dispatch_get_main_queue()];
    }];
}

#pragma mark - Actions
#pragma mark 点击添加照片按钮
- (IBAction)clickAddPhoto
{
    // 如何判断摄像头可用
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.delegate = self;
        
        [self presentViewController:picker animated:YES completion:nil];
        
    } else {
        NSLog(@"摄像头不可用");
    }
}

@end
