// 灵动岛GIF背景 —— 重制版设置 Bundle
// lddgifbgRootListController: 设置项 + 注销按钮
// LDDMaterialPickerController: 带缩略图的素材选择 (GIF首帧/视频首帧/静态图)
// LDDMaterialFolderOpenerController: 跳转素材目录 (Filza / 文件)
// 无 SDK 编译: 全部运行时动态解析; ImageIO/AVFoundation 用 dlopen+dlsym, 无硬链接

#include <stdint.h>
#include <stddef.h>

typedef struct objc_class *Class;
typedef struct objc_object { Class isa; } *id;
typedef struct objc_selector *SEL;
typedef void *IMP;
typedef struct CGImage *CGImageRef;
typedef struct CGColor *CGColorRef;
typedef bool BOOL;
typedef unsigned long NSUInteger;
#define YES 1
#define NO 0
#define nil 0
#define Nil 0

extern "C" id objc_msgSend(id self, SEL op, ...);
extern "C" id objc_getClass(const char *name);
extern "C" SEL sel_registerName(const char *name);
extern "C" void *dlopen(const char *path, int mode);
extern "C" void *dlsym(void *handle, const char *symbol);
extern "C" void *objc_autoreleasePoolPush(void);
extern "C" void objc_autoreleasePoolPop(void *pool);
extern "C" int posix_spawn(void *pid, const char *path, void *file_actions, void *attrp, char *const argv[], char *const envp[]);
extern "C" void CFRelease(void *cf);
extern "C" { extern void *kCGImagePropertyGIFDictionary; extern void *kCGImagePropertyGIFDelayTime; extern void *kCGImagePropertyGIFUnclampedDelayTime; }

#define MSG(recv, sel, ...) objc_msgSend((id)(recv), sel_registerName(sel) __VA_OPT__(,) __VA_ARGS__)
#define MSGB(recv, sel, ...) ((BOOL(*)(id, SEL, ...))objc_msgSend)((id)(recv), sel_registerName(sel) __VA_OPT__(,) __VA_ARGS__)
#define MSGR(recv, sel) ((CGRect(*)(id, SEL))objc_msgSend)((id)(recv), sel_registerName(sel))
#define CLS(n) objc_getClass(n)

