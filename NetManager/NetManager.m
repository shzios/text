//
//  NetManager.m
//



#import "NetManager.h"
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVAssetExportSession.h>
#import <AVFoundation/AVMediaFormat.h>



@interface NetManager()


@end

static NSMutableArray *tasks;
@implementation NetManager

+ (instancetype)shareNetManager
{
    static NetManager *_intance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        if (_intance == nil)
        {
            _intance = [[NetManager alloc] init];
        }
    });
    return _intance;
}

- (void)getRequestWithUrl:(NSString *)url Finsh:(HZResponseSuccess)requestSucBlock fail:(HZResponseFail)requestFailBlock
{
      //    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    //    manager.requestSerializer.timeoutInterval = 10.0f;
    //    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    [manager GET:url parameters:nil progress: nil success:^(NSURLSessionDataTask * _Nonnull task, id data) {
        if (data){
            requestSucBlock(data);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (requestFailBlock)
        {
            requestFailBlock(error);
        }
    }];

}

- (void)dataGetRequestWithUrl:(NSString *)url Finsh:(HZResponseSuccess)requestSucBlock fail:(HZResponseFail)requestFailBlock
{

    //    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    //    manager.requestSerializer.timeoutInterval = 10.0f;
    //    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (responseObject != nil) {
            requestSucBlock(responseObject);
        }else{
            requestFailBlock(error);
        }
    }];
    [dataTask resume];
}

- (void)postRequestWithDic:(NSDictionary *)dic Finsh:(HZResponseSuccess)finsh fail:(HZResponseFail)fail Url:(NSString *)url
{

    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:url parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (finsh) {
            finsh(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error) {
            fail(error);
        }
    }];
}

/*!
 *  上传图片(多图)
 *
 *  @param operations   上传图片预留参数---视具体情况而定 可移除
 *  @param imageArray   上传的图片数组
 *  @parm width      图片要被压缩到的宽度
 *  @param urlString    上传的url
 *  @param successBlock 上传成功的回调
 *  @param failureBlock 上传失败的回调
 *  @param progress     上传进度
 */
+ (HZURLSessionTask *)uploadImageWithUrlString:(NSString *)urlString
                                       parameters:(NSDictionary *)parameters
                                   withImageArray:(NSArray *)imageArray
                                 withSuccessBlock:(HZResponseSuccess)successBlock
                                  withFailurBlock:(HZResponseFail)failureBlock
                               withUpLoadProgress:(HZUploadProgress)progress{
    if (urlString == nil)
    {
        return nil;
    }
    /*! 检查地址中是否有中文 */
    NSString *URLString = [NSURL URLWithString:urlString] ? urlString : [self strUTF8Encoding:urlString];
    HZURLSessionTask *sessionTask = nil;
    sessionTask = [[self shareNetManager] POST:URLString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        /*! 出于性能考虑,将上传图片进行压缩 */
        for (int i = 0; i < imageArray.count; i++){
            /*! image的压缩方法 */
            UIImage *resizedImage;
            resizedImage = imageArray[i];
        /*! 此处压缩方法是jpeg格式是原图大小的0.8倍，要调整大小的话，就在这里调整就行了还是原图等比压缩 */
            NSData *imgData = UIImageJPEGRepresentation(resizedImage, 0.8);
            /*! 拼接data */
            if (imgData != nil)
            {   // 图片数据不为空才传递
                [formData appendPartWithFileData:imgData name:[NSString stringWithFormat:@"picflie%ld",(long)i] fileName:@"image.png" mimeType:@" image/jpeg"];
            }
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress)
        {
            progress(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (successBlock)
        {
            successBlock(responseObject);
        }
        [[self tasks] removeObject:sessionTask];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (failureBlock)
        {
            failureBlock(error);
        }
        [[self tasks] removeObject:sessionTask];
    }];
    if (sessionTask)
    {
        [[self tasks] addObject:sessionTask];
    }
    return sessionTask;
}
+ (NSMutableArray *)tasks
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"创建数组");
        tasks = [[NSMutableArray alloc] init];
    });
    return tasks;
}

/*!
 *  视频上传
 *
 *  @param operations   上传视频预留参数---视具体情况而定 可移除
 *  @param videoPath    上传视频的本地沙河路径
 *  @param urlString     上传的url
 *  @param successBlock 成功的回调
 *  @param failureBlock 失败的回调
 *  @param progress     上传的进度
 */
