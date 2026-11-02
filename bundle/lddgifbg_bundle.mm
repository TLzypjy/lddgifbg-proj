// 灵动岛背景美化 —— 重制版设置 Bundle (v3: 全标准 ObjC 语法, 适配 arm64e)
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
- (void)removeObjectForKey:(id)k;
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
- (BOOL)moveItemAtPath:(NSString *)p toPath:(NSString *)t error:(id *)e;
- (BOOL)createFileAtPath:(NSString *)p contents:(id)c attributes:(id)a;
- (id)contentsOfDirectoryAtPath:(NSString *)p error:(id *)e;
@end
@interface NSUserDefaults : NSObject
- (id)initWithSuiteName:(NSString *)n;
- (id)objectForKey:(id)k;
- (void)setObject:(id)obj forKey:(id)k;
- (void)removeObjectForKey:(NSString *)k;
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
- (void)addGestureRecognizer:(id)g;
- (void)setAutoresizingMask:(NSUInteger)m;
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
@interface UIGestureRecognizer : NSObject
- (id)initWithTarget:(id)target action:(SEL)action;
- (long)state;
- (id)view;
- (CGPoint)locationInView:(id)v;
@end
@interface UILongPressGestureRecognizer : UIGestureRecognizer
- (void)setMinimumPressDuration:(double)d;
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
- (void)sizeToFit;
- (CGRect)frame;
- (void)setFrame:(CGRect)r;
@end
@interface UITextField : UIView
- (void)setPlaceholder:(NSString *)p;
- (id)text;
- (void)setText:(NSString *)t;
- (void)setKeyboardType:(NSInteger)k;
// 1.9.191: 素材网格行内改名
- (void)setFont:(id)f;
- (void)setBorderStyle:(NSInteger)s;
- (void)setReturnKeyType:(NSInteger)t;
- (void)setDelegate:(id)d;
- (void)setClearButtonMode:(NSInteger)m;
- (void)setAutocapitalizationType:(NSInteger)t;
- (void)setAutocorrectionType:(NSInteger)t;
- (void)setTextAlignment:(NSInteger)a;
- (void)becomeFirstResponder;
- (void)resignFirstResponder;
@end
// 1.9.153: 点击数值自定义输入
@interface UITapGestureRecognizer : NSObject
- (id)initWithTarget:(id)t action:(SEL)a;
- (id)view;
@end
// 1.9.185: 越狱源点击复制
@interface UIPasteboard : NSObject
+ (id)generalPasteboard;
- (void)setString:(id)s;
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
- (void)viewDidLayoutSubviews;
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
- (double)minimumInteritemSpacing;
- (void)setMinimumLineSpacing:(double)s;
- (void)setItemSize:(CGSize)s;
- (CGSize)itemSize;
- (void)setSectionInset:(UIEdgeInsets)i;
- (UIEdgeInsets)sectionInset;
- (void)invalidateLayout;
@end
@interface UICollectionView : UIView
- (id)initWithFrame:(CGRect)f collectionViewLayout:(id)layout;
- (id)collectionViewLayout;
- (void)setBackgroundColor:(id)c;
- (void)setDelegate:(id)d;
- (void)setDataSource:(id)d;
- (void)registerClass:(id)cls forCellWithReuseIdentifier:(NSString *)ri;
- (id)dequeueReusableCellWithReuseIdentifier:(NSString *)ri forIndexPath:(id)ip;
- (void)reloadData;
- (id)indexPathForItemAtPoint:(CGPoint)p;
// 1.9.191: 素材网格编辑态抖动/行内改名
- (id)visibleCells;
- (id)cellForItemAtIndexPath:(id)ip;
- (CGPoint)contentOffset;
- (void)setContentOffset:(CGPoint)o animated:(BOOL)a;
- (UIEdgeInsets)contentInset;
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
- (id)userInfo;
- (void)invalidate;
@end
@interface CALayer : NSObject
- (void)setCornerRadius:(double)r;
- (void)setMasksToBounds:(BOOL)b;
- (void)setShadowColor:(CGColorRef)c;
- (void)setShadowOpacity:(float)o;
- (void)setShadowRadius:(double)r;
- (void)setShadowOffset:(CGSize)s;
// 1.9.191: 素材网格编辑态抖动
- (void)addAnimation:(id)a forKey:(NSString *)k;
- (void)removeAnimationForKey:(NSString *)k;
@end
// 1.9.191: 素材网格编辑态抖动动画 (属性走 KVC setValue:forKey:)
@interface CABasicAnimation : NSObject
+ (id)animationWithKeyPath:(NSString *)key;
@end
@interface PSListController : UIViewController
- (id)loadSpecifiersFromPlistName:(NSString *)n target:(id)t;
- (id)specifiers;
// 1.9.140: 素材选择返回后刷新 (预览行跟随)
- (id)table;
@end
@interface NSBundle : NSObject
+ (id)mainBundle;
+ (id)bundleForClass:(Class)c;
- (NSString *)pathForResource:(NSString *)n ofType:(NSString *)t;
- (id)objectForInfoDictionaryKey:(NSString *)k;
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
// 素材库布局探针: 写入用户可直接回传的 __plugin_probe__.txt (与主逻辑 ProbeWrite 同文件)
static void PwB(const char *s) {
    FILE *f = fopen("/var/mobile/lddgifbg/__plugin_probe__.txt", "a");
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
- (void)closeTapped;
- (void)viewDidLayoutSubviews;
- (void)kbdWillShow:(id)n;
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
    BOOL _editMode;
    id _activeField;
    NSString *_activeName;
    id _activeCell;
    id _activeLabel; // 1.9.192: 行内改名中被隐藏的名字 label, 结束时恢复显示
    id _activeIp;    // 1.9.201: 正在改名的 cell 的 indexpath, 键盘弹出时滚动到可视区
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"素材库"];
    UIBarButtonItem *close = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:0 target:self action:@selector(closeTapped)];
    [[self navigationItem] setLeftBarButtonItem:close];
    UIBarButtonItem *imp = [[UIBarButtonItem alloc] initWithTitle:@"导入" style:0 target:self action:@selector(importTapped)];
    [[self navigationItem] setRightBarButtonItems:[NSArray arrayWithObjects:imp, nil]];
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
    [flow setMinimumInteritemSpacing:0];
    [flow setMinimumLineSpacing:0];
    UIEdgeInsets ins; ins.top = 14; ins.left = 16; ins.bottom = 70; ins.right = 16;
    [flow setSectionInset:ins];
    // 1.9.195: item 精确 = 行宽/3 (不含间距), 间距归零, 任何手机宽度下每行必然恰好 3 个;
    // 列间距改由卡片自身左右缩进 6pt 呈现, 不再依赖 flow 的 interitem 判定
    CGRect sb = [[UIScreen mainScreen] bounds];
    double iw = (sb.w - 32.0) / 3.0;
    double ih = (iw - 12.0) + 56.0;
    CGSize isz; isz.w = iw; isz.h = ih;
    [flow setItemSize:isz];
    CGRect vb = [[self view] bounds];
    UICollectionView *cv = [[UICollectionView alloc] initWithFrame:vb collectionViewLayout:flow];
    {
        char bl[160];
        snprintf(bl, sizeof(bl), "MAT-FLOW-A set item=%.2f x%.2f inter=0 insL=16 insR=16 viewW=%.1f", iw, ih, vb.w);
        PwB(bl);
    }
    [cv setBackgroundColor:[UIColor clearColor]];
    [cv setDelegate:self];
    [cv setDataSource:self];
    [cv registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"m"];
    UILongPressGestureRecognizer *lp = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressTapped:)];
    [lp setMinimumPressDuration:0.4];
    [cv addGestureRecognizer:lp];
    [[self view] addSubview:cv];
    _cv = cv;
    // 1.9.201: 键盘弹出 -> 把正在改名的 cell 滚到可视区 (底两行改名不再被键盘盖住)
    // 1.9.203: 探针改写 PwB (用户回传的 __plugin_probe__.txt), 不再写 bundle.log; 加 DidShow 双保险
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbdWillShow:) name:@"UIKeyboardWillShowNotification" object:0];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbdDidShow:) name:@"UIKeyboardDidShowNotification" object:0];
    PwB("KBD-OBS-ADDED");
    NSString *cnt = [NSString stringWithFormat:@"素材库 (%lu)", (unsigned long)[_folders count]];
    [self setTitle:cnt];
}
// 1.9.194: 布局完成后核对/强制 3 列 (探针日志 + 兜底修正)
- (void)viewDidLayoutSubviews {
    @try {
        [super viewDidLayoutSubviews];
        if (!_cv) return;
        UICollectionView *c = (UICollectionView *)_cv;
        CGRect b = [c bounds];
        UICollectionViewFlowLayout *fl = (UICollectionViewFlowLayout *)[c collectionViewLayout];
        CGSize its = [fl itemSize];
        double inter = [fl minimumInteritemSpacing];
        UIEdgeInsets si = [fl sectionInset];
        double want = (b.w - 32.0) / 3.0;
        {
            char bl[200];
            snprintf(bl, sizeof(bl), "MAT-RELAYOUT cvW=%.1f cvH=%.1f item=%.2f inter=%.1f insL=%.1f insR=%.1f want=%.2f",
                     b.w, b.h, its.w, inter, si.left, si.right, want);
            PwB(bl);
        }
        if (want > 1.0 && (its.w - want) > 1.0) {
            CGSize nz; nz.w = want; nz.h = (want - 12.0) + 56.0;
            [fl setItemSize:nz];
            [fl setMinimumInteritemSpacing:0];
            UIEdgeInsets ni; ni.top = 14; ni.left = 16; ni.bottom = 70; ni.right = 16;
            [fl setSectionInset:ni];
            [fl invalidateLayout];
            { char bl[160]; snprintf(bl, sizeof(bl), "MAT-FORCED item=%.2f inter=0", want); PwB(bl); }
        }
    } @catch (id e) { LogB("MAT-RELAYOUT-EXC"); }
}
- (void)closeTapped {
    [self dismissViewControllerAnimated:YES completion:0];
}
// 1.9.191: 长按缩略图 -> 进入编辑态(全网格抖动 + 红-删除钮), 点名字 -> 行内改名 (同 cc 播放器素材库交互)
- (void)longPressTapped:(id)lp {
    if ((long)[lp state] != 1) return; // UIGestureRecognizerStateBegan
    id v = [lp view];
    CGPoint p = [lp locationInView:v];
    NSIndexPath *ip = [(UICollectionView *)_cv indexPathForItemAtPoint:p];
    if (!ip) return;
    NSInteger row = [ip row];
    if (!_folders || row >= (NSInteger)[_folders count]) return;
    [self enterEditing];
}
- (void)enterEditing {
    if (_editMode) return;
    _editMode = YES;
    [self setTitle:@"长按完成退出"];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:0 target:self action:@selector(exitEditing)];
    [[self navigationItem] setRightBarButtonItems:[NSArray arrayWithObjects:done, nil]];
    [(UICollectionView *)_cv reloadData];
    [self startJiggling];
}
- (void)exitEditing {
    if (!_editMode) return;
    if (_activeField) [_activeField resignFirstResponder]; // 保存未完成的改名
    [self stopJiggling];
    _editMode = NO;
    UIBarButtonItem *imp = [[UIBarButtonItem alloc] initWithTitle:@"导入" style:0 target:self action:@selector(importTapped)];
    [[self navigationItem] setRightBarButtonItems:[NSArray arrayWithObjects:imp, nil]];
    [self setTitle:[NSString stringWithFormat:@"素材库 (%lu)", (unsigned long)[_folders count]]];
    [(UICollectionView *)_cv reloadData];
}
// 抖动动画: 挂在缩略图卡片(tag 911) layer 上, 删除钮是卡片子视图 -> 随卡片一起抖
- (void)jiggleCard:(id)card {
    id anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    [anim setValue:[NSNumber numberWithDouble:-0.03] forKey:@"fromValue"];
    [anim setValue:[NSNumber numberWithDouble:0.03] forKey:@"toValue"];
    [anim setValue:[NSNumber numberWithDouble:0.12] forKey:@"duration"];
    [anim setValue:[NSNumber numberWithBool:YES] forKey:@"autoreverses"];
    [anim setValue:[NSNumber numberWithDouble:100000] forKey:@"repeatCount"];
    [[card layer] addAnimation:anim forKey:@"lddJiggle"];
}
- (void)startJiggling {
    for (id c in [(UICollectionView *)_cv visibleCells]) {
        id card = [c viewWithTag:911];
        if (card) [self jiggleCard:card];
    }
}
- (void)stopJiggling {
    for (id c in [(UICollectionView *)_cv visibleCells]) {
        id card = [c viewWithTag:911];
        if (card) [[card layer] removeAnimationForKey:@"lddJiggle"];
    }
}
// 删除钮: 手势绑定素材名
static const char kLDDDelKey = 0;
- (void)delBtnTapped:(UITapGestureRecognizer *)g {
    NSString *name = objc_getAssociatedObject(g, &kLDDDelKey);
    if (name) [self confirmDelete:name];
}
// 点名字 -> 行内改名
static const char kLDDNameKey = 0;
- (void)nameTapped:(UITapGestureRecognizer *)g {
    NSString *name = objc_getAssociatedObject(g, &kLDDNameKey);
    if (!name) return;
    id pill = [g view];              // pill (名字胶囊)
    id contentV = [pill superview];  // contentView
    id cell = [contentV superview];  // cell
    if (!cell) return;
    [self beginRename:name inCell:cell atPill:pill];
}
- (void)beginRename:(NSString *)name inCell:(id)cell atPill:(id)pill {
    if (_activeField) [_activeField resignFirstResponder]; // 先结束上一次未完成的编辑
    id lab = [pill viewWithTag:922]; // 名字文字 label
    CGRect lf = [pill frame];
    if (lab) [lab setHidden:YES];
    // 1.9.201: 记住位置, 键盘弹出时滚动 (存根工程无 UICollectionView 接口 -> objc_msgSend)
    _activeIp = ((id(*)(id, SEL, id))objc_msgSend)((UICollectionView *)_cv, sel_registerName("indexPathForCell:"), cell);
    UITextField *tf = [[UITextField alloc] initWithFrame:lf];
    [tf setText:name];
    [tf setFont:[UIFont systemFontOfSize:11.0]];
    [tf setTextAlignment:1];
    [tf setBorderStyle:3];     // UITextBorderStyleRoundedRect
    [tf setReturnKeyType:9];   // UIReturnKeyDone
    [tf setClearButtonMode:2]; // UITextFieldViewModeWhileEditing
    [tf setAutocapitalizationType:0];
    [tf setAutocorrectionType:1];
    [tf setDelegate:self];
    [tf setTag:955];
    [[cell contentView] addSubview:tf];
    _activeField = tf;
    _activeName = name;
    _activeCell = cell;
    _activeLabel = lab;
    [tf becomeFirstResponder];
}
// 1.9.205: 键盘弹出 -> 把正在改名的 cell 直接滚到集合视图可视区顶部, 完全露出。
// 1.9.203 的 scrollToItemAtIndexPath:Top 实测静默失效(1.9.141 段 KBD-SCROLL-OK 4 次但内容未滚动,
// 用户: 素材比较上它已经滚动不了了, 截图证实第 1 行仍在顶部) -> 改用 _activeCell.frame
// 直接 setContentOffset 到 cell.origin.y - contentInset.top, 不依赖系统滚动判定。
- (void)kbdWillShow:(id)n {
    if (!_activeIp) { PwB("KBD-NO-IP"); return; }
    @try {
        UICollectionView *cv = (UICollectionView *)_cv;
        if (_activeCell) {
            // id -> UIView 显式 cast 调 frame(编译期方法解析), 避免 id 隐式调用 warning
            CGRect fr = [(UIView *)_activeCell frame];
            UIEdgeInsets ei = [cv contentInset];
            // 存根 CGRect 字段是 ox/oy/w/h (无 origin), 类型 double (无 CGFloat)
            double offY = fr.oy - ei.top;
            if (offY < 0) offY = 0;
            CGPoint pt = [cv contentOffset];
            pt.y = offY;
            [cv setContentOffset:pt animated:YES];
            char kb[96]; snprintf(kb, sizeof(kb), "KBD-OFFSET-y%.0f", fr.oy);
            PwB(kb);
        } else {
            PwB("KBD-NO-CELL");
        }
        PwB("KBD-SCROLL-OK");
    } @catch (id e) { PwB("KBD-SCROLL-EXC"); }
}
// 1.9.205: 键盘完全弹出后再滚一次 (WillShow 时键盘尚未弹起, 单次滚动可能不到位), 同样顶对齐
- (void)kbdDidShow:(id)n {
    if (!_activeIp) return;
    @try {
        UICollectionView *cv = (UICollectionView *)_cv;
        if (_activeCell) {
            CGRect fr = [(UIView *)_activeCell frame];
            UIEdgeInsets ei = [cv contentInset];
            double offY = fr.oy - ei.top;
            if (offY < 0) offY = 0;
            CGPoint pt = [cv contentOffset];
            pt.y = offY;
            [cv setContentOffset:pt animated:YES];
        } else {
            PwB("KBD-NO-CELL");
        }
        PwB("KBD-DIDSHOW-OK");
    } @catch (id e) { PwB("KBD-DIDSHOW-EXC"); }
}
- (BOOL)textFieldShouldReturn:(UITextField *)tf {
    [tf resignFirstResponder];
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)tf {
    if (tf != _activeField) return;
    NSString *old = _activeName;
    NSString *nn = [tf text];
    [tf removeFromSuperview];
    _activeField = nil;
    _activeName = nil;
    _activeCell = nil;
    _activeIp = nil;
    if (_activeLabel) { [_activeLabel setHidden:NO]; _activeLabel = nil; }
    if (old && nn && [nn length] > 0) [self doRename:old to:nn];
}
- (void)doRename:(NSString *)old to:(NSString *)newName {
    if (!newName || [newName length] == 0) return;
    NSString *src = [@"/var/mobile/lddgifbg" stringByAppendingPathComponent:old];
    NSString *dst = [@"/var/mobile/lddgifbg" stringByAppendingPathComponent:newName];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:dst]) { [self showTip:@"已存在同名素材"]; return; }
    if ([fm moveItemAtPath:src toPath:dst error:0]) {
        _folders = LDDListMaterialFolders();
        [_thumbs removeObjectForKey:old];
        [_anims removeObjectForKey:old];
        [(UICollectionView *)_cv reloadData];
        if (_editMode) [self startJiggling]; // 改名后保持编辑态抖动
        [self setTitle:[NSString stringWithFormat:@"素材库 (%lu)", (unsigned long)[_folders count]]];
        if (_sel && [_sel isEqualToString:old]) {
            _sel = newName;
            NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
            [ud setObject:newName forKey:@"SelectedMaterialFolder"];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LDDMatChanged" object:0];
    } else {
        [self showTip:@"改名失败"];
    }
}
- (void)confirmDelete:(NSString *)name {
    UIAlertController *al = [UIAlertController alertControllerWithTitle:@"删除素材" message:[NSString stringWithFormat:@"确定删除「%@」? 不可恢复", name] preferredStyle:1];
    UIAlertAction *yes = [UIAlertAction actionWithTitle:@"删除" style:2 handler:^(UIAlertAction *a){
        NSString *p = [@"/var/mobile/lddgifbg" stringByAppendingPathComponent:name];
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([fm removeItemAtPath:p error:0]) {
            _folders = LDDListMaterialFolders();
            [_thumbs removeObjectForKey:name];
            [_anims removeObjectForKey:name];
            [(UICollectionView *)_cv reloadData];
            if (_editMode) [self startJiggling]; // 删除后保持编辑态抖动
            [self setTitle:[NSString stringWithFormat:@"素材库 (%lu)", (unsigned long)[_folders count]]];
            if (_sel && [_sel isEqualToString:name]) {
                _sel = nil;
                NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
                [ud removeObjectForKey:@"SelectedMaterialFolder"];
            }
        } else {
            [self showTip:@"删除失败"];
        }
    }];
    UIAlertAction *cc = [UIAlertAction actionWithTitle:@"取消" style:1 handler:0];
    [al addAction:yes];
    [al addAction:cc];
    [self presentViewController:al animated:YES completion:0];
}
- (void)showTip:(NSString *)msg {
    UIAlertController *al = [UIAlertController alertControllerWithTitle:@"提示" message:msg preferredStyle:1];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"好" style:0 handler:0];
    [al addAction:ok];
    [self presentViewController:al animated:YES completion:0];
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
- (id)collectionView:(id)cv cellForItemAtIndexPath:(id)ip {
    NSInteger row = [ip row];
    UICollectionViewCell *cell = [(UICollectionView *)cv dequeueReusableCellWithReuseIdentifier:@"m" forIndexPath:ip];
    for (UIView *v in [[cell contentView] subviews]) { if (v) [v removeFromSuperview]; }
    if (!_folders || row >= (NSInteger)[_folders count]) return cell;
    NSString *name = [_folders objectAtIndex:(NSUInteger)row];
    // 1.9.195: item 宽 = 行宽/3, 卡片在 cell 内左右各缩 6pt (视觉 12pt 列距), 图片仍为方形
    double w = ([[UIScreen mainScreen] bounds].w - 32.0) / 3.0;
    double cardW = w - 12.0;
    double imgH = cardW;
    {
        char bl[160];
        snprintf(bl, sizeof(bl), "MAT-CELL row=%ld w=%.2f cardW=%.2f", (long)row, w, cardW);
        PwB(bl);
    }
    // 白色圆角卡片 + 图 (卡片不裁切, 让删除钮可盖住并伸出右上角; 图片圆角由 iv 自己裁切)
    UIView *card = [[UIView alloc] initWithFrame:MakeRect(6, 0, cardW, imgH)];
    [card setBackgroundColor:[UIColor whiteColor]];
    [card setTag:911];
    [[card layer] setCornerRadius:14.0];
    UIImage *thumb = [_thumbs objectForKeyedSubscript:name];
    NSString *typeTag = @"图片";
    BOOL hasVideo = NO;
    {
        NSString *full = [@"/var/mobile/lddgifbg" stringByAppendingPathComponent:name];
        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:full error:nil];
        for (NSString *f in files) {
            NSString *ext = [[f pathExtension] lowercaseString];
            if ([ext isEqualToString:@"gif"]) { typeTag = @"GIF"; if (!thumb) thumb = ThumbForPath([full stringByAppendingPathComponent:f]); break; }
            if ([ext isEqualToString:@"mp4"] || [ext isEqualToString:@"mov"]) { typeTag = @"视频"; hasVideo = YES; if (!thumb) thumb = ThumbForPath([full stringByAppendingPathComponent:f]); }
            if ([ext isEqualToString:@"png"] || [ext isEqualToString:@"jpg"] || [ext isEqualToString:@"jpeg"]) { typeTag = @"图片"; if (!thumb) thumb = ThumbForPath([full stringByAppendingPathComponent:f]); }
        }
        if (thumb) [_thumbs setObject:thumb forKeyedSubscript:name];
    }
    UIImageView *iv = [[UIImageView alloc] initWithFrame:MakeRect(0, 0, cardW, imgH)];
    [iv setImage:thumb];
    [iv setContentMode:2];
    [[iv layer] setCornerRadius:14.0];
    [[iv layer] setMasksToBounds:YES];
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
    // 1.9.191: 视频素材左下角播放标志(区分视频/图片)
    if (hasVideo) {
        UIView *vb = [[UIView alloc] initWithFrame:MakeRect(6, imgH - 30, 24, 24)];
        [vb setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.45]];
        [[vb layer] setCornerRadius:12.0];
        [[vb layer] setMasksToBounds:YES];
        UILabel *pl = [[UILabel alloc] initWithFrame:MakeRect(0, -1, 24, 24)];
        [pl setText:@"▶"];
        [pl setFont:[UIFont systemFontOfSize:11.0]];
        [pl setTextAlignment:1];
        [pl setTextColor:[UIColor whiteColor]];
        [vb addSubview:pl];
        [card addSubview:vb];
    }
    // 1.9.191: 编辑态删除钮(红底白"-", 圆心卡缩略图右上角: 一半盖图角一半伸出, 随卡片一起抖动)
    if (_editMode) {
        UIView *delv = [[UIView alloc] initWithFrame:MakeRect(cardW - 10, -9, 20, 20)];
        [delv setBackgroundColor:[UIColor redColor]];
        [[delv layer] setCornerRadius:10.0];
        [[delv layer] setMasksToBounds:YES];
        UILabel *mn = [[UILabel alloc] initWithFrame:MakeRect(0, 0, 20, 20)];
        [mn setText:@"-"];
        [mn setFont:[UIFont systemFontOfSize:17.0]];
        [mn setTextAlignment:1];
        [mn setTextColor:[UIColor whiteColor]];
        [delv addSubview:mn];
        [card addSubview:delv];
        UITapGestureRecognizer *dg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(delBtnTapped:)];
        [delv addGestureRecognizer:dg];
        objc_setAssociatedObject(dg, &kLDDDelKey, name, 1); // OBJC_ASSOCIATION_RETAIN_NONATOMIC
    }
    [[cell contentView] addSubview:card];
    // 名字胶囊 (点按 -> 行内改名); 1.9.201: x=10 与卡片(x=6,宽cardW)水平居中对齐 —— 用户反馈胶囊偏左
    UIView *pill = [[UIView alloc] initWithFrame:MakeRect(10, imgH + 7, cardW - 8, 22)];
    [pill setBackgroundColor:[UIColor colorWithWhite:0.62 alpha:0.85]];
    [[pill layer] setCornerRadius:11.0];
    [[pill layer] setMasksToBounds:YES];
    UILabel *plb = [[UILabel alloc] initWithFrame:MakeRect(0, 0, cardW - 8, 22)];
    [plb setText:name];
    [plb setFont:[UIFont systemFontOfSize:11.0]];
    [plb setTextAlignment:1];
    [plb setTextColor:[UIColor whiteColor]];
    [plb setTag:922];
    [pill addSubview:plb];
    [[cell contentView] addSubview:pill];
    UITapGestureRecognizer *ng = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nameTapped:)];
    [pill addGestureRecognizer:ng];
    objc_setAssociatedObject(ng, &kLDDNameKey, name, 1);
    // 选中圆点 (编辑态隐藏)
    if (!_editMode) {
        BOOL on = _sel && [_sel isEqualToString:name];
        UIView *dot = [[UIView alloc] initWithFrame:MakeRect(6 + cardW / 2 - 9, imgH + 33, 18, 18)];
        [[dot layer] setCornerRadius:9.0];
        [[dot layer] setMasksToBounds:YES];
        [dot setBackgroundColor:(on ? [UIColor systemBlueColor] : [UIColor colorWithWhite:0.80 alpha:1.0])];
        [[cell contentView] addSubview:dot];
    }
    // 1.9.192: 编辑态直接给卡片加抖动(创建即抖, 不依赖 reloadData 后 visibleCells 时机)
    if (_editMode) [self jiggleCard:card];
    return cell;
}
- (void)collectionView:(id)cv didSelectItemAtIndexPath:(id)ip {
    if (_editMode) return; // 编辑态点选不生效(删除走删除钮, 退出走"完成")
    NSInteger row = [ip row];
    if (!_folders || row >= (NSInteger)[_folders count]) return;
    NSString *name = [_folders objectAtIndex:(NSUInteger)row];
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
- (void)footerCopyTapped:(UITapGestureRecognizer *)g;
- (void)footerCopyRestore:(NSTimer *)t;
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
    [self setTitle:@"灵动岛背景美化"];   // 1.17: 更名
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
// 1.9.184: 行数 10 (版本/作者 移除, 改底部居中版权 footer)
- (NSInteger)tableView:(id)tv numberOfRowsInSection:(NSInteger)s { return 10; }
// 1.9.156: 输入框预填值去小数 (偏移=整数, 速度=去尾零保留1位)
static NSString *LDDInputNum(double v, BOOL isSpeed) {
    if (!isSpeed) return [NSString stringWithFormat:@"%.0f", v];
    if (v == (double)(long long)v) return [NSString stringWithFormat:@"%.0f", v];
    return [NSString stringWithFormat:@"%.1f", v];
}
// 1.9.146: 预览尺寸 (真实岛比例 + 面板宽缩放), heightForRow/cellForRow 共用
static void LDDPreviewSize(double bw, double *piw, double *pih) {
    // 1.9.163: 宽度一律撑满面板, 高度按岛真实比例等比 —— 小尺寸广播不再导致预览缩成小药丸
    double iw = bw, ih = 100;
    NSString *isz = [NSString stringWithContentsOfFile:@"/var/mobile/lddgifbg/__island_size__" encoding:4 error:0];
    if (isz) {
        NSArray *parts = [isz componentsSeparatedByString:@" "];
        if ([parts count] >= 2) {
            double w2 = [[parts objectAtIndex:0] doubleValue], h2 = [[parts objectAtIndex:1] doubleValue];
            if (w2 >= 200 && h2 >= 40 && w2 > 0) { ih = h2 * (bw / w2); } // 撑满宽, 等比高
        }
    }
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
- (double)tableView:(id)tv heightForFooterInSection:(NSInteger)s { return 96.0; }
// 1.1: 阻断 PSListController 私有 titleAlignmentForFooterInSection (内部 objectAtIndex 越界 → NSRangeException → 设置闪退)
- (NSInteger)tableView:(id)tv titleAlignmentForFooterInSection:(NSInteger)s { return 0; }
- (id)tableView:(id)tv viewForHeaderInSection:(NSInteger)s { return nil; }
// 1.9.185: 底部三行版权 footer (作者/版本号/越狱源), 越狱源点击复制
- (id)tableView:(id)tv viewForFooterInSection:(NSInteger)s {
    // 1.4: 全宽 label + textAlignment 居中 (与容器宽度无关, 不会偏), 字号改小
    CGRect tb = ((CGRect(*)(id, SEL))objc_msgSend)(tv, sel_registerName("bounds"));
    double sw = tb.w;
    if (sw < 100) { CGRect sbb = [[UIScreen mainScreen] bounds]; sw = sbb.w; }
    UIView *fv = [[UIView alloc] initWithFrame:MakeRect(0, 0, sw, 96)];
    UILabel *l1 = [[UILabel alloc] initWithFrame:MakeRect(0, 10, sw, 20)];
    [l1 setText:@"作者：TL"];
    [l1 setFont:[UIFont systemFontOfSize:13.0]];
    [l1 setTextColor:[UIColor colorWithWhite:0.35 alpha:1.0]];
    [l1 setTextAlignment:1];
    [l1 setAutoresizingMask:98];
    [fv addSubview:l1];
    UILabel *l2 = [[UILabel alloc] initWithFrame:MakeRect(0, 36, sw, 18)];
    NSString *ver = [[NSBundle bundleForClass:(Class)objc_msgSend((id)self, sel_registerName("class"))] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    if (!ver || [ver length] == 0) ver = @"1.0";
    [l2 setText:[NSString stringWithFormat:@"版本号：%@", ver]];
    [l2 setFont:[UIFont systemFontOfSize:11.0]];
    [l2 setTextColor:[UIColor colorWithWhite:0.5 alpha:1.0]];
    [l2 setTextAlignment:1];
    [l2 setAutoresizingMask:98];
    [fv addSubview:l2];
    UILabel *l3 = [[UILabel alloc] initWithFrame:MakeRect(0, 60, sw, 18)];
    [l3 setText:@"越狱源：https://tlzypjy.github.io/jb-repo/"];
    [l3 setFont:[UIFont systemFontOfSize:10.0]];
    [l3 setTextColor:[UIColor colorWithRed:0.0 green:0.45 blue:1.0 alpha:1.0]];
    [l3 setUserInteractionEnabled:YES];
    [l3 setTextAlignment:1];
    [l3 setAutoresizingMask:98];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(footerCopyTapped:)];
    [l3 addGestureRecognizer:tap];
    [fv addSubview:l3];
    return fv;
}
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
    // 1.9.184: 行号与 UI 同步 (0/1开关 2预览 3水平偏移 4垂直偏移 5速度 6选素材 7跳转 8预览通知 9注销)
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
// 1.9.185: 点击越狱源 -> 复制链接到剪贴板, 文字短暂反馈"已复制"
- (void)footerCopyTapped:(UITapGestureRecognizer *)g {
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setString:@"https://tlzypjy.github.io/jb-repo/"];
    UILabel *l3 = (UILabel *)[g view];
    if (l3) {
        [l3 setText:@"越狱源已复制 ✓"];
        [l3 setTextColor:[UIColor colorWithRed:0.1 green:0.7 blue:0.2 alpha:1.0]];
        [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(footerCopyRestore:) userInfo:l3 repeats:NO];
    }
}
- (void)footerCopyRestore:(NSTimer *)t {
    UILabel *l3 = (UILabel *)[t userInfo];
    if (l3) {
        [l3 setText:@"越狱源：https://tlzypjy.github.io/jb-repo/"];
        [l3 setTextColor:[UIColor colorWithRed:0.0 green:0.45 blue:1.0 alpha:1.0]];
    }
}
@end