// ---------- ObjC 存根 ----------
@interface NSObject
+ (id)alloc;
- (id)init;
@end
@interface NSString : NSObject
- (NSString *)stringByAppendingPathComponent:(NSString *)s;
- (NSString *)pathExtension;
- (NSString *)lowercaseString;
- (BOOL)isEqualToString:(NSString *)s;
- (unsigned long)length;
@end
@interface NSArray : NSObject
- (unsigned long)count;
- (id)objectAtIndex:(unsigned long)i;
- (NSUInteger)countByEnumeratingWithState:(void *)state objects:(id *)buf count:(NSUInteger)len;
@end
@interface NSMutableArray : NSArray
+ (id)array;
- (void)addObject:(id)obj;
@end
@interface NSDictionary : NSObject
- (id)objectForKeyedSubscript:(id)k;
@end
@interface NSMutableDictionary : NSDictionary
+ (id)dictionary;
- (void)setObject:(id)obj forKeyedSubscript:(id)k;
- (void)setObject:(id)obj forKey:(id)k;
@end
@interface NSData : NSObject
+ (id)dataWithContentsOfFile:(NSString *)p;
@end
@interface NSFileManager : NSObject
+ (id)defaultManager;
- (BOOL)fileExistsAtPath:(NSString *)p isDirectory:(BOOL *)d;
- (id)contentsOfDirectoryAtPath:(NSString *)p error:(id *)e;
@end
@interface NSUserDefaults : NSObject
- (id)initWithSuiteName:(NSString *)n;
- (id)objectForKey:(NSString *)k;
- (void)setObject:(id)obj forKey:(NSString *)k;
- (BOOL)synchronize;
@end
@interface NSURL : NSObject
+ (id)fileURLWithPath:(NSString *)p;
@end
@interface NSIndexPath : NSObject
- (unsigned long)row;
@end
@interface UIApplication : NSObject
+ (id)sharedApplication;
- (BOOL)canOpenURL:(id)url;
- (void)openURL:(id)url options:(id)opts completionHandler:(id)handler;
@end
@interface UIScreen : NSObject
+ (id)mainScreen;
@end
@interface UIColor : NSObject
+ (id)whiteColor;
+ (id)clearColor;
@end
typedef struct CGRect { double ox, oy, w, h; } CGRect;
@interface UIView : NSObject
- (id)initWithFrame:(CGRect)r;
- (void)setFrame:(CGRect)r;
- (CGRect)bounds;
- (void)addSubview:(id)v;
- (id)layer;
- (void)setBackgroundColor:(id)c;
- (void)setClipsToBounds:(BOOL)b;
- (void)setContentMode:(long)m;
- (void)setAutoresizingMask:(unsigned long)m;
- (void)setText:(NSString *)t;      // UILabel 专用(运行时)
- (void)setFont:(id)f;
- (void)setTextColor:(id)c;
- (void)setTextAlignment:(long)a;
- (void)setNumberOfLines:(long)n;
@end
@interface UIImage : NSObject
+ (id)imageWithContentsOfFile:(NSString *)p;
+ (id)imageWithCGImage:(CGImageRef)cg scale:(double)s orientation:(long)o;
@end
@interface UIImageView : UIView
- (void)setImage:(id)img;
@end
@interface UILabel : UIView
- (id)initWithFrame:(CGRect)r;
@end
@interface UIFont : NSObject
+ (id)systemFontOfSize:(double)s;
+ (id)boldSystemFontOfSize:(double)s;
@end
@interface UIViewController : NSObject
- (id)view;
- (id)navigationItem;
- (id)navigationController;
- (void)setTitle:(NSString *)t;
- (id)title;
- (void)viewDidLoad;
- (void)viewDidAppear:(BOOL)a;
@end
@interface UITableViewController : UIViewController
- (id)initWithStyle:(long)style;
- (id)tableView;
- (void)setTableView:(id)tv;
@end
@interface UITableViewController (LDD)
- (long)numberOfSectionsInTableView:(id)tv;
- (long)tableView:(id)tv numberOfRowsInSection:(long)s;
- (id)tableView:(id)tv cellForRowAtIndexPath:(id)ip;
- (void)tableView:(id)tv didSelectRowAtIndexPath:(id)ip;
@end
@interface UINavigationController : UIViewController
- (void)popViewControllerAnimated:(BOOL)a;
@end
@interface UIBarButtonItem : NSObject
- (id)initWithTitle:(NSString *)t style:(long)s target:(id)tgt action:(SEL)a;
@end
@interface UITableViewCell : UIView
- (id)initWithStyle:(long)style reuseIdentifier:(NSString *)ri;
- (id)contentView;
- (void)setAccessoryType:(long)t;
- (void)setSelectionStyle:(long)s;
@end
@interface CALayer : NSObject
- (void)setCornerRadius:(double)r;
- (void)setMasksToBounds:(BOOL)b;
@end
@interface PSListController : UIViewController
- (void)loadSpecifiersFromPlistName:(NSString *)n target:(id)t;
- (id)specifiers;
@end
@interface PSSpecifier : NSObject @end

