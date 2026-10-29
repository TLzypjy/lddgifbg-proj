// 灵动岛GIF背景 —— 重制版设置 Bundle (v3: 全标准 ObjC 语法, 适配 arm64e)
// 架构: 入口壳(PSListController) -> 模态面板(UITableViewController 自绘) -> 素材选择器(模态)
// 关键: 全部使用 [obj method:] 标准语法, 由编译器生成 arm64e 正确的 objc_msgSend
#include <stdio.h>
#include <time.h>
#include <string.h>

typedef struct objc_class *Class;
typedef struct objc_object { Class isa; } *id;
typedef struct objc_selector *SEL;
typedef struct CGImage *CGImageRef;
typedef bool BOOL;
typedef unsigned long NSUInteger;
typedef long NSInteger;
#define YES 1
#define NO 0
#define nil 0
#define Nil 0

extern "C" id objc_msgSend(id self, SEL op, ...);
extern "C" id objc_getClass(const char *name);
extern "C" SEL sel_registerName(const char *name);
extern "C" void *dlopen(const char *path, int mode);
extern "C" void *dlsym(void *handle, const char *symbol);
extern "C" void CFRelease(void *cf);
extern "C" void objc_setAssociatedObject(id obj, const char *key, id value, unsigned long policy);
extern "C" id objc_getAssociatedObject(id obj, const char *key);
extern "C" int notify_post(const char *name);
extern "C" double CFAbsoluteTimeGetCurrent(void);
extern "C" id UIImageJPEGRepresentation(id img, double q);

#define CLS(n) objc_getClass(n)
static id CLSSTR(const char *n) { return (id)objc_getClass(n); }

// ---------- ObjC 存根 (标准声明, 供编译期检查) ----------
@interface NSObject
+ (id)alloc;
+ (id)class;
- (id)performSelector:(SEL)s;
- (id)init;
- (id)valueForKey:(id)k;
- (void)setValue:(id)v forKey:(id)k;
- (void)performSelector:(SEL)s withObject:(id)o afterDelay:(double)d;
@end
@class NSArray;
@class NSString;
@interface NSNotificationCenter : NSObject
+ (id)defaultCenter;
- (void)postNotificationName:(NSString *)n object:(id)o;
- (void)addObserver:(id)obs selector:(SEL)sel name:(NSString *)n object:(id)o;
@end
@interface NSString : NSObject
- (id)initWithBytes:(const void *)b length:(NSUInteger)l encoding:(NSUInteger)e;
+ (id)stringWithFormat:(NSString *)f, ...;
- (double)doubleValue;
- (NSString *)stringByAppendingPathComponent:(NSString *)s;
- (NSString *)pathExtension;
- (NSString *)lowercaseString;
- (NSString *)lastPathComponent;
- (BOOL)isEqualToString:(NSString *)s;
- (NSUInteger)length;
+ (id)stringWithContentsOfFile:(NSString *)path encoding:(NSUInteger)enc error:(id *)err;
- (NSArray *)componentsSeparatedByString:(NSString *)sep;
@end
@interface NSArray : NSObject
+ (id)array;
+ (id)arrayWithObjects:(id)first, ...;
- (NSUInteger)count;
- (id)objectAtIndex:(NSUInteger)i;
- (BOOL)containsObject:(id)o;
- (id)mutableCopy;
- (NSUInteger)countByEnumeratingWithState:(void *)state objects:(id *)buf count:(NSUInteger)len;
- (id)objectAtIndexedSubscript:(NSUInteger)i;
@end
@interface NSMutableArray : NSArray
+ (id)array;
+ (id)arrayWithCapacity:(NSUInteger)n;
- (void)addObject:(id)obj;
- (void)removeObject:(id)o;
- (void)removeAllObjects;
@end
@interface NSDictionary : NSObject
+ (id)dictionary;
+ (id)dictionaryWithContentsOfFile:(NSString *)p;
- (NSUInteger)count;
- (id)objectForKeyedSubscript:(id)k;
- (id)objectForKey:(id)k;
- (BOOL)writeToFile:(NSString *)p atomically:(BOOL)a;
@end
@interface NSMutableDictionary : NSDictionary
+ (id)dictionary;
- (void)addEntriesFromDictionary:(NSDictionary *)other;
- (void)setObject:(id)obj forKeyedSubscript:(id)k;
- (void)setObject:(id)obj forKey:(id)k;
@end
@interface NSData : NSObject
+ (id)dataWithContentsOfFile:(NSString *)p;
@end
@interface NSNumber : NSObject
+ (id)numberWithDouble:(double)d;
+ (id)numberWithBool:(BOOL)b;
- (double)doubleValue;
- (BOOL)boolValue;
- (int)intValue;
+ (id)numberWithInt:(int)v;
@end
@interface NSFileManager : NSObject
+ (id)defaultManager;
- (BOOL)fileExistsAtPath:(NSString *)p;
- (BOOL)fileExistsAtPath:(NSString *)p isDirectory:(BOOL *)d;
- (BOOL)createDirectoryAtPath:(NSString *)p withIntermediateDirectories:(BOOL)b attributes:(id)a error:(id *)e;
- (BOOL)copyItemAtURL:(id)src toURL:(id)dst error:(id *)e;
- (BOOL)removeItemAtPath:(NSString *)p error:(id *)e;
- (BOOL)createFileAtPath:(NSString *)p contents:(id)c attributes:(id)a;
- (id)contentsOfDirectoryAtPath:(NSString *)p error:(id *)e;
@end
@interface NSUserDefaults : NSObject
- (id)initWithSuiteName:(NSString *)n;
- (id)objectForKey:(id)k;
- (void)setObject:(id)obj forKey:(id)k;
- (BOOL)synchronize;
@end
@interface NSURL : NSObject
+ (id)fileURLWithPath:(NSString *)p;
+ (id)URLWithString:(NSString *)s;
@end
@interface NSIndexPath : NSObject
- (NSInteger)row;
@end
@interface NSException : NSObject @end

typedef struct CGPoint { double x, y; } CGPoint;
typedef struct CGRect { double ox, oy, w, h; } CGRect;

typedef struct CGColor *CGColorRef;
extern "C" void *CGImageSourceCopyPropertiesAtIndex(void *src, unsigned long idx, void *opts);
extern "C" void *CGColorSpaceCreateDeviceRGB(void);
extern "C" void *CGBitmapContextCreate(void *data, unsigned long w, unsigned long h, unsigned long bpc, unsigned long bpr, void *cs, unsigned long info);
extern "C" void CGContextDrawImage(void *ctx, CGRect rect, CGImageRef img);
extern "C" void CGColorSpaceRelease(void *cs);
extern "C" void CGContextRelease(void *ctx);
extern "C" void *kCGImagePropertyGIFDictionary;
extern "C" void *kCGImagePropertyGIFDelayTime;
extern "C" void *kCGImagePropertyGIFUnclampedDelayTime;

typedef struct CGSize { double w, h; } CGSize;
typedef struct UIEdgeInsets { double top, left, bottom, right; } UIEdgeInsets;
// 1.9.140: 预览平移
typedef struct CGAffineTransform { double a, b, c, d, tx, ty; } CGAffineTransform;
static CGAffineTransform CGMakeTranslate(double tx, double ty) { CGAffineTransform t = {1, 0, 0, 1, tx, ty}; return t; }
static CGRect MakeRect(double x, double y, double w, double h) { CGRect r = {x, y, w, h}; return r; }

@interface UIColor : NSObject
+ (id)clearColor;
+ (id)whiteColor;
+ (id)redColor;
+ (id)colorWithWhite:(double)w alpha:(double)a;
+ (id)systemBlueColor;
+ (id)colorWithWhite:(double)w alpha:(double)a;
- (CGColorRef)CGColor;
+ (id)colorWithRed:(double)r green:(double)g blue:(double)bl alpha:(double)a;
@end
@interface UIFont : NSObject
+ (id)systemFontOfSize:(double)s;
+ (id)boldSystemFontOfSize:(double)s;
@end
@interface UIView : NSObject
- (id)initWithFrame:(CGRect)r;
- (CGRect)bounds;
- (CGRect)frame;
- (void)setFrame:(CGRect)r;
- (void)addSubview:(id)v;
// 1.9.140: 预览偏移用
- (void)setTransform:(CGAffineTransform)t;
- (void)setTag:(NSInteger)t;
- (id)viewWithTag:(NSInteger)t;
- (id)superview;
- (void)addGestureRecognizer:(id)g;
- (void)removeFromSuperview;
- (void)setBackgroundColor:(id)c;
- (id)subviews;
- (id)layer;
- (void)setContentMode:(NSInteger)m;
- (void)setClipsToBounds:(BOOL)b;
- (void)setAlpha:(double)a;
- (id)window;
- (void)setUserInteractionEnabled:(BOOL)e;
@end

