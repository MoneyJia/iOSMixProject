#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@interface NSBundle (RYInfo)
+ (NSArray <Class> *)yj_bundleOwnClassesInfo;
+ (NSArray <NSString *> *)yj_bundleAllClassesInfo;
+ (NSArray <NSString *>* )ry_bundleAllMethName;
NS_ASSUME_NONNULL_END
- (void)sp_getLoginState;
- (void)sp_getMediaData;
@end