// ---------- 素材缩略图 ----------
static void *gImageIO = NULL;
static void *gAVF = NULL;
static void *fnCGSrcCreate = NULL, *fnCGSrcCount = NULL, *fnCGSrcImg = NULL;
static void EnsureLibs(void) {
    if (!gImageIO) {
        gImageIO = dlopen("/System/Library/Frameworks/ImageIO.framework/ImageIO", 2);
        if (gImageIO) {
            fnCGSrcCreate = dlsym(gImageIO, "CGImageSourceCreateWithData");
            fnCGSrcCount = dlsym(gImageIO, "CGImageSourceGetCount");
            fnCGSrcImg = dlsym(gImageIO, "CGImageSourceCreateImageAtIndex");
        }
    }
    if (!gAVF) gAVF = dlopen("/System/Library/Frameworks/AVFoundation.framework/AVFoundation", 2);
}
static id ThumbForPath(NSString *path) {
    EnsureLibs();
    id ext = MSG(MSG(path, "pathExtension"), "lowercaseString");
    if ((BOOL)MSG(ext, "isEqualToString:", @"gif") && gImageIO && fnCGSrcCreate && fnCGSrcImg) {
        id data = MSG(CLS("NSData"), "dataWithContentsOfFile:", path);
        if (data) {
            void *src = ((void *(*)(void *, void *))fnCGSrcCreate)((void *)data, 0);
            if (src) {
                size_t n = ((size_t(*)(void *))fnCGSrcCount)(src);
                CGImageRef cg = n > 0 ? ((CGImageRef(*)(void *, size_t, void *))fnCGSrcImg)(src, 0, 0) : 0;
                if (cg) {
                    id img = MSG(CLS("UIImage"), "imageWithCGImage:scale:orientation:", (void *)cg, 1.0, 0);
                    CFRelease((void *)cg);
                    CFRelease(src);
                    return img;
                }
                CFRelease(src);
            }
        }
        return nil;
    }
    if ((BOOL)MSG(ext, "isEqualToString:", @"mp4") || (BOOL)MSG(ext, "isEqualToString:", @"mov")) {
        if (gAVF) {
            id url = MSG(CLS("NSURL"), "fileURLWithPath:", path);
            id asset = MSG(CLS("AVURLAsset"), "URLAssetWithURL:options:", url, nil);
            id gen = MSG(CLS("AVAssetImageGenerator"), "assetImageGeneratorWithAsset:", asset);
            struct CMTimeRaw { long long value; int timescale; unsigned flags; long long epoch; } t = {1, 1, 1, 0};
            // copyCGImageAtTime:actualTime:error:  (CMTime 按值经 x2/x3)
            CGImageRef cg = (CGImageRef)((id(*)(id, SEL, struct CMTimeRaw, void *, void *))objc_msgSend)(gen, sel_registerName("copyCGImageAtTime:actualTime:error:"), t, 0, 0);
            if (cg) {
                id img = MSG(CLS("UIImage"), "imageWithCGImage:scale:orientation:", (void *)cg, 1.0, 0);
                CFRelease((void *)cg);
                return img;
            }
        }
        return nil;
    }
    return MSG(CLS("UIImage"), "imageWithContentsOfFile:", path);   // png/jpg 兜底(含无扩展名)
}