+ (void)uploadVideoWithUrlString:(NSString *)urlString
                         parameters:(NSDictionary *)parameters
                      withVideoPath:(NSString *)videoPath
                   withSuccessBlock:(HZResponseSuccess)successBlock
                   withFailureBlock:(HZResponseFail)failureBlock
                 withUploadProgress:(HZUploadProgress)progress{
    /*! 获得视频资源 */
    AVURLAsset *avAsset = [AVURLAsset assetWithURL:[NSURL URLWithString:videoPath]];
    /*! 压缩 */
    //    NSString *const AVAssetExportPreset640x480;
    //    NSString *const AVAssetExportPreset960x540;
    //    NSString *const AVAssetExportPreset1280x720;
    //    NSString *const AVAssetExportPreset1920x1080;
    //    NSString *const AVAssetExportPreset3840x2160;
    AVAssetExportSession  *  avAssetExport = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPreset640x480];
    /*! 创建日期格式化器 */
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
    /*! 转化后直接写入Library---caches */
    NSString *  videoWritePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:[NSString stringWithFormat:@"/output-%@.mp4",[formatter stringFromDate:[NSDate date]]]];
    avAssetExport.outputURL = [NSURL URLWithString:videoWritePath];
    avAssetExport.outputFileType =  AVFileTypeMPEG4;
    [avAssetExport exportAsynchronouslyWithCompletionHandler:^{
        switch ([avAssetExport status]) {
            case AVAssetExportSessionStatusCompleted:
            {
                [[self shareNetManager] POST:urlString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                    //获得沙盒中的视频内容
                    [formData appendPartWithFileURL:[NSURL fileURLWithPath:videoWritePath] name:@"write you want to writre" fileName:videoWritePath mimeType:@"video/mpeg4" error:nil];
                } progress:^(NSProgress * _Nonnull uploadProgress) {
                    if (progress)
                    {
                        progress(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
                    }
                    
                } success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable responseObject) {
                    if (successBlock)
                    {
                        successBlock(responseObject);
                    }
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    
                    if (failureBlock)
                    {
                        failureBlock(error);
                    }
                }];
                
                break;
            }
            default:
                break;
        }
    }];
    
}

#pragma mark - ***** 文件下载
/*!
 *  文件下载
 *
 *  @param operations   文件下载预留参数---视具体情况而定 可移除
 *  @param savePath     下载文件保存路径
 *  @param urlString        请求的url
 *  @param successBlock 下载文件成功的回调
 *  @param failureBlock 下载文件失败的回调
 *  @param progress     下载文件的进度显示
 */
+ (HZURLSessionTask *)downLoadFileWithUrlString:(NSString *)urlString
                                        parameters:(NSDictionary *)parameters
                                      withSavaPath:(NSString *)savePath
                                  withSuccessBlock:(HZResponseSuccess)successBlock
                                  withFailureBlock:(HZResponseFail)failureBlock
                              withDownLoadProgress:(HZDownloadProgress)progress{
    if (urlString == nil)
    {
        return nil;
    }
    NSURLRequest *downloadRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    HZURLSessionTask *sessionTask = nil;
    sessionTask = [[self shareNetManager] downloadTaskWithRequest:downloadRequest progress:^(NSProgress * _Nonnull downloadProgress) {
        /*! 回到主线程刷新UI */
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progress)
            {
                progress(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
            }
        });
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        if (!savePath)
        {
            NSURL *downloadURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
            return [downloadURL URLByAppendingPathComponent:[response suggestedFilename]];
        }
        else
        {
            return [NSURL fileURLWithPath:savePath];
        }
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        [[self tasks] removeObject:sessionTask];
        if (error == nil)
        {
            if (successBlock)
            {
                /*! 返回完整路径 */
                successBlock([filePath path]);
            }
            else
            {
                if (failureBlock)
                {
                    failureBlock(error);
                }
            }
        }
    }];
    
    /*! 开始启动任务 */
    [sessionTask resume];
    
    if (sessionTask)
    {
        [[self tasks] addObject:sessionTask];
    }
    return sessionTask;
}

#pragma mark - ***** 开始监听网络连接
/*!
 *  开启网络监测
 */
+ (void)startNetWorkMonitoring
{
    // 1.获得网络监控的管理者
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    // 当使用AF发送网络请求时,只要有网络操作,那么在状态栏(电池条)wifi符号旁边显示  菊花提示
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    // 2.设置网络状态改变后的处理
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        // 当网络状态改变了, 就会调用这个block
        switch (status)
        {
            case AFNetworkReachabilityStatusUnknown: // 未知网络
                [NetManager shareNetManager].netWorkStatus = HZNetworkStatusUnknown;
                break;
            case AFNetworkReachabilityStatusNotReachable: // 没有网络(断网)
                [NetManager shareNetManager].netWorkStatus = HZNetworkStatusNotReachable;
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN: // 手机自带网络
              [NetManager shareNetManager].netWorkStatus = HZNetworkStatusReachableViaWWAN;
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi: // WIFI
               [NetManager shareNetManager].netWorkStatus = HZNetworkStatusReachableViaWiFi;
                break;
        }
    }];
    [manager startMonitoring];
}


+ (NSString *)strUTF8Encoding:(NSString *)str
{
    /*! ios9适配的话 打开第一个 */
    return [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
    
}




@end