@interface UIWindow : UIView
- (id)initWithFrame:(CGRect)r;
- (void)setWindowLevel:(long)l;
- (void)setHidden:(BOOL)h;
- (void)makeKeyAndVisible;
- (void)setWindowScene:(id)s;
- (id)scene;
- (long)windowLevel;
- (id)hitTest:(CGPoint)p withEvent:(id)e;
@end
@interface UIApplication : NSObject
+ (id)sharedApplication;
- (id)keyWindow;
- (void)openURL:(id)u options:(id)o completionHandler:(id)c;
@end
@interface UIControl : UIView
- (void)addTarget:(id)t action:(SEL)a forControlEvents:(NSUInteger)e;
@end
@interface UILabel : UIView
- (id)initWithFrame:(CGRect)r;
- (void)setText:(NSString *)t;
- (void)setFont:(id)f;
- (void)setTextColor:(id)c;
- (void)setTextAlignment:(NSInteger)a;
- (void)setAlpha:(double)a;
- (void)setNumberOfLines:(NSInteger)n;
@end
@interface UITextField : UIView
- (void)setPlaceholder:(NSString *)p;
- (id)text;
- (void)setText:(NSString *)t;
- (void)setKeyboardType:(NSInteger)k;
@end
// 1.9.153: 点击数值自定义输入
@interface UITapGestureRecognizer : NSObject
- (id)initWithTarget:(id)t action:(SEL)a;
- (id)view;
@end
@interface UIImage : NSObject
+ (id)imageWithContentsOfFile:(NSString *)p;
+ (id)imageWithCGImage:(CGImageRef)cg scale:(double)s orientation:(NSInteger)o;
- (CGSize)size;
- (void)drawInRect:(CGRect)r;
- (CGImageRef)CGImage;
- (CGSize)size;
+ (id)imageWithCGImage:(CGImageRef)cg;
@end
extern "C" void UIGraphicsBeginImageContextWithOptions(CGSize sz, BOOL opaque, double scale);
extern "C" id UIGraphicsGetImageFromCurrentImageContext(void);
extern "C" void UIGraphicsEndImageContext(void);
@interface UIImageView : UIView
- (id)initWithFrame:(CGRect)r;
- (void)setImage:(id)img;
- (void)setAnimationImages:(id)images;
- (void)setAnimationDuration:(double)d;
- (void)setAnimationRepeatCount:(NSInteger)n;
- (void)startAnimating;
- (void)stopAnimating;
- (void)setAlpha:(double)a;
@end
@interface UIView (Spring)
+ (void)animateWithDuration:(double)d delay:(double)dl usingSpringWithDamping:(double)damp initialSpringVelocity:(double)vel options:(NSUInteger)opt animations:(void(^)(void))anim completion:(void(^)(BOOL))comp;
@end
@interface UIButton : UIView @end
@interface UISwitch : UIView
- (id)initWithFrame:(CGRect)r;
- (void)setOn:(BOOL)on animated:(BOOL)a;
- (BOOL)isOn;
- (void)setTag:(NSInteger)t;
- (NSInteger)tag;
- (void)addTarget:(id)t action:(SEL)a forControlEvents:(NSUInteger)e;
@end
@interface UISlider : UIView
- (id)initWithFrame:(CGRect)r;
// 1.9.138: 真实 UIKit 为 float —— double 签名导致 arm64 上 value 读取错位(恒 0.00)
- (void)setMinimumValue:(float)m;
- (void)setMaximumValue:(float)m;
- (void)setValue:(float)v;
- (float)value;
- (void)addTarget:(id)t action:(SEL)a forControlEvents:(NSUInteger)e;
@end
@interface UITableViewCell : UIView
- (id)initWithStyle:(NSInteger)style reuseIdentifier:(NSString *)ri;
- (id)contentView;
- (void)setAccessoryType:(NSInteger)t;
- (void)setSelectionStyle:(NSInteger)s;
@end
@interface UITableView : UIView
- (id)dequeueReusableCellWithIdentifier:(NSString *)ri;
- (void)deselectRowAtIndexPath:(id)ip animated:(BOOL)a;
@end
@interface UIViewController : NSObject
- (void)viewWillAppear:(BOOL)a;
- (id)initWithNibName:(id)n bundle:(id)b;
- (id)view;
- (id)navigationItem;
- (void)setLeftBarButtonItem:(id)b;
- (void)setRightBarButtonItem:(id)b;
- (void)setRightBarButtonItems:(id)items;
- (void)setTitle:(NSString *)t;
- (void)viewDidLoad;
- (void)viewDidAppear:(BOOL)a;
- (void)presentViewController:(id)vc animated:(BOOL)a completion:(id)c;
- (void)dismissViewControllerAnimated:(BOOL)a completion:(id)c;
- (id)presentingViewController;
@end
@interface UITableViewController : UIViewController
- (id)initWithStyle:(NSInteger)style;
- (void)setTableView:(id)tv;
@end
@interface UINavigationController : UIViewController
- (id)initWithRootViewController:(id)rvc;
- (void)pushViewController:(id)vc animated:(BOOL)a;
- (void)popViewControllerAnimated:(BOOL)a;
@end
@interface NSDate : NSObject
+ (id)date;
- (double)timeIntervalSince1970;
@end
@interface UIScreen : NSObject
+ (id)mainScreen;
- (CGRect)bounds;
- (double)scale;
@end
@interface UICollectionViewCell : UIView
- (id)contentView;
@end
@interface UICollectionViewFlowLayout : NSObject
- (id)init;
- (void)setMinimumInteritemSpacing:(double)s;
- (void)setMinimumLineSpacing:(double)s;
- (void)setItemSize:(CGSize)s;
- (void)setSectionInset:(UIEdgeInsets)i;
@end
@interface UICollectionView : UIView
- (id)initWithFrame:(CGRect)f collectionViewLayout:(id)layout;
- (void)setBackgroundColor:(id)c;
- (void)setDelegate:(id)d;
- (void)setDataSource:(id)d;
- (void)registerClass:(id)cls forCellWithReuseIdentifier:(NSString *)ri;
- (id)dequeueReusableCellWithReuseIdentifier:(NSString *)ri forIndexPath:(id)ip;
- (void)reloadData;
@end
@interface UIImagePickerController : UIViewController
- (void)setSourceType:(NSInteger)t;
- (void)setMediaTypes:(id)types;
- (void)setDelegate:(id)d;
- (void)setAllowsEditing:(BOOL)b;
@end
@interface UIDocumentPickerViewController : UIViewController
- (id)initForOpeningContentTypes:(id)types;
- (void)setDelegate:(id)d;
@end
@interface UNTimeIntervalNotificationTrigger : NSObject
- (id)initWithTimeInterval:(double)t repeats:(BOOL)r;
@end
@interface UNMutableNotificationContent : NSObject
- (id)init;
@end
@interface UNNotificationRequest : NSObject
- (id)initWithIdentifier:(NSString *)i content:(id)c trigger:(id)t;
@end
@interface UIAlertAction : NSObject
+ (id)actionWithTitle:(NSString *)t style:(NSInteger)s handler:(id)h;
@end
@interface UIAlertController : UIViewController
+ (id)alertControllerWithTitle:(NSString *)t message:(NSString *)m preferredStyle:(NSInteger)s;
- (void)addAction:(id)a;
- (void)addTextFieldWithConfigurationHandler:(id)h;
- (id)textFields;
@end
@interface UIBarButtonItem : NSObject
- (id)initWithTitle:(NSString *)t style:(NSInteger)s target:(id)tgt action:(SEL)a;
@end
@interface NSTimer : NSObject
+ (id)scheduledTimerWithTimeInterval:(double)t target:(id)target selector:(SEL)s userInfo:(id)info repeats:(BOOL)r;
- (void)invalidate;
@end
@interface CALayer : NSObject
- (void)setCornerRadius:(double)r;
- (void)setMasksToBounds:(BOOL)b;
- (void)setShadowColor:(CGColorRef)c;
- (void)setShadowOpacity:(float)o;
- (void)setShadowRadius:(double)r;
- (void)setShadowOffset:(CGSize)s;
@end
@interface PSListController : UIViewController
- (id)loadSpecifiersFromPlistName:(NSString *)n target:(id)t;
- (id)specifiers;
// 1.9.140: 素材选择返回后刷新 (预览行跟随)
- (id)table;
@end
@interface NSBundle : NSObject
+ (id)mainBundle;
- (NSString *)pathForResource:(NSString *)n ofType:(NSString *)t;
@end