// ---------- 素材选择器 ----------
@interface LDDMaterialPickerController : UITableViewController @end
@implementation LDDMaterialPickerController
{
    id _folders;        // NSArray<NSString*>: 素材目录列表
    id _thumbs;         // 缓存 name -> UIImage
    NSString *_sel;     // 当前选中
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"选择素材"];
    id fm = MSG(CLS("NSFileManager"), "defaultManager");
    BOOL isDir = NO;
    NSString *root = @"/var/mobile/lddgifbg";
    _folders = nil;
    if ((BOOL)MSG(fm, "fileExistsAtPath:isDirectory:", root, &isDir) && isDir) {
        _folders = MSG(fm, "contentsOfDirectoryAtPath:error:", root, nil);
    }
    _thumbs = MSG(CLS("NSMutableDictionary"), "dictionary");
    id ud = MSG(MSG(CLS("NSUserDefaults"), "alloc"), "initWithSuiteName:", @"lddgifbg");
    _sel = (NSString *)MSG(ud, "objectForKey:", @"SelectedMaterialFolder");
}
- (long)numberOfSectionsInTableView:(id)tv { return 1; }
- (long)tableView:(id)tv numberOfRowsInSection:(long)s {
    return _folders ? (long)MSG(_folders, "count") : 0;
}
- (id)tableView:(id)tv cellForRowAtIndexPath:(id)ip {
    long row = (long)MSG(ip, "row");
    if (!_folders || row >= (long)MSG(_folders, "count")) return nil;
    NSString *name = (NSString *)MSG(_folders, "objectAtIndex:", (unsigned long)row);
    id cell = MSG(tv, "dequeueReusableCellWithIdentifier:", @"mat");
    if (!cell) cell = MSG(MSG(CLS("UITableViewCell"), "alloc"), "initWithStyle:reuseIdentifier:", 1 /*Subtitle*/, @"mat");
    // 清空旧内容
    MSG(MSG(cell, "contentView"), "setBackgroundColor:", MSG(CLS("UIColor"), "clearColor"));
    // 缩略图
    NSString *full = (NSString *)MSG(@"/var/mobile/lddgifbg", "stringByAppendingPathComponent:", name);
    id thumb = MSG(_thumbs, "objectForKeyedSubscript:", name);
    if (!thumb) {
        // 找出素材文件再取首帧
        NSString *media = nil;
        id fm = MSG(CLS("NSFileManager"), "defaultManager");
        id files = MSG(fm, "contentsOfDirectoryAtPath:error:", full, nil);
        if (files) {
            for (id f in files) {
                id ext = MSG(MSG(f, "pathExtension"), "lowercaseString");
                if ((BOOL)MSG(ext, "isEqualToString:", @"gif") || (BOOL)MSG(ext, "isEqualToString:", @"mp4") ||
                    (BOOL)MSG(ext, "isEqualToString:", @"mov") || (BOOL)MSG(ext, "isEqualToString:", @"png") ||
                    (BOOL)MSG(ext, "isEqualToString:", @"jpg") || (BOOL)MSG(ext, "isEqualToString:", @"jpeg")) {
                    media = (NSString *)MSG(full, "stringByAppendingPathComponent:", f);
                    break;
                }
            }
        }
        if (media) thumb = ThumbForPath(media);
        if (thumb) MSG(_thumbs, "setObject:forKeyedSubscript:", thumb, name);
    }
    if (thumb) {
        id iv = MSG(CLS("UIImageView"), "alloc");
        iv = MSG(iv, "initWithFrame:", (CGRect){8, 8, 44, 44});
        MSG(iv, "setImage:", thumb);
        MSG(iv, "setContentMode:", 1);   // AspectFit
        MSG(iv, "setClipsToBounds:", 1);
        MSG(MSG(iv, "layer"), "setCornerRadius:", 6.0);
        MSG(MSG(iv, "layer"), "setMasksToBounds:", 1);
        MSG(MSG(cell, "contentView"), "addSubview:", iv);
    }
    // 名称 + 类型
    CGRect b = MSGR(MSG(cell, "contentView"), "bounds");
    id label = MSG(CLS("UILabel"), "alloc");
    label = MSG(label, "initWithFrame:", (CGRect){60, 10, b.w - 70, 22});
    MSG(label, "setText:", name);
    MSG(label, "setFont:", MSG(CLS("UIFont"), "boldSystemFontOfSize:", 16.0));
    MSG(MSG(cell, "contentView"), "addSubview:", label);
    id sub = MSG(CLS("UILabel"), "alloc");
    sub = MSG(sub, "initWithFrame:", (CGRect){60, 33, b.w - 70, 16});
    // 素材类型描述
    NSString *typeDesc = @"GIF";
    id fm2 = MSG(CLS("NSFileManager"), "defaultManager");
    id files2 = MSG(fm2, "contentsOfDirectoryAtPath:error:", full, nil);
    if (files2) {
        for (id f in files2) {
            id ext = MSG(MSG(f, "pathExtension"), "lowercaseString");
            if ((BOOL)MSG(ext, "isEqualToString:", @"mp4") || (BOOL)MSG(ext, "isEqualToString:", @"mov")) { typeDesc = @"视频"; break; }
            if ((BOOL)MSG(ext, "isEqualToString:", @"png") || (BOOL)MSG(ext, "isEqualToString:", @"jpg") || (BOOL)MSG(ext, "isEqualToString:", @"jpeg")) { typeDesc = @"静态图"; }
        }
    }
    MSG(sub, "setText:", typeDesc);
    MSG(sub, "setFont:", MSG(CLS("UIFont"), "systemFontOfSize:", 12.0));
    MSG(MSG(cell, "contentView"), "addSubview:", sub);
    // 当前选中打勾
    if (_sel && (BOOL)MSG(_sel, "isEqualToString:", name)) {
        MSG(cell, "setAccessoryType:", 3);
    } else {
        MSG(cell, "setAccessoryType:", 0);
    }
    MSG(cell, "setSelectionStyle:", 0);
    return cell;
}
- (void)tableView:(id)tv didSelectRowAtIndexPath:(id)ip {
    long row = (long)MSG(ip, "row");
    if (!_folders || row >= (long)MSG(_folders, "count")) return;
    NSString *name = (NSString *)MSG(_folders, "objectAtIndex:", (unsigned long)row);
    id ud = MSG(MSG(CLS("NSUserDefaults"), "alloc"), "initWithSuiteName:", @"lddgifbg");
    MSG(ud, "setObject:forKey:", name, @"SelectedMaterialFolder");
    MSG(ud, "synchronize");
    MSG(tv, "deselectRowAtIndexPath:animated:", ip, 1);
    MSG(MSG(self, "navigationController"), "popViewControllerAnimated:", 1);
}
@end

