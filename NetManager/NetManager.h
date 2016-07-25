




#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "UIKit+AFNetworking.h"
#import <UIKit/UIKit.h>

typedef void( ^ HZResponseSuccess)(id response);
/*! 定义请求失败的block */
typedef void( ^ HZResponseFail)(NSError *error);
/*! 定义上传进度block */
typedef void( ^ HZUploadProgress)(int64_t bytesProgress,
                                  int64_t totalBytesProgress);
/*! 定义下载进度block */
typedef void( ^ HZDownloadProgress)(int64_t bytesProgress,
                                    int64_t totalBytesProgress);

typedef NSURLSessionTask HZURLSessionTask;
typedef NS_ENUM(NSInteger,HZNetworkStatus){
    /*! 未知网络 */
    HZNetworkStatusUnknown  = 100,
    /*! 没有网络 */
    HZNetworkStatusNotReachable,
    /*! 手机自带网络 */
    HZNetworkStatusReachableViaWWAN,
    /*! wifi */
    HZNetworkStatusReachableViaWiFi
};

/*！定义请求类型的枚举 */
typedef NS_ENUM(NSInteger,HZHttpRequestType){
    /*! get请求 */
    HZHttpRequestTypeGet = 100,
    /*! post请求 */
    HZHttpRequestTypePost,
    /*! put请求 */
    HZHttpRequestTypePut,
    /*! delete请求 */
    HZHttpRequestTypeDelete
};

/**
 *  typedef NS_ENUM(NSInteger, UIAlertControllerStyle) {
 UIAlertControllerStyleActionSheet = 0,
 UIAlertControllerStyleAlert
 }
 */



@interface NetManager : NSObject

@property(nonatomic,assign)HZNetworkStatus netWorkStatus;

+ (instancetype)shareNetManager;

- (void)getRequestWithUrl:(NSString *)url Finsh:(HZResponseSuccess)requestSucBlock fail:(HZResponseFail)requestFailBlock;

- (void)postRequestWithDic:(NSDictionary *)dic Finsh:(HZResponseSuccess)finsh fail:(HZResponseFail)fail Url:(NSString *)url;

- (void)dataGetRequestWithUrl:(NSString *)url Finsh:(HZResponseSuccess)requestSucBlock fail:(HZResponseFail)requestFailBlock;

+ (HZURLSessionTask *)downLoadFileWithUrlString:(NSString *)urlString
                                        parameters:(NSDictionary *)parameters
                                      withSavaPath:(NSString *)savePath
                                  withSuccessBlock:(HZResponseSuccess)successBlock
                                  withFailureBlock:(HZResponseFail)failureBlock
                              withDownLoadProgress:(HZDownloadProgress)progress;
+ (void)uploadVideoWithUrlString:(NSString *)urlString
                         parameters:(NSDictionary *)parameters
                      withVideoPath:(NSString *)videoPath
                   withSuccessBlock:(HZResponseSuccess)successBlock
                   withFailureBlock:(HZResponseFail)failureBlock
                 withUploadProgress:(HZUploadProgress)progress;
+ (HZURLSessionTask *)uploadImageWithUrlString:(NSString *)urlString
                                       parameters:(NSDictionary *)parameters
                                   withImageArray:(NSArray *)imageArray
                                 withSuccessBlock:(HZResponseSuccess)successBlock
                                  withFailurBlock:(HZResponseFail)failureBlock
                               withUpLoadProgress:(HZUploadProgress)progress;

+ (void)startNetWorkMonitoring;

//+ (NSString *)getImageUrl:(NSString *)url;

//- (void)dataGetWithParametersRequestWithUrl:(NSString *)url Finsh:(httpRequestSuc)requestSucBlock fail:(httpRequestFail)requestFailBlock Dictionary:(NSDictionary *)dict;
//
//- (void)sessionGet:(NSString *)url Finsh:(httpRequestSuc)requestSucBlock fail:(httpRequestFail)requestFailBlock Dictionary:(NSDictionary *)dict;


@end