// ---------- prefs 文件直写 (保证 SB 文件优先读取到最新值) ----------
static void WritePrefsFile(NSString *key, id value) {
    const char *paths[] = {
        "/var/jb/User/Library/Preferences/lddgifbg.plist",
        "/var/mobile/Library/Preferences/lddgifbg.plist",
        0
    };
    NSMutableDictionary *d = [NSMutableDictionary dictionary];
    // 底: NSUserDefaults 全键 (面板写过的一定在)
    NSUserDefaults *ud0 = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
    for (NSString *k in [NSArray arrayWithObjects:@"Enablelddgifbg", @"Enablezxhlddgifbg", @"lddgifbgSpeed", @"lddgifbgPosX", @"lddgifbgPosY", @"SelectedMaterialFolder", nil]) {
        id v = [ud0 objectForKey:k];
        if (v) [d setObject:v forKey:k];
    }
    // 叠加: 已有文件值
    for (int i = 0; paths[i]; i++) {
        NSString *p = [[NSString alloc] initWithBytes:paths[i] length:strlen(paths[i]) encoding:4];
        NSDictionary *cur = [NSDictionary dictionaryWithContentsOfFile:p];
        if (cur) { [d addEntriesFromDictionary:cur]; break; }
    }
    [d setObject:value forKey:key];
    for (int i = 0; paths[i]; i++) {
        NSString *p = [[NSString alloc] initWithBytes:paths[i] length:strlen(paths[i]) encoding:4];
        [d writeToFile:p atomically:YES];
    }
}

// ---------- 日志(诊断) ----------
static void LogB(const char *s) {
    FILE *f = fopen("/var/jb/tmp/lddgifbg-bundle.log", "a");
    if (f) { fprintf(f, "%s\n", s ? s : "?"); fflush(f); fclose(f); }
}


// ---------- 测试通知 (独立函数, 全程防护) ----------
static void PostTestNotification(void) {
    LogB("TN-FLAG-WRITE");
    @try {
        // 写触发文件, 由 SpringBoard 侧代发通知 (设置进程无通知资格)
        [[NSFileManager defaultManager] createFileAtPath:@"/var/mobile/lddgifbg/__test_notif__" contents:0 attributes:0];
        LogB("TN-FLAG-OK");
    } @catch (id e) { LogB("TN-FLAG-EXC"); }
}

// ---------- 1.9.140: 设置页实时预览 (灵动岛药丸 + 素材首帧 + 偏移平移) ----------
static UIView *gPrevContainer = nil;
static UIImageView *gPrevContent = nil;
static double gPrevW = 0, gPrevH = 0;
static NSString *SelectedMaterialPathForPreview(void) {
    NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
    NSString *folder = [ud objectForKey:@"SelectedMaterialFolder"];
    if (!folder) return nil;
    NSString *dir = [@"/var/mobile/lddgifbg" stringByAppendingPathComponent:folder];
    NSArray *items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:0];
    for (NSString *it in items) {
        NSString *e = [[it pathExtension] lowercaseString];
        if ([e isEqualToString:@"gif"] || [e isEqualToString:@"mp4"] || [e isEqualToString:@"mov"])
            return [dir stringByAppendingPathComponent:it];
    }
    return nil;
}
static void LDDUpdatePreview(void) {
    if (!gPrevContainer || !gPrevContent) return;
    NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
    id vx = [ud objectForKey:@"lddgifbgPosX"];
    id vy = [ud objectForKey:@"lddgifbgPosY"];
    double px = vx ? [vx doubleValue] : 0.0;
    double py = vy ? [vy doubleValue] : 0.0;
    CGRect cb = [gPrevContainer bounds];
    double maxTx = 0, maxTy = 0;
    if (gPrevW > 1 && gPrevH > 1) {
        double sc = (cb.w / gPrevW) > (cb.h / gPrevH) ? (cb.w / gPrevW) : (cb.h / gPrevH);
        double rw = gPrevW * sc, rh = gPrevH * sc;
        maxTx = (rw - cb.w) / 2.0; if (maxTx < 0) maxTx = 0;
        maxTy = (rh - cb.h) / 2.0; if (maxTy < 0) maxTy = 0;
    }
    // 1.9.150: 与 main 一致, 偏移限制在素材可移范围内, 不漏黑边
    if (px > maxTx) px = maxTx;
    if (px < -maxTx) px = -maxTx;
    if (py > maxTy) py = maxTy;
    if (py < -maxTy) py = -maxTy;
    // 1.9.143: 与 main 一致, 直接改 frame 原点 (不用 transform)
    CGRect pf = [gPrevContent frame];
    double fx = (cb.w - pf.w) / 2.0 + px;
    double fy = (cb.h - pf.h) / 2.0 + py;
    [gPrevContent setFrame:MakeRect(fx, fy, pf.w, pf.h)];
    { char bl[96]; snprintf(bl, sizeof(bl), "PREVIEW-POS %.0f %.0f", px, py); LogB(bl); }
}

// ---------- 素材缩略图 ----------
static void *gImageIO = NULL;
static void *gAVF = NULL;
static void *fnCGSrcCreate = NULL, *fnCGSrcImg = NULL, *fnCGSrcCount = NULL;
static void EnsureLibs(void) {
    if (!gImageIO) {
        gImageIO = dlopen("/System/Library/Frameworks/ImageIO.framework/ImageIO", 2);
        if (gImageIO) {
            fnCGSrcCreate = dlsym(gImageIO, "CGImageSourceCreateWithData");
            fnCGSrcImg = dlsym(gImageIO, "CGImageSourceCreateImageAtIndex");
            fnCGSrcCount = dlsym(gImageIO, "CGImageSourceGetCount");
        }
    }
    if (!gAVF) gAVF = dlopen("/System/Library/Frameworks/AVFoundation.framework/AVFoundation", 2);
}
// GIF 低分辨率帧序列 (动态预览用): 最多 maxFrames 帧, 缩到 maxW 宽
__attribute__((unused)) static id GIFFramesForPath(NSString *path, int maxFrames, double maxW) {
    EnsureLibs();
    if (!gImageIO || !fnCGSrcCreate || !fnCGSrcImg) return nil;
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (!data) return nil;
    void *src = ((void *(*)(void *, void *))fnCGSrcCreate)((__bridge void *)data, 0);
    if (!src) return nil;
    NSUInteger count = ((NSUInteger(*)(void *))fnCGSrcCount)(src);
    if (count == 0) { CFRelease(src); return nil; }
    if ((int)count > maxFrames) count = (NSUInteger)maxFrames;
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:count];
    for (NSUInteger i = 0; i < count; i++) {
        CGImageRef cg = ((CGImageRef(*)(void *, NSUInteger, void *))fnCGSrcImg)(src, i, 0);
        if (!cg) continue;
        UIImage *full = [UIImage imageWithCGImage:cg scale:1.0 orientation:0];
        CFRelease((void *)cg);
        if (!full) continue;
        // 缩放到 maxW
        CGSize osz; osz.w = [full size].w; osz.h = [full size].h;
        double sc = maxW / osz.w;
        if (sc > 1.0) sc = 1.0;
        CGSize nsz; nsz.w = osz.w * sc; nsz.h = osz.h * sc;
        UIGraphicsBeginImageContextWithOptions(nsz, NO, 0.0);
        [full drawInRect:MakeRect(0, 0, nsz.w, nsz.h)];
        UIImage *small = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        if (small) [arr addObject:small];
    }
    CFRelease(src);
    return [arr count] > 1 ? arr : nil;
}
static id ThumbForPath(NSString *path) {
    EnsureLibs();
    NSString *ext = [[path pathExtension] lowercaseString];
    if ([ext isEqualToString:@"gif"] && gImageIO && fnCGSrcCreate && fnCGSrcImg) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        if (data) {
            void *src = ((void *(*)(void *, void *))fnCGSrcCreate)((__bridge void *)data, 0);
            if (src) {
                CGImageRef cg = ((CGImageRef(*)(void *, NSUInteger, void *))fnCGSrcImg)(src, 0, 0);
                if (cg) {
                    UIImage *img = [UIImage imageWithCGImage:cg scale:1.0 orientation:0];
                    CFRelease((void *)cg);
                    CFRelease(src);
                    return img;
                }
                CFRelease(src);
            }
        }
        return nil;
    }
    if ([ext isEqualToString:@"mp4"] || [ext isEqualToString:@"mov"]) {
        if (gAVF) {
            NSURL *url = [NSURL fileURLWithPath:path];
            typedef id (*FnA)(id, SEL, NSURL *, id);
            FnA fna = (FnA)objc_msgSend;
            id asset = fna((id)CLSSTR("AVURLAsset"), sel_registerName("URLAssetWithURL:options:"), url, nil);
            if (asset) {
                id gen = ((id(*)(id, SEL, id))objc_msgSend)((id)CLSSTR("AVAssetImageGenerator"), sel_registerName("assetImageGeneratorWithAsset:"), asset);
                if (gen) {
                    [gen setValue:[NSNumber numberWithBool:YES] forKey:@"appliesPreferredTrackTransform"];
                    struct CMTimeRaw { long long value; int timescale; unsigned flags; long long epoch; };
                    struct CMTimeRaw t = {1, 1, 1, 0};
                    // copyCGImageAtTime:actualTime:error:  (CMTime 按值经 x2/x3)
                    typedef id (*Fn)(id, SEL, struct CMTimeRaw, void *, void *);
                    Fn fn = (Fn)objc_msgSend;
                    CGImageRef cg = (__bridge CGImageRef)(fn(gen, sel_registerName("copyCGImageAtTime:actualTime:error:"), t, 0, 0));
                    if (cg) {
                        UIImage *img = [UIImage imageWithCGImage:cg scale:1.0 orientation:0];
                        CFRelease((void *)cg);
                        return img;
                    }
                }
            }
        }
        return nil;
    }
    return [UIImage imageWithContentsOfFile:path];
}