// ---------- 跳转素材目录 ----------
@interface LDDMaterialFolderOpenerController : PSListController @end
@implementation LDDMaterialFolderOpenerController
- (void)viewDidLoad {
    [super viewDidLoad];
    id app = MSG(CLS("UIApplication"), "sharedApplication");
    id filza = MSG(CLS("NSURL"), "fileURLWithPath:", @"/var/mobile/lddgifbg");
    if ((BOOL)MSG(app, "canOpenURL:", MSG(CLS("NSURL"), "fileURLWithPath:", @"/var/mobile/lddgifbg"))) {
        // file:// 通常可以直接打开"文件"
        MSG(app, "openURL:options:completionHandler:", filza, MSG(CLS("NSDictionary"), "dictionary"), nil);
    } else {
        // 尝试 Filza
        id fz = MSG(CLS("NSURL"), "fileURLWithPath:", @"/var/mobile/lddgifbg");
        MSG(app, "openURL:options:completionHandler:", fz, MSG(CLS("NSDictionary"), "dictionary"), nil);
    }
    MSG(MSG(self, "navigationController"), "popViewControllerAnimated:", 1);
}
@end

// ---------- 设置主控制器 ----------
@interface lddgifbgRootListController : PSListController @end
@implementation lddgifbgRootListController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"灵动岛GIF背景"];
    MSG(self, "loadSpecifiersFromPlistName:target:", @"Root", self);
    id btn = MSG(MSG(CLS("UIBarButtonItem"), "alloc"), "initWithTitle:style:target:action:", @"重启", 0, self, sel_registerName("respringNow"));
    MSG(MSG(self, "navigationItem"), "setRightBarButtonItem:", btn);
}
- (void)respringNow {
    id fm = MSG(CLS("NSFileManager"), "defaultManager");
    BOOL have_sbreload = (BOOL)MSG(fm, "fileExistsAtPath:", @"/var/jb/usr/bin/sbreload");
    char *argv1[] = {(char *)"/var/jb/usr/bin/sbreload", 0};
    char *argv2[] = {(char *)"/var/jb/usr/bin/killall", (char *)"SpringBoard", 0};
    // 通过 dlsym 调用 posix_spawn, 避免与 SDK 头文件声明冲突
    static int (*spawn_fn)(void *, const char *, void *, void *, char *const[], char *const[]);
    if (!spawn_fn) {
        void *h = dlopen(0, 1);
        if (h) spawn_fn = (int (*)(void *, const char *, void *, void *, char *const[], char *const[]))dlsym(h, "posix_spawn");
    }
    if (spawn_fn) {
        if (have_sbreload) spawn_fn(0, "/var/jb/usr/bin/sbreload", 0, 0, argv1, 0);
        else spawn_fn(0, "/var/jb/usr/bin/killall", 0, 0, argv2, 0);
    }
}
@end
