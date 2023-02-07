#import "NSBundle+RYInfo.h"
#import <objc/runtime.h>
#import <dlfcn.h>
#import <mach-o/ldsyms.h>
@implementation NSBundle (RYInfo)
+ (NSArray <NSString *>*)whiteList {
    return @[
        @"AppDelegate",
        @"AppBaseInfo"
    ];;
}
+ (NSArray <NSString *>*)whiteMethList {
    return @[
        @"awakeFromNib",
        @"mas_equalTo",
        @"layoutSubviews",
        @"cellHeightForIndexPath",
        @"NSURLSessionDelegate",
        @"NSURLSession",
        @"hideAnimated",
        @"numberOfSectionsInTableView",
        @"UITextView",
        @"endRefreshing",
        @"reloadData",
        @"addObject",
        @"removeAllObjects",
        @"imageNamed",
        @"popToRootViewControllerAnimated",
        @"isEqualToString",
        @"presentViewController",
        @"pushViewController",
        @"stringForKey",
        @"addObjectsFromArray",
        @"removeObjectAtIndex",
        @"lastObject",
        @"objectAtIndex",
        @"containsString",
        @"removeObjectsInArray",
        @"allObjects",
        @"insertObject",
        @"enumerateObjectsUsingBlock",
        @"objectEnumerator",
        @"reverseObjectEnumerator",
        @"firstObject",
        @"isRefreshing",
        @"insertObjects",
        @"registerClass",
        @"pansendReadReceiptMessage",
        @"isKindOfClass",
        @"mutableCopy",
        @"indexOfObject",
        @"allValues",
        @"reloadData",
        @"playAnimationp",
        @"listContainerView",
        @"reloadBanner",
        @"snp_updateConstraints",
        @"endRefreshing",
        @"updateConstraints",
        @"emptyDataSetSource",
        @"resizeTableHeaderViewHeight",
        @"tableHeaderView",
        @"beginRefreshing",
        @"resetNoMoreData",
        @"endRefreshingWithNoMoreData",
        @"deleteBackward",
        @"didSelectItemAt",
        @"emptyDataSetDelegate",
        @"pageTitleViewConfigure",
        @"pageTitleViewWithFrame",
        @"resetSelectedIndex",
        @"targetIndex",
        @"dictionary",
        @"postNotificationName",
        @"configure",
        @"backgroundColor",
        @"textColor",
        @"clearColor",
        @"removeFromSuperview",
        @"removeObject",
        @"dismissViewControllerAnimated",
        @"respondsToSelector",
        @"becomeFirstResponder",
        @"UITextField",
        @"keyWindow",
        @"popToRootViewController",
        @"reloadData",
        @"prepareForReuse",
        @"invalidateLayout",
        @"playing",
        @"layoutAttributesForItemAtIndexPath",
        @"layoutAttributesForElementsInRect",
        @"prepareLayout",
        @"contentView",
        @"addGestureRecognizer",
        @"integerValue",
        @"sizeThatFits",
        @"sd_setImageWithURL",
        @"attributedText",
        @"tableHeaderView",
        @"scramblergestureRecognizers",
        @"sizeToFit",
        @"updateUserInfo",
        @"floatValue",
        @"intrinsicContentSize",
        @"tintColorDidChange",
        @"objectForKey",
        @"priority",
        @"removeObserver",
        @"removeLastObject",
        @"appendPartWithFileData",
        @"fileName",
        @"mimeType",
    ];
}
+ (NSString *)getLogFilePath:(NSInteger)index{
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    documentsDir = [documentsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"log%ld.txt", index]];
    return documentsDir;
}
+ (void)saveToLocalText:(NSString *)info index:(NSInteger)index{
    NSString *documentsDir = [self getLogFilePath:index];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExit = [fileManager fileExistsAtPath:documentsDir];
    if (!isExit) {
        NSLog(@"log文件不存在");
        [fileManager createFileAtPath:documentsDir contents:nil attributes:nil];
    }
        NSError *error;
        NSString *content =[NSString stringWithContentsOfFile:documentsDir encoding:NSUTF8StringEncoding error:&error];
        if (!error) {
           NSLog(@"文件读取成功: %@",content);
        }else{
           NSLog(@"%@",error.localizedDescription);
        }
        if (content.length == 0 || [content isKindOfClass:[NSNull class]] || content == nil) {
            NSLog(@"文件中无数据");
        }else{
            info = [NSString stringWithFormat:@"%@\n%@",content,info];
        }
        BOOL res = [info writeToFile:documentsDir atomically:true encoding:NSUTF8StringEncoding error:nil];
        if (res) {
            NSLog(@"INFO写入成功");
        }else {
            NSLog(@"INFO写入失败");
        }
}
+ (NSArray<NSString *> *)ry_bundleAllMethName {
    NSArray <Class> * allClass = [NSBundle yj_bundleOwnClassesInfo];
    NSMutableSet *methNameArray = [NSMutableSet new];
    NSMutableArray *classNameArray = [NSMutableArray new];
    for (Class class in allClass) {
        [classNameArray addObject:NSStringFromClass(class)];
    }
    for (Class  class in allClass) {
        unsigned int methodCount =0;
        Method* methodList = class_copyMethodList(class, &methodCount);
        NSMutableSet *classMethdArray = [NSMutableSet new];
        u_int count;
        objc_property_t *properties  =class_copyPropertyList(class, &count);
        NSMutableArray *propertiesArray = [NSMutableArray new];
        for (int i = 0; i < count ; i++)
        {
            const char* propertyName =property_getName(properties[i]);
            [propertiesArray addObject: [NSString stringWithUTF8String: propertyName]];
        }
        for(int i=0;i<methodCount;i++) {
            Method temp = methodList[i];
            const char* name_s =sel_getName(method_getName(temp));
            int arguments = method_getNumberOfArguments(temp);
            const char* encoding =method_getTypeEncoding(temp);
            NSLog(@"方法名：%@,参数个数：%d,编码方式：%@",[NSString stringWithUTF8String:name_s],
                  arguments,
                  [NSString stringWithUTF8String:encoding]);
            NSString *methodName = [NSString stringWithUTF8String:name_s];
            methodName = [[methodName componentsSeparatedByString:@":"] firstObject];
            BOOL hasContent = false;
            for (NSString *content in propertiesArray) {
                if ([content containsString:methodName]) {
                    hasContent = true;
                }
            }
            for (NSString *content in classNameArray) {
                if ([content containsString:methodName]) {
                    hasContent = true;
                }
            }
            if ([self hasInWhiteMethedList:methodName] || hasContent) {
                continue;
            }
            [classMethdArray addObject:methodName];
        }
        [self hanleSetAndGet:classMethdArray];
        [methNameArray addObjectsFromArray:(NSArray *)classMethdArray];
        free(methodList);
    }
    NSArray *tmpArray = [methNameArray allObjects];
    __block NSInteger index = 0;
    [tmpArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx%3000 == 0) {
            index ++;
        }
        [self saveToLocalText:obj index:index];
    }];
    return tmpArray;
}
+ (void)hanleSetAndGet:(NSMutableSet <NSString *>*)array {
    NSMutableSet *setterArray = [NSMutableSet new];
    [array enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj hasPrefix:@"set"]) {
            [setterArray addObject:obj];
        }
    }];
    [array enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        [setterArray enumerateObjectsUsingBlock:^(id  _Nonnull subObj, BOOL * _Nonnull subStop) {
            if ([obj isEqualToString:subObj]) {
                [array removeObject:obj];
                NSMutableString *tmpStr = [NSMutableString stringWithString:obj];
                [tmpStr replaceOccurrencesOfString:@"set" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tmpStr length])];
                NSString *getterStr = [tmpStr lowercaseString];
                if ([array containsObject:getterStr]) {
                    [array removeObject:getterStr];
                }
            }
        }];
    }];
}
+ (BOOL)hasInWhiteList:(NSString *)className {
    __block BOOL hasIn = false;
    [[self whiteList] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([className isEqualToString:obj]) {
            hasIn = true;
            *stop = true;
        }
    }];
    return hasIn;
}
+ (BOOL)hasInWhiteMethedList:(NSString *)methedName {
    __block BOOL hasIn = false;
    if ([methedName hasPrefix:@"."] || [methedName hasPrefix:@"_"] || methedName.length < 8) {
        return true;
    }
    [[self whiteMethList] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([methedName hasPrefix:obj]) {
            hasIn = true;
            *stop = true;
        }
    }];
    return hasIn;
}
+ (NSArray <Class> *)yj_bundleOwnClassesInfo {
    NSMutableArray *resultArray = [NSMutableArray array];
    unsigned int classCount;
    const char **classes;
    Dl_info info;
    dladdr(&_mh_execute_header, &info);
    classes = objc_copyClassNamesForImage(info.dli_fname, &classCount);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    dispatch_apply(classCount, dispatch_get_global_queue(0, 0), ^(size_t index) {
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        NSString *className = [NSString stringWithCString:classes[index] encoding:NSUTF8StringEncoding];
        Class class = NSClassFromString(className);
        if (![self hasInWhiteList:className]) {
            [resultArray addObject:class];
        }
        dispatch_semaphore_signal(semaphore);
    });
    return resultArray.mutableCopy;
}
+ (NSArray <NSString *> *)yj_bundleAllClassesInfo {
    NSMutableArray *resultArray = [NSMutableArray new];
    int classCount = objc_getClassList(NULL, 0);
    Class *classes = NULL;
    classes = (__unsafe_unretained Class *)malloc(sizeof(Class) *classCount);
    classCount = objc_getClassList(classes, classCount);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    dispatch_apply(classCount, dispatch_get_global_queue(0, 0), ^(size_t index) {
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        Class class = classes[index];
        NSString *className = [[NSString alloc] initWithUTF8String: class_getName(class)];
        [resultArray addObject:className];
        dispatch_semaphore_signal(semaphore);
    });
    free(classes);
    return resultArray.mutableCopy;
}
- (void)sp_getLoginState {
    NSLog(@"Continue");
}
- (void)sp_getMediaData {
    NSLog(@"Get Info Success");
}
@end