// ---------- 素材选择器: 卡片网格 ----------
@interface LDDMaterialPickerController : UIViewController
- (NSInteger)collectionView:(id)cv numberOfItemsInSection:(NSInteger)s;
- (id)collectionView:(id)cv cellForItemAtIndexPath:(id)ip;
- (void)collectionView:(id)cv didSelectItemAtIndexPath:(id)ip;
- (CGSize)collectionView:(id)cv layout:(id)layout sizeForItemAtIndexPath:(id)ip;
- (void)closeTapped;
@end
// 1.9.131: 素材列表只返回"素材文件夹"(目录), 排除 __ 前缀内部文件(探针/消费标记)
static id LDDListMaterialFolders(void) {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *all = [fm contentsOfDirectoryAtPath:@"/var/mobile/lddgifbg" error:nil];
    NSMutableArray *dirs = [NSMutableArray array];
    for (NSString *nm in all) {
        if (((BOOL(*)(id, SEL, id))objc_msgSend)(nm, sel_registerName("hasPrefix:"), @"__")) continue;
        NSString *fp = [@"/var/mobile/lddgifbg" stringByAppendingPathComponent:nm];
        BOOL isD = NO;
        if ([fm fileExistsAtPath:fp isDirectory:&isD] && isD) [dirs addObject:nm];
    }
    return dirs;
}

