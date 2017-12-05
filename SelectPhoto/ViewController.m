//
//  ViewController.m
//  SelectPhoto
//
//  Created by hao on 2017/11/15.
//  Copyright © 2017年 hao. All rights reserved.
//

#import "ViewController.h"
#import <Photos/Photos.h>
@interface ViewController ()<UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *myImange;
-(PHAssetCollection *)createdCollection;//创建相册
-(PHFetchResult<PHAsset *>*)createdPhasset;//添加相片
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(iOS 11.1,*)) {
        NSLog(@"IOS11.1以上！！");
    }else{
        NSLog(@"ios 11.1以下");
    }
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(PHAssetCollection *)createdCollection{
    NSError *error = nil;
    NSString *appName = [NSBundle mainBundle].infoDictionary[(NSString*)kCFBundleNameKey];
    PHFetchResult<PHAssetCollection *>*collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    PHAssetCollection *createdCollection = nil;
    for (PHAssetCollection *collection in collections) {
        if ([collection.localizedTitle isEqualToString:appName]) {
            return collection;
        }
    }
    __block NSString *createdCollectionId = nil;
    
        [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
            createdCollectionId = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:appName].placeholderForCreatedAssetCollection.localIdentifier;
            
        } error:&error] ;
    if (error) {
        //相册创建失败，返回nil；
        return nil;
    }
    createdCollection = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[createdCollectionId] options:nil].firstObject;
    
    return createdCollection;

}
-(PHFetchResult<PHAsset *>*)createdPhasset{
    NSError *error = nil;
    __block NSString *assetID = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        assetID = [PHAssetChangeRequest creationRequestForAssetFromImage:self.myImange.image].placeholderForCreatedAsset.localIdentifier;
    } error:&error];
    
    if (error) return nil;
   
    return [PHAsset fetchAssetsWithLocalIdentifiers:@[assetID] options:nil];
}
- (IBAction)saveImage {
    PHAuthorizationStatus oldStatus = [PHPhotoLibrary authorizationStatus];
    
    // 请求\检查访问权限 :
    // 如果用户还没有做出选择，会自动弹框，用户对弹框做出选择后，才会调用block
    // 如果之前已经做过选择，会直接执行block
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == PHAuthorizationStatusDenied) { // 用户拒绝当前App访问相册
                if (oldStatus != PHAuthorizationStatusNotDetermined) {
//                    XMGLog(@"提醒用户打开开关")
                }
            } else if (status == PHAuthorizationStatusAuthorized) { // 用户允许当前App访问相册
                [self saveImageAction];
            } else if (status == PHAuthorizationStatusRestricted) { // 无法访问相册
//                [SVProgressHUD showErrorWithStatus:@"因系统原因，无法访问相册！"];
            }
        });
    }];
}
-(void)saveImageAction{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        NSLog(@"%ld",status);
        switch (status) {
            case 0:
                
                break;
                
            default:
                break;
        }
    }];
    //获取相片
    PHFetchResult <PHAsset *>*createdPhasset = self.createdPhasset;
    if (createdPhasset == nil) {
        NSLog(@"保存图片失败！");
        return;
    }else{
        NSLog(@"保存相片成功！");
    }
    //获取相册
    PHAssetCollection *createdCollection = self.createdCollection;
    if (createdCollection == nil) {
        NSLog(@"创建或者获取相册失败！");
        return;
    }else{
        NSLog(@"创建相册成功！");
    }
    
    
    //1,保存图片到系统相册
       NSError *error = nil;
       [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
            PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:createdCollection];
            [request insertAssets:createdPhasset atIndexes:[NSIndexSet indexSetWithIndex:0]];
//           [request addAssets:createdPhasset];
           
       } error:&error] ;
    if (error) {
        NSLog(@"插入图片失败！");
    }else{
        NSLog(@"插入图片成功！");
    }
        /*
        if (error) {
            UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"保存失败！" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alertView addAction:cancel];
            [self presentViewController:alertView animated:YES completion:nil];
        }else{
            UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"保存成功！" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alertView addAction:cancel];
            [self presentViewController:alertView animated:YES completion:nil];
        }
    */
    

//    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
//
//    } completionHandler:^(BOOL success, NSError * _Nullable error) {
//
//    }];
}

- (IBAction)button {
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:^{
        
    }];

}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [self dismissViewControllerAnimated:picker completion:nil];
    self.myImange.image = info[UIImagePickerControllerOriginalImage];
}

@end
