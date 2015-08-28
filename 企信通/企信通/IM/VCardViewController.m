//
//  VCardViewController.m
//  企信通
//
//  Created by apple on 13-11-30.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "VCardViewController.h"
#import "AppDelegate.h"
#import "XMPPvCardTemp.h"
#import "LoginUser.h"
#import "NSString+Helper.h"

#import "EditVCardViewController.h"

@interface VCardViewController () <EditVCardViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>
{
    // 文本标签的标题数组
    NSArray *_titlesArray;
    // 文本标签数组
    NSArray *_titleLablesArray;
}

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameText;
@property (weak, nonatomic) IBOutlet UILabel *jidText;
@property (weak, nonatomic) IBOutlet UILabel *orgNameText;
@property (weak, nonatomic) IBOutlet UILabel *orgUnitText;
@property (weak, nonatomic) IBOutlet UILabel *titleText;
@property (weak, nonatomic) IBOutlet UILabel *photoNumberText;
@property (weak, nonatomic) IBOutlet UILabel *emailText;

@end

@implementation VCardViewController

#pragma mark - AppDelegate 的助手方法
- (AppDelegate *)appDelegate
{
    return [[UIApplication sharedApplication] delegate];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // 1. 实例化标题数组
    _titlesArray = @[@[@"头像", @"姓名", @"JID"], @[@"公司", @"部门", @"职务", @"电话", @"邮件"]];
    _titleLablesArray = @[@[_jidText, _nickNameText, _jidText],
                          @[_orgNameText, _orgUnitText, _titleText, _photoNumberText, _emailText]];
    
    [self setupvCard];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(NSIndexPath *)indexPath
{
    EditVCardViewController *controller = segue.destinationViewController;
    
    // 1. 设置标题
    controller.contentTitle = _titlesArray[indexPath.section][indexPath.row];
    // 2. 传递内容标签
    controller.contentLable = _titleLablesArray[indexPath.section][indexPath.row];
    // 3. 设置代理
    controller.delegate = self;
}

#pragma mark - 电子名片处理方法
#pragma mark - 设置电子名片
- (void)setupvCard
{
    // 1. 获取当前账号的电子名片
    XMPPvCardTemp *myCard = [[[self appDelegate] xmppvCardModule] myvCardTemp];
    
    // 2. 判断当前账号是否有电子名片
    if (myCard == nil) {
        // 1. 新建电子名片
        myCard = [XMPPvCardTemp vCardTemp];
        // 2. 设置昵称
        myCard.nickname = [[LoginUser sharedLoginUser] userName];
    }

    // 设置jid
    if (myCard.jid == nil) {
        myCard.jid = [XMPPJID jidWithString:[LoginUser sharedLoginUser].myJIDName];
    }
    
    // 更新或保存电子名片
    [[[self appDelegate] xmppvCardModule] updateMyvCardTemp:myCard];
    
    // 使用myCard中的信息设置界面UI显示
    // 1) 照片
    NSData *photoData = [[xmppDelegate xmppvCardAvatarModule] photoDataForJID:myCard.jid];
    if (photoData) {
        _headImageView.image = [UIImage imageWithData:photoData];
    }
    // 2) 用户名
    _nickNameText.text = myCard.nickname;
    // 3) JID
    _jidText.text = [myCard.jid full];
    // 4) 公司
    _orgNameText.text = myCard.orgName;
    // 5) 部门
    if (myCard.orgUnits) {
        _orgUnitText.text = myCard.orgUnits[0];
    }
    // 6) 职务
    _titleText.text = myCard.title;
    // 7) 电话
    _photoNumberText.text = myCard.note;
    // 8) 电子邮件
    _emailText.text = myCard.mailer;
}

#pragma mark - 更新电子名片
// 注释：此处代码有点偷懒，不管字段是否更改，都一次性保存所有字段内容
- (void)savevCard
{
    // 1. 获取电子名片
    XMPPvCardTemp *myCard = [[[self appDelegate] xmppvCardModule] myvCardTemp];
    
    // 2. 设置名片内容
    myCard.photo = UIImagePNGRepresentation(_headImageView.image);
    myCard.nickname = [_nickNameText.text trimString];
    myCard.orgName = [_orgNameText.text trimString];
    myCard.orgUnits = @[[_orgUnitText.text trimString]];
    myCard.title = [_titleText.text trimString];
    myCard.note = [_photoNumberText.text trimString];
    myCard.mailer = [_emailText.text trimString];
    
    // 3. 保存电子名片
    [[[self appDelegate] xmppvCardModule] updateMyvCardTemp:myCard];
}

#pragma mark - 注销用户登录
- (IBAction)logout:(id)sender
{
    [[self appDelegate] logout];
}

#pragma mark - UITableView代理方法
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 1. 取出用户点击的cell
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    // 2. 判断cell.tag，如果==1，跳转
    if (cell.tag == 1) {
        [self performSegueWithIdentifier:@"EditVCardSegue" sender:indexPath];
    } else if (cell.tag == 2) {
        // 让用户选择照片来源
        // * 用相机作为暗示按钮可以获取到更多的真实有效的照片
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"选择照片", nil];
        
        [sheet showInView:self.view];
    }
}

#pragma mark - 编辑电子名片视图控制器代理方法
- (void)editVCardViewControllerDidFinished
{
    [self savevCard];
}

#pragma mark - ActionSheet代理方法
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 2) {
        return;
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];

    // 1. 设置照片源，提示在模拟上不支持相机！
    if (buttonIndex == 0) {
        [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
    } else {
        [picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
    // 2. 允许编辑
    [picker setAllowsEditing:YES];
    // 3. 设置代理
    [picker setDelegate:self];
    // 4. 显示照片选择控制器
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - 照片选择代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // 1. 设置头像
    _headImageView.image = info[UIImagePickerControllerEditedImage];
    // 2. 保存名片
    [self savevCard];
    
    // 3. 关闭照片选择器
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