@implementation LDDMaterialPickerController
{
    id _folders;
    id _thumbs;
    id _anims;
    NSString *_sel;
    id _cv;
    id _pendImg;
    id _pendURL;
    BOOL _pendVideo;
    BOOL _delMode;
    id _marked;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"素材库"];
    UIBarButtonItem *close = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:0 target:self action:@selector(closeTapped)];
    [[self navigationItem] setLeftBarButtonItem:close];
    UIBarButtonItem *imp = [[UIBarButtonItem alloc] initWithTitle:@"导入" style:0 target:self action:@selector(importTapped)];
    UIBarButtonItem *del = [[UIBarButtonItem alloc] initWithTitle:@"删除" style:0 target:self action:@selector(deleteTapped)];
    [[self navigationItem] setRightBarButtonItems:[NSArray arrayWithObjects:imp, del, nil]];
    _marked = [NSMutableArray array];
    [[self view] setBackgroundColor:[UIColor colorWithWhite:0.94 alpha:1.0]];

    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir = NO;
    if ([fm fileExistsAtPath:@"/var/mobile/lddgifbg" isDirectory:&isDir] && isDir) {
        _folders = LDDListMaterialFolders();
    }
    _thumbs = [NSMutableDictionary dictionary];
    _anims = [NSMutableDictionary dictionary];
    NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
    _sel = [ud objectForKey:@"SelectedMaterialFolder"];

    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    [flow setMinimumInteritemSpacing:10];
    [flow setMinimumLineSpacing:22];
    UIEdgeInsets ins; ins.top = 14; ins.left = 14; ins.bottom = 70; ins.right = 14;
    [flow setSectionInset:ins];
    CGRect vb = [[self view] bounds];
    UICollectionView *cv = [[UICollectionView alloc] initWithFrame:vb collectionViewLayout:flow];
    [cv setBackgroundColor:[UIColor clearColor]];
    [cv setDelegate:self];
    [cv setDataSource:self];
    [cv registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"m"];
    [[self view] addSubview:cv];
    _cv = cv;
    NSString *cnt = [NSString stringWithFormat:@"素材库 (%lu)", (unsigned long)[_folders count]];
    [self setTitle:cnt];
}
- (void)closeTapped {
    [self dismissViewControllerAnimated:YES completion:0];
}
- (void)importTapped {
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"导入素材" message:@"选择来源" preferredStyle:0];
    UIAlertAction *a1 = [UIAlertAction actionWithTitle:@"从相册" style:0 handler:^(UIAlertAction *a){
        [self openPhotos];
    }];
    UIAlertAction *a2 = [UIAlertAction actionWithTitle:@"从文件" style:0 handler:^(UIAlertAction *a){
        [self openFiles];
    }];
    UIAlertAction *a3 = [UIAlertAction actionWithTitle:@"取消" style:1 handler:0];
    [sheet addAction:a1];
    [sheet addAction:a2];
    [sheet addAction:a3];
    [self presentViewController:sheet animated:YES completion:0];
}
- (void)openPhotos {
    UIImagePickerController *pc = [[UIImagePickerController alloc] init];
    [pc setSourceType:0];
    [pc setMediaTypes:[NSArray arrayWithObjects:@"public.image", @"public.movie", nil]];
    [pc setDelegate:self];
    [pc setAllowsEditing:NO];
    [self presentViewController:pc animated:YES completion:0];
}
- (void)openFiles {
    id utImage = ((id(*)(id, SEL))objc_msgSend)((id)objc_getClass("UTType"), sel_registerName("image"));
    id utMovie = ((id(*)(id, SEL))objc_msgSend)((id)objc_getClass("UTType"), sel_registerName("movie"));
    UIDocumentPickerViewController *dp = [[UIDocumentPickerViewController alloc] initForOpeningContentTypes:[NSArray arrayWithObjects:utImage, utMovie, nil]];
    [dp setDelegate:self];
    [self presentViewController:dp animated:YES completion:0];
}
// 相册回调
- (void)imagePickerController:(id)picker didFinishPickingMediaWithInfo:(id)info {
    LogB("PICK-DIDFINISH");
    @try {
        NSString *mt = [info objectForKeyedSubscript:@"UIImagePickerControllerMediaType"];
        _pendImg = [info objectForKeyedSubscript:@"UIImagePickerControllerOriginalImage"];
        _pendURL = [info objectForKeyedSubscript:@"UIImagePickerControllerMediaURL"];
        _pendVideo = mt && [mt isEqualToString:@"public.movie"];
        LogB(_pendImg ? "PICK-HAS-IMAGE" : "PICK-NO-IMAGE");
        [self dismissViewControllerAnimated:YES completion:0];
        [self performSelector:@selector(showNaming) withObject:0 afterDelay:0.5];
    } @catch (id e) { LogB("PICK-EXC"); }
}
- (void)notifyTapped {
    SEL sp = sel_registerName("showBannerPreview");
    SEL rs = sel_registerName("respondsToSelector:");
    id host = self;
    for (int i = 0; i < 5; i++) {
        if (((BOOL(*)(id, SEL, SEL))objc_msgSend)(host, rs, sp)) break;
        id nx = ((id(*)(id, SEL))objc_msgSend)(host, sel_registerName("presentingViewController"));
        if (!nx) nx = ((id(*)(id, SEL))objc_msgSend)(host, sel_registerName("navigationController"));
        if (!nx || nx == host) break;
        host = nx;
    }
    if (((BOOL(*)(id, SEL, SEL))objc_msgSend)(host, rs, sp))
        ((void(*)(id, SEL))objc_msgSend)(host, sp);
}
- (void)deleteTapped {
    if (!_delMode) {
        _delMode = YES;
        [_marked removeAllObjects];
        [self setTitle:@"删除模式: 点选素材"];
        [(UICollectionView *)_cv reloadData];
        return;
    }
    // 已在删除模式: 有标记则确认删除, 无则退出
    if ([_marked count] == 0) {
        _delMode = NO;
        [self setTitle:[NSString stringWithFormat:@"素材库 (%lu)", (unsigned long)[_folders count]]];
        [(UICollectionView *)_cv reloadData];
        return;
    }
    UIAlertController *cf = [UIAlertController alertControllerWithTitle:@"确认删除"
        message:[NSString stringWithFormat:@"删除 %lu 个素材?", (unsigned long)[_marked count]] preferredStyle:1];
    UIAlertAction *yes = [UIAlertAction actionWithTitle:@"删除" style:2 handler:^(UIAlertAction *a){
        NSFileManager *fm = [NSFileManager defaultManager];
        for (NSString *nm in _marked) {
            [fm removeItemAtPath:[@"/var/mobile/lddgifbg" stringByAppendingPathComponent:nm] error:0];
        }
        [_marked removeAllObjects];
        _delMode = NO;
        _folders = LDDListMaterialFolders();
        [self setTitle:[NSString stringWithFormat:@"素材库 (%lu)", (unsigned long)[_folders count]]];
        [(UICollectionView *)_cv reloadData];
    }];
    UIAlertAction *no = [UIAlertAction actionWithTitle:@"取消" style:1 handler:^(UIAlertAction *a){
    }];
    [cf addAction:yes];
    [cf addAction:no];
    [self presentViewController:cf animated:YES completion:0];
}
- (void)showNaming {
    [self askNameAndSave:_pendImg url:_pendURL isVideo:_pendVideo];
}
- (void)imagePickerControllerDidCancel:(id)picker {
    [self dismissViewControllerAnimated:YES completion:0];
}
// 文件回调
- (void)documentPicker:(id)controller didPickDocumentsAtURLs:(id)urls {
    _pendImg = 0;
    _pendURL = [urls objectAtIndex:0];
    _pendVideo = NO;
    [self dismissViewControllerAnimated:YES completion:0];
    [self performSelector:@selector(showNaming) withObject:0 afterDelay:0.5];
}
- (void)documentPickerWasCancelled:(id)controller {
    [self dismissViewControllerAnimated:YES completion:0];
}
// 命名 + 保存
- (void)askNameAndSave:(id)img url:(id)srcURL isVideo:(BOOL)isVideo {
    LogB("ASKNAME");
    UIAlertController *al = [UIAlertController alertControllerWithTitle:@"命名素材" message:@"给这个素材起个名字" preferredStyle:1];
    [al addTextFieldWithConfigurationHandler:^(UITextField *tf){
        [tf setPlaceholder:@"素材名称"];
    }];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"保存" style:0 handler:^(UIAlertAction *a){
        id tfs = [al textFields];
        UITextField *tf = [tfs objectAtIndex:0];
        NSString *nm = [tf text];
        if (!nm || [nm length] == 0) nm = @"新素材";
        [self saveMaterial:nm image:img url:srcURL isVideo:isVideo];
    }];
    UIAlertAction *cc = [UIAlertAction actionWithTitle:@"取消" style:1 handler:0];
    [al addAction:ok];
    [al addAction:cc];
    [self presentViewController:al animated:YES completion:0];
}
- (void)saveMaterial:(NSString *)nm image:(id)img url:(id)srcURL isVideo:(BOOL)isVideo {
    LogB("SAVE-START");
    @try {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *dir = [@"/var/mobile/lddgifbg" stringByAppendingPathComponent:nm];
    [fm createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:0 error:0];
    BOOL ok = NO;
    if (img) {
        id data = UIImageJPEGRepresentation(img, 0.85);
        ok = [data writeToFile:[dir stringByAppendingPathComponent:@"imported.jpg"] atomically:YES];
    } else if (srcURL) {
        NSString *ext = isVideo ? @"mov" : @"jpg";
        ok = [fm copyItemAtURL:srcURL toURL:[NSURL fileURLWithPath:[dir stringByAppendingPathComponent:[NSString stringWithFormat:@"imported.%@", ext]]] error:0];
    }
    LogB(ok ? "SAVE-OK" : "SAVE-FAIL");
    // 刷新列表
    _folders = LDDListMaterialFolders();
    NSString *cnt = [NSString stringWithFormat:@"素材库 (%lu)", (unsigned long)[_folders count]];
    [self setTitle:cnt];
    [(UICollectionView *)_cv reloadData];
    LogB("SAVE-RELOADED");
    (void)ok;
    } @catch (id e) { LogB("SAVE-EXC"); }
}
- (NSInteger)collectionView:(id)cv numberOfItemsInSection:(NSInteger)s {
    return _folders ? (NSInteger)[_folders count] : 0;
}
- (CGSize)collectionView:(id)cv layout:(id)layout sizeForItemAtIndexPath:(id)ip {
    CGRect sb = [[UIScreen mainScreen] bounds];
    double w = (sb.w - 28.0 - 20.0) / 3.0;
    CGSize sz; sz.w = w; sz.h = w * 1.0 + 62.0;
    return sz;
}
- (id)collectionView:(id)cv cellForItemAtIndexPath:(id)ip {
    NSInteger row = [ip row];
    UICollectionViewCell *cell = [(UICollectionView *)cv dequeueReusableCellWithReuseIdentifier:@"m" forIndexPath:ip];
    for (UIView *v in [[cell contentView] subviews]) { if (v) [v removeFromSuperview]; }
    if (!_folders || row >= (NSInteger)[_folders count]) return cell;
    NSString *name = [_folders objectAtIndex:(NSUInteger)row];
    CGRect cb = [[cell contentView] bounds];
    double imgH = cb.w * 1.0;
    // 白色圆角卡片 + 图
    UIView *card = [[UIView alloc] initWithFrame:MakeRect(0, 0, cb.w, imgH)];
    [card setBackgroundColor:[UIColor whiteColor]];
    [[card layer] setCornerRadius:14.0];
    [[card layer] setMasksToBounds:YES];
    UIImage *thumb = [_thumbs objectForKeyedSubscript:name];
    NSString *typeTag = @"图片";
    {
        NSString *full = [@"/var/mobile/lddgifbg" stringByAppendingPathComponent:name];
        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:full error:nil];
        for (NSString *f in files) {
            NSString *ext = [[f pathExtension] lowercaseString];
            if ([ext isEqualToString:@"gif"]) { typeTag = @"GIF"; if (!thumb) thumb = ThumbForPath([full stringByAppendingPathComponent:f]); break; }
            if ([ext isEqualToString:@"mp4"] || [ext isEqualToString:@"mov"]) { typeTag = @"视频"; if (!thumb) thumb = ThumbForPath([full stringByAppendingPathComponent:f]); break; }
            if ([ext isEqualToString:@"png"] || [ext isEqualToString:@"jpg"] || [ext isEqualToString:@"jpeg"]) { typeTag = @"图片"; if (!thumb) thumb = ThumbForPath([full stringByAppendingPathComponent:f]); }
        }
        if (thumb) [_thumbs setObject:thumb forKeyedSubscript:name];
    }
    UIImageView *iv = [[UIImageView alloc] initWithFrame:MakeRect(0, 0, cb.w, imgH)];
    [iv setImage:thumb];
    [iv setContentMode:2];
    [card addSubview:iv];
    UILabel *badge = [[UILabel alloc] initWithFrame:MakeRect(6, 6, 34, 16)];
    [badge setText:typeTag];
    [badge setFont:[UIFont systemFontOfSize:9.0]];
    [badge setTextAlignment:1];
    [badge setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.55]];
    [badge setTextColor:[UIColor whiteColor]];
    [[badge layer] setCornerRadius:8.0];
    [[badge layer] setMasksToBounds:YES];
    [card addSubview:badge];
    [[cell contentView] addSubview:card];
    // 名字胶囊
    UILabel *pill = [[UILabel alloc] initWithFrame:MakeRect(4, imgH + 8, cb.w - 8, 24)];
    [pill setText:name];
    [pill setFont:[UIFont systemFontOfSize:11.0]];
    [pill setTextAlignment:1];
    [pill setBackgroundColor:[UIColor colorWithWhite:0.62 alpha:0.85]];
    [pill setTextColor:[UIColor whiteColor]];
    [[pill layer] setCornerRadius:12.0];
    [[pill layer] setMasksToBounds:YES];
    [[cell contentView] addSubview:pill];
    // 选中圆点
    BOOL on = _sel && [_sel isEqualToString:name];
    BOOL mk = [_marked containsObject:name];
    UIView *dot = [[UIView alloc] initWithFrame:MakeRect(cb.w / 2 - 11, imgH + 38, 22, 22)];
    [[dot layer] setCornerRadius:11.0];
    [[dot layer] setMasksToBounds:YES];
    [dot setBackgroundColor:(_delMode ? (mk ? [UIColor redColor] : [UIColor colorWithWhite:0.85 alpha:1.0])
                                       : (on ? [UIColor systemBlueColor] : [UIColor colorWithWhite:0.80 alpha:1.0]))];
    [[cell contentView] addSubview:dot];
    return cell;
}
- (void)collectionView:(id)cv didSelectItemAtIndexPath:(id)ip {
    NSInteger row = [ip row];
    if (!_folders || row >= (NSInteger)[_folders count]) return;
    NSString *name = [_folders objectAtIndex:(NSUInteger)row];
    if (_delMode) {
        if ([_marked containsObject:name]) [_marked removeObject:name];
        else [_marked addObject:name];
        [(UICollectionView *)cv reloadData];
        return;
    }
    _sel = name;
    NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
    [ud setObject:name forKey:@"SelectedMaterialFolder"];
    [ud synchronize];
    WritePrefsFile(@"SelectedMaterialFolder", name);
    [(UICollectionView *)cv reloadData];
    // 1.9.144: 通知设置页刷新预览 (不依赖 viewWillAppear)
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LDDMatChanged" object:0];
}
@end

// ---------- 设置主控制器: PSListController 子类 + 直接自绘 6 行 (无模态无延迟) ----------
@interface lddgifbgRootListController : PSListController
- (NSInteger)numberOfSectionsInTableView:(id)tv;
- (NSInteger)tableView:(id)tv numberOfRowsInSection:(NSInteger)s;
- (id)tableView:(id)tv cellForRowAtIndexPath:(id)ip;
- (void)tableView:(id)tv didSelectRowAtIndexPath:(id)ip;
// 1.9.153: 点击数值弹出输入框
- (void)valTapped:(UITapGestureRecognizer *)g;
@end


@implementation lddgifbgRootListController
- (void)showBannerPreview {
    @try {
        // 1.9.90: 只走文件通道(单通道)。此前双通道(文件+notify)在 SpringBoard 端
        // 因 main 队列串行+投递阻塞, 时间窗口去重失效 -> 每次点击弹两条/连点积压十几条。
        // 文件通道由布局 hook 消费(remove), 每次点击恰好触发一次投递。
        // 按钮 2s 连点去重 + 文件内容带时间戳 (SB 端按内容去重, 防残留双弹)
        // 1.9.126: 去掉按钮 1s 去重 —— 点多少下都立即写文件立即弹
        NSString *tsStr = [NSString stringWithFormat:@"%ld", (long)time(0)];
        id tsData = ((id(*)(id, SEL, NSUInteger))objc_msgSend)(tsStr, sel_registerName("dataUsingEncoding:"), (NSUInteger)4);
        [[NSFileManager defaultManager] createFileAtPath:@"/var/mobile/lddgifbg/__force_preview__" contents:tsData attributes:0];
        return;
    } @catch (id e) {}
}
- (void)viewDidLoad {
    LogB("ROOT-VIEWDIDLOAD");
    @try { [super viewDidLoad]; } @catch (id e) { LogB("ROOT-VD-EXC"); }
    [self setTitle:@"灵动岛GIF背景"];
    // 1.9.144: 素材切换通知 -> 强制刷新预览行
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(matChanged) name:@"LDDMatChanged" object:0];
}
// 1.9.144: 素材切换后刷新
- (void)matChanged {
    LogB("MAT-CHANGED-NOTIFY");
    id tb = [self table];
    if (tb) [tb reloadData];
}
// 1.9.140: 从素材选择器返回时刷新预览行 (跟随新素材)
- (void)viewWillAppear:(BOOL)animated {
    @try { [super viewWillAppear:animated]; } @catch (id e) { LogB("ROOT-WVA-EXC"); }
    // 1.9.141: 素材选择返回后刷新预览行 (探针验证 table 是否取到)
    id tb = [self table];
    if (tb) { [tb reloadData]; LogB("PREVIEW-RELOAD-OK"); }
    else LogB("PREVIEW-RELOAD-NO-TABLE");
}
- (id)specifiers {
    @try { return [self loadSpecifiersFromPlistName:@"Root" target:self]; }
    @catch (id e) { LogB("ROOT-SPEC-EXC"); }
    return [NSArray array];
}
- (NSInteger)numberOfSectionsInTableView:(id)tv { return 1; }
// 1.9.140: 行数 10 (0/1开关 2预览 3水平偏移 4垂直偏移 5速度 6选素材 7跳转 8预览通知 9注销)
- (NSInteger)tableView:(id)tv numberOfRowsInSection:(NSInteger)s { return 10; }
// 1.9.156: 输入框预填值去小数 (偏移=整数, 速度=去尾零保留1位)
static NSString *LDDInputNum(double v, BOOL isSpeed) {
    if (!isSpeed) return [NSString stringWithFormat:@"%.0f", v];
    double r = round(v * 10.0) / 10.0;
    if (r == (double)(long long)r) return [NSString stringWithFormat:@"%.0f", r];
    return [NSString stringWithFormat:@"%.1f", r];
}
// 1.9.146: 预览尺寸 (真实岛比例 + 面板宽缩放), heightForRow/cellForRow 共用
static void LDDPreviewSize(double bw, double *piw, double *pih) {
    double iw = bw - 32, ih = 100;
    NSString *isz = [NSString stringWithContentsOfFile:@"/var/mobile/lddgifbg/__island_size__" encoding:4 error:0];
    if (isz) {
        NSArray *parts = [isz componentsSeparatedByString:@" "];
        if ([parts count] >= 2) {
            double w2 = [[parts objectAtIndex:0] doubleValue], h2 = [[parts objectAtIndex:1] doubleValue];
            if (w2 >= 200 && h2 >= 40) { iw = w2; ih = h2; } // 1.9.151: 忽略收起小尺寸, 保持大预览
        }
    }
    // 1.9.147: 预览宽度直接撑满面板可用宽度 (左右不留白), 高度等比保持岛比例
    if (iw > bw) { double sc = bw / iw; iw = bw; ih *= sc; }
    *piw = iw; *pih = ih;
}
- (double)tableView:(id)tv heightForRowAtIndexPath:(id)ip {
    if ([ip row] == 2) {
        // 1.9.146: 预览行高度贴合预览药丸, 消除上下大面积留白
        CGRect tb = [tv bounds];
        double bw = tb.w; if (bw < 100) bw = 390;
        double iw = 0, ih = 0;
        LDDPreviewSize(bw, &iw, &ih);
        return 14.0 + ih + 14.0;
    }
    return 60.0;
}
- (double)tableView:(id)tv estimatedHeightForRowAtIndexPath:(id)ip { return 60.0; }
- (double)tableView:(id)tv heightForHeaderInSection:(NSInteger)s { return 0.0; }
- (double)tableView:(id)tv heightForFooterInSection:(NSInteger)s { return 0.0; }
- (id)tableView:(id)tv viewForHeaderInSection:(NSInteger)s { return nil; }
- (id)tableView:(id)tv viewForFooterInSection:(NSInteger)s { return nil; }
- (id)tableView:(id)tv titleForHeaderInSection:(NSInteger)s { return @""; }
- (id)tableView:(id)tv titleForFooterInSection:(NSInteger)s { return @""; }
- (id)tableView:(id)tv cellForRowAtIndexPath:(id)ip {
    NSInteger row = [ip row];
    static int logged = 0;
    if (!logged) { logged = 1; LogB("ROOT-CELL-RENDERED"); }
    UITableView *table = (UITableView *)tv;
    UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:@"c"];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:1 reuseIdentifier:@"c"];
    CGRect b = [[cell contentView] bounds];
    for (UIView *v in [[cell contentView] subviews]) { if (v) [v removeFromSuperview]; }
    [cell setSelectionStyle:0];
    [cell setAccessoryType:0];
    if (row == 0 || row == 1) {
        UILabel *label = [[UILabel alloc] initWithFrame:MakeRect(16, 19, b.w - 110, 22)];
        [label setText:(row == 0 ? @"启用总开关" : @"启用小岛")];
        [label setFont:[UIFont systemFontOfSize:16.0]];
        [[cell contentView] addSubview:label];
        UISwitch *sw = [[UISwitch alloc] initWithFrame:MakeRect(b.w - 67, 14, 51, 31)];
        [sw setTag:(row == 0 ? 1001 : 1002)];
        NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
        id v = [ud objectForKey:(row == 0 ? @"Enablelddgifbg" : @"Enablezxhlddgifbg")];
        BOOL on = v ? [v boolValue] : YES;
        [sw setOn:on animated:NO];
        [sw addTarget:self action:@selector(switchToggled:) forControlEvents:1 << 12];
        [[cell contentView] addSubview:sw];
    } else if (row == 2) {
        // 1.9.140: 实时预览 (黑底药丸模拟灵动岛 + 素材首帧 + 当前偏移)
        [cell setSelectionStyle:0];
        // 1.9.146: 尺寸统一走 LDDPreviewSize (岛比例 + 面板宽缩放)
        double iw = 0, ih = 0;
        LDDPreviewSize(b.w, &iw, &ih);
        CGRect cb = MakeRect((b.w - iw) / 2.0, 14, iw, ih);
        UIView *box = [[UIView alloc] initWithFrame:cb];
        [box setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:1.0]];
        [box setTag:2010];
        id blay = [box layer];
        [blay setCornerRadius:ih / 2.0];
        [blay setMasksToBounds:YES];
        [[cell contentView] addSubview:box];
        gPrevContainer = box;
        NSString *ppath = SelectedMaterialPathForPreview();
        UIImage *pimg = ppath ? ThumbForPath(ppath) : nil;
        if (pimg) {
            CGSize isz = [pimg size];
            double cw = cb.w, ch = cb.h;
            double sc = (cw / isz.w) > (ch / isz.h) ? (cw / isz.w) : (ch / isz.h);
            cw = isz.w * sc; ch = isz.h * sc;
            gPrevW = isz.w; gPrevH = isz.h;
            UIImageView *piv = [[UIImageView alloc] initWithFrame:MakeRect((cb.w - cw) / 2.0, (cb.h - ch) / 2.0, cw, ch)];
            [piv setContentMode:2];
            [piv setImage:pimg];
            [piv setTag:2011];
            [box addSubview:piv];
            gPrevContent = piv;
        } else {
            gPrevW = 0; gPrevH = 0; gPrevContent = nil;
            UILabel *tip = [[UILabel alloc] initWithFrame:MakeRect(0, 0, cb.w, cb.h)];
            [tip setText:@"未选择素材"];
            [tip setTextColor:[UIColor whiteColor]];
            [tip setTextAlignment:1];
            [tip setFont:[UIFont systemFontOfSize:14.0]];
            [box addSubview:tip];
        }
        LDDUpdatePreview();
    } else if (row == 3) {
        // 1.9.140: 水平偏移 (左右调整显示区域, -200~200, 默认0)
        UILabel *label = [[UILabel alloc] initWithFrame:MakeRect(16, 8, b.w - 32, 20)];
        [label setText:@"水平偏移"];
        [label setFont:[UIFont systemFontOfSize:15.0]];
        [[cell contentView] addSubview:label];
        UISlider *sl = [[UISlider alloc] initWithFrame:MakeRect(16, 30, b.w - 108, 28)];
        [sl setMinimumValue:-200];
        [sl setMaximumValue:200];
        NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
        id v = [ud objectForKey:@"lddgifbgPosX"];
        double dv = v ? [v doubleValue] : 0.0;
        [sl setValue:dv];
        [sl setTag:3003];   // 1.9.153: 自定义输入后同步滑块
        LogB("CELL-POSX-SLIDER");
        [sl addTarget:self action:@selector(posXChanged:) forControlEvents:(1 << 12) | (1 << 6) | (1 << 7)];
        [[cell contentView] addSubview:sl];
        // 1.9.152: 滑块右侧实时数值
        UILabel *vl = [[UILabel alloc] initWithFrame:MakeRect(b.w - 92, 33, 76, 22)];
        [vl setTextAlignment:2];
        [vl setFont:[UIFont systemFontOfSize:15.0]];
        [vl setTag:2023];
        [vl setText:[NSString stringWithFormat:@"%.0f", dv]];
        // 1.9.153: 点击数值可自定义输入
        [vl setUserInteractionEnabled:YES];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(valTapped:)];
        [vl addGestureRecognizer:tap];
        [[cell contentView] addSubview:vl];
    } else if (row == 4) {
        // 1.9.140: 垂直偏移 (上下调整显示区域, -200~200, 默认0)
        UILabel *label = [[UILabel alloc] initWithFrame:MakeRect(16, 8, b.w - 32, 20)];
        [label setText:@"垂直偏移"];
        [label setFont:[UIFont systemFontOfSize:15.0]];
        [[cell contentView] addSubview:label];
        UISlider *sl = [[UISlider alloc] initWithFrame:MakeRect(16, 30, b.w - 108, 28)];
        [sl setMinimumValue:-200];
        [sl setMaximumValue:200];
        NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
        id v = [ud objectForKey:@"lddgifbgPosY"];
        double dv = v ? [v doubleValue] : 0.0;
        [sl setValue:dv];
        [sl setTag:3004];   // 1.9.153
        LogB("CELL-POSY-SLIDER");
        [sl addTarget:self action:@selector(posYChanged:) forControlEvents:(1 << 12) | (1 << 6) | (1 << 7)];
        [[cell contentView] addSubview:sl];
        // 1.9.152: 滑块右侧实时数值
        UILabel *vl = [[UILabel alloc] initWithFrame:MakeRect(b.w - 92, 33, 76, 22)];
        [vl setTextAlignment:2];
        [vl setFont:[UIFont systemFontOfSize:15.0]];
        [vl setTag:2024];
        [vl setText:[NSString stringWithFormat:@"%.0f", dv]];
        // 1.9.153: 点击数值可自定义输入
        [vl setUserInteractionEnabled:YES];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(valTapped:)];
        [vl addGestureRecognizer:tap];
        [[cell contentView] addSubview:vl];
    } else if (row == 5) {
        // 1.9.133: 播放速度滑块 (0.5x~2.0x)
        UILabel *label = [[UILabel alloc] initWithFrame:MakeRect(16, 8, b.w - 32, 20)];
        [label setText:@"播放速度"];
        [label setFont:[UIFont systemFontOfSize:15.0]];
        [[cell contentView] addSubview:label];
        UISlider *sl = [[UISlider alloc] initWithFrame:MakeRect(16, 30, b.w - 108, 28)];
        [sl setMinimumValue:0.5];
        [sl setMaximumValue:3.0];   // 1.9.152: 支持到三倍速
        NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
        id v = [ud objectForKey:@"lddgifbgSpeed"];
        double dv = v ? [v doubleValue] : 1.0;
        if (dv <= 0) dv = 1.0;
        [sl setValue:dv];
        [sl setTag:3005];   // 1.9.153
        LogB("CELL-SPEED-SLIDER");
        [sl addTarget:self action:@selector(speedChanged:) forControlEvents:(1 << 12) | (1 << 6) | (1 << 7)];
        [[cell contentView] addSubview:sl];
        // 1.9.152: 滑块右侧实时数值 (倍速)
        UILabel *vl = [[UILabel alloc] initWithFrame:MakeRect(b.w - 92, 33, 76, 22)];
        [vl setTextAlignment:2];
        [vl setFont:[UIFont systemFontOfSize:15.0]];
        [vl setTag:2025];
        [vl setText:[NSString stringWithFormat:@"%.1fx", dv]];
        // 1.9.153: 点击数值可自定义输入
        [vl setUserInteractionEnabled:YES];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(valTapped:)];
        [vl addGestureRecognizer:tap];
        [[cell contentView] addSubview:vl];
    } else {
        NSString *t = (row == 6 ? @"选择素材" : (row == 7 ? @"跳转素材目录" : (row == 8 ? @"预览通知" : @"立即注销")));
        UILabel *label = [[UILabel alloc] initWithFrame:MakeRect(16, 19, b.w - 60, 22)];
        [label setText:t];
        [label setFont:[UIFont systemFontOfSize:16.0]];
        if (row == 9) [label setTextColor:[UIColor redColor]];
        [[cell contentView] addSubview:label];
        [cell setSelectionStyle:1];
    }
    return cell;
}
- (void)tableView:(id)tv didSelectRowAtIndexPath:(id)ip {
    NSInteger row = [ip row];
    [(UITableView *)tv deselectRowAtIndexPath:ip animated:YES];
    // 1.9.140: 行号与 UI 同步 (0/1开关 2预览 3水平偏移 4垂直偏移 5速度 6选素材 7跳转 8预览通知 9注销)
    if (row == 6) {
        LDDMaterialPickerController *pc = [[LDDMaterialPickerController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:pc];
        [self presentViewController:nav animated:YES completion:0];
    } else if (row == 7) {
        UIApplication *app = [UIApplication sharedApplication];
        NSURL *fz = [NSURL URLWithString:@"filza://view/var/mobile/lddgifbg"];
        [app openURL:fz options:[NSDictionary dictionary] completionHandler:^(BOOL ok){
            if (!ok) {
                NSURL *url = [NSURL fileURLWithPath:@"/var/mobile/lddgifbg"];
                [app openURL:url options:[NSDictionary dictionary] completionHandler:0];
            }
        }];
    } else if (row == 8) {
        [self showBannerPreview];
    } else if (row == 9) {
        [self respringNow];
    }
}
- (void)switchToggled:(UISwitch *)sw {
    NSString *key = ([sw tag] == 1001 ? @"Enablelddgifbg" : @"Enablezxhlddgifbg");
    BOOL on = [sw isOn];
    NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
    [ud setObject:[NSNumber numberWithBool:on] forKey:key];
    [ud synchronize];
    WritePrefsFile(key, [NSNumber numberWithBool:on]);
}
- (void)posXChanged:(UISlider *)sl {
    double dv = [sl value];
    { char bl[96]; snprintf(bl, sizeof(bl), "POSX-CHANGED %.2f", dv); LogB(bl); }
    NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
    [ud setObject:[NSNumber numberWithDouble:dv] forKey:@"lddgifbgPosX"];
    [ud synchronize];
    WritePrefsFile(@"lddgifbgPosX", [NSNumber numberWithDouble:dv]);
    { id rv = [ud objectForKey:@"lddgifbgPosX"]; double rd = rv ? [rv doubleValue] : -1.0; char bl[96]; snprintf(bl, sizeof(bl), "WRITE-POSX-OK %.2f", rd); LogB(bl); }
    // 1.9.152: 更新右侧数值显示
    id cv = [sl superview];
    if (cv) { UILabel *vl = (UILabel *)[cv viewWithTag:2023]; if (vl) [vl setText:[NSString stringWithFormat:@"%.0f", dv]]; }
    // 1.9.140: 实时刷新预览位置
    LDDUpdatePreview();
}
- (void)posYChanged:(UISlider *)sl {
    double dv = [sl value];
    { char bl[96]; snprintf(bl, sizeof(bl), "POSY-CHANGED %.2f", dv); LogB(bl); }
    NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
    [ud setObject:[NSNumber numberWithDouble:dv] forKey:@"lddgifbgPosY"];
    [ud synchronize];
    WritePrefsFile(@"lddgifbgPosY", [NSNumber numberWithDouble:dv]);
    { id rv = [ud objectForKey:@"lddgifbgPosY"]; double rd = rv ? [rv doubleValue] : -1.0; char bl[96]; snprintf(bl, sizeof(bl), "WRITE-POSY-OK %.2f", rd); LogB(bl); }
    // 1.9.152: 更新右侧数值显示
    id cv = [sl superview];
    if (cv) { UILabel *vl = (UILabel *)[cv viewWithTag:2024]; if (vl) [vl setText:[NSString stringWithFormat:@"%.0f", dv]]; }
    // 1.9.140: 实时刷新预览位置
    LDDUpdatePreview();
}
- (void)speedChanged:(UISlider *)sl {
    double dv = [sl value];
    { char bl[96]; snprintf(bl, sizeof(bl), "SPEED-CHANGED %.2f", dv); LogB(bl); }
    NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
    [ud setObject:[NSNumber numberWithDouble:dv] forKey:@"lddgifbgSpeed"];
    [ud synchronize];
    WritePrefsFile(@"lddgifbgSpeed", [NSNumber numberWithDouble:dv]);
    // 1.9.137: 写后回读验证
    { id rv = [ud objectForKey:@"lddgifbgSpeed"]; double rd = rv ? [rv doubleValue] : -1.0; char bl[96]; snprintf(bl, sizeof(bl), "WRITE-SPEED-OK %.2f", rd); LogB(bl); }
    // 1.9.152: 更新右侧数值显示
    id cv = [sl superview];
    if (cv) { UILabel *vl = (UILabel *)[cv viewWithTag:2025]; if (vl) [vl setText:[NSString stringWithFormat:@"%.1fx", dv]]; }
}
// 1.9.153: 点击数值 -> 弹输入框自定义填入, 同步滑块/预览/prefs
- (void)valTapped:(UITapGestureRecognizer *)g {
    id vl = [g view];
    NSInteger tag = [vl tag];
    if (tag != 2023 && tag != 2024 && tag != 2025) return;
    NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
    NSString *key = (tag == 2023 ? @"lddgifbgPosX" : (tag == 2024 ? @"lddgifbgPosY" : @"lddgifbgSpeed"));
    id cur = [ud objectForKey:key];
    double dv = cur ? [cur doubleValue] : 0.0;
    NSString *title = (tag == 2023 ? @"水平偏移数值" : (tag == 2024 ? @"垂直偏移数值" : @"播放速度数值"));
    NSString *hint = (tag == 2025 ? @"输入 0.5 ~ 3.0 倍速" : @"输入 -200 ~ 200");
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:title message:hint preferredStyle:1];   // 1.9.154: 必须 Alert(1), ActionSheet(0) 不允许加输入框会崩
    [ac addTextFieldWithConfigurationHandler:^(UITextField *tf){
        [tf setKeyboardType:4];
        [tf setText:LDDInputNum(dv, (tag == 2025))];   // 1.9.156: 偏移整数, 速度去尾零
    }];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:0 handler:^(UIAlertAction *a){
        id tfs = [ac textFields];
        UITextField *tf = [tfs objectAtIndex:0];
        NSString *txt = [tf text];
        double nv = [txt doubleValue];
        if (tag == 2025) {
            if (nv < 0.5) nv = 0.5;
            if (nv > 3.0) nv = 3.0;
        } else {
            if (nv < -200) nv = -200;
            if (nv > 200) nv = 200;
        }
        [ud setObject:[NSNumber numberWithDouble:nv] forKey:key];
        [ud synchronize];
        WritePrefsFile(key, [NSNumber numberWithDouble:nv]);
        // 同步滑块
        id cv = [vl superview];
        if (cv) {
            UISlider *sl = (UISlider *)[cv viewWithTag:(tag == 2023 ? 3003 : (tag == 2024 ? 3004 : 3005))];
            if (sl) [sl setValue:nv];
        }
        // 更新数值显示
        if (tag == 2025) [(UILabel *)vl setText:[NSString stringWithFormat:@"%.1fx", nv]];
        else [(UILabel *)vl setText:[NSString stringWithFormat:@"%.0f", nv]];
        // 偏移输入后刷新预览
        if (tag == 2023 || tag == 2024) LDDUpdatePreview();
    }];
    [ac addAction:ok];
    UIAlertAction *cc = [UIAlertAction actionWithTitle:@"取消" style:1 handler:0];
    [ac addAction:cc];
    [self presentViewController:ac animated:YES completion:0];
}
- (void)testNotification {
    PostTestNotification();
}
- (void)respringNow {
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL have = [fm fileExistsAtPath:@"/var/jb/usr/bin/sbreload"];
    static int (*spawn_fn)(void *, const char *, void *, void *, char *const[], char *const[]);
    if (!spawn_fn) {
        void *h = dlopen(0, 1);
        if (h) spawn_fn = (int (*)(void *, const char *, void *, void *, char *const[], char *const[]))dlsym(h, "posix_spawn");
    }
    if (spawn_fn) {
        if (have) {
            char *argv1[] = {(char *)"/var/jb/usr/bin/sbreload", 0};
            spawn_fn(0, "/var/jb/usr/bin/sbreload", 0, 0, argv1, 0);
        } else {
            char *argv2[] = {(char *)"/var/jb/usr/bin/killall", (char *)"SpringBoard", 0};
            spawn_fn(0, "/var/jb/usr/bin/killall", 0, 0, argv2, 0);
        }
    }
}
@end
