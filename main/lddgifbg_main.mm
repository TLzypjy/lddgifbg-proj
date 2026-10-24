// 灵动岛GIF背景 —— 重制版主插件 (全标准 ObjC 语法, arm64e 安全)
// hook SBSystemApertureContainerViewContentView layoutSubviews
// prefs: suite lddgifbg (NSUserDefaults + plist 文件多路径兜底, 含 @P@ RootHide 路径)
// 素材: /var/mobile/lddgifbg/<文件夹>/, gif > mp4/mov > png/jpg
// 诊断: 无素材=红块, 素材加载失败=蓝块, 正常=素材

#include <stdio.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

typedef struct objc_class *Class;
typedef struct objc_object { Class isa; } *id;
typedef struct objc_selector *SEL;
typedef void *IMP;
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
extern "C" void MSHookMessageEx(Class _class, SEL _sel, IMP _replacement, IMP *_result);
extern "C" int objc_getClassList(void *buffer, int bufferLen);
extern "C" const char *class_getName(void *cls);
extern "C" void *objc_autoreleasePoolPush(void);
extern "C" void objc_autoreleasePoolPop(void *pool);
extern "C" void CFRelease(void *cf);
extern "C" const char *object_getClassName(id obj);
extern "C" id object_getClass(id obj);
extern "C" void dispatch_async(void *queue, void (^block)(void));
extern "C" void dispatch_after(long long when, void *queue, void (^block)(void));
extern "C" int notify_post(const char *name);
extern "C" int notify_register_dispatch(const char *name, int *token, void *queue, void (^block)(int token));
extern "C" long long dispatch_time(long long base, long long delta);
struct dispatch_queue_s;
extern "C" struct dispatch_queue_s _dispatch_main_q;
extern "C" void *class_copyIvarList(Class cls, unsigned int *count);
extern "C" const char *ivar_getName(void *ivar);
extern "C" id object_getIvar(id obj, void *ivar);
extern "C" CGImageRef CGImageSourceCreateImageAtIndex(void *src, NSUInteger idx, void *opts);
extern "C" NSUInteger CGImageSourceGetCount(void *src);
extern "C" void *CGImageSourceCreateWithData(void *data, void *opts);
extern "C" void *CGImageSourceCopyPropertiesAtIndex(void *src, NSUInteger idx, void *opts);
extern "C" { extern void *kCGImagePropertyGIFDictionary; extern void *kCGImagePropertyGIFDelayTime; extern void *kCGImagePropertyGIFUnclampedDelayTime; }

// ---------- ObjC 存根 ----------
@interface NSObject
+ (id)alloc;
- (id)init;
- (void)setValue:(id)v forKey:(id)k;
- (id)valueForKey:(id)k;
@end
@interface NSString : NSObject
- (id)initWithBytes:(const void *)b length:(NSUInteger)l encoding:(NSUInteger)e;
+ (id)stringWithFormat:(NSString *)f, ...;
- (NSString *)stringByAppendingPathComponent:(NSString *)s;
- (NSString *)pathExtension;
- (NSString *)lowercaseString;
- (BOOL)isEqualToString:(NSString *)s;
@end
@interface NSDictionary : NSObject
+ (id)dictionaryWithContentsOfFile:(NSString *)p;
- (id)objectForKeyedSubscript:(id)k;
- (id)objectForKey:(id)k;
- (BOOL)writeToFile:(NSString *)p atomically:(BOOL)a;
@end
@interface NSMutableDictionary : NSDictionary
+ (id)dictionary;
- (void)setObject:(id)obj forKeyedSubscript:(id)k;
- (void)setObject:(id)obj forKey:(id)k;
@end
@interface NSArray : NSObject
+ (id)arrayWithObjects:(id)first, ...;
- (NSUInteger)count;
- (NSUInteger)countByEnumeratingWithState:(void *)state objects:(id *)buf count:(NSUInteger)len;
@end
@interface NSMutableArray : NSArray
+ (id)arrayWithCapacity:(NSUInteger)n;
- (void)addObject:(id)obj;
@end
@interface NSData : NSObject
+ (id)dataWithContentsOfFile:(NSString *)p;
@end
@interface NSNumber : NSObject
+ (id)numberWithDouble:(double)d;
+ (id)numberWithInt:(int)i;
+ (id)numberWithBool:(BOOL)b;
- (double)doubleValue;
- (BOOL)boolValue;
@end
@interface NSFileManager : NSObject
+ (id)defaultManager;
- (BOOL)fileExistsAtPath:(NSString *)p;
- (BOOL)fileExistsAtPath:(NSString *)p isDirectory:(BOOL *)d;
- (id)contentsOfDirectoryAtPath:(NSString *)p error:(id *)e;
@end
@interface NSUserDefaults : NSObject
- (id)initWithSuiteName:(NSString *)n;
- (id)objectForKey:(id)k;
@end
@interface NSNotificationCenter : NSObject
+ (id)defaultCenter;
- (void)addObserver:(id)o selector:(SEL)s name:(NSString *)n object:(id)obj;
@end
@interface NSDate : NSObject
+ (id)date;
@end
@interface NSURL : NSObject
+ (id)fileURLWithPath:(NSString *)p;
@end

typedef struct CGRect { double ox, oy, w, h; } CGRect;
static void LogReason(const char *tag, id e);
static void CheckForcePreviewTick(void);
static CGRect MakeRect(double x, double y, double w, double h) { CGRect r = {x, y, w, h}; return r; }
typedef struct UIEdgeInsets { double top, left, bottom, right; } UIEdgeInsets;
typedef struct CGAffineTransform { double a, b, c, d, tx, ty; } CGAffineTransform;
static CGAffineTransform CGMakeScale(double s) { CGAffineTransform t = {s, 0, 0, s, 0, 0}; return t; }
static void ShowPreviewWindow(void);
@interface UIApplication : NSObject
+ (id)sharedApplication;
- (id)keyWindow;
- (id)windows;
- (id)connectedScenes;
@end
@interface UIScreen : NSObject
+ (id)mainScreen;
- (CGRect)bounds;
@end


@interface UIColor : NSObject
+ (id)redColor;
+ (id)blueColor;
+ (id)clearColor;
+ (id)whiteColor;
+ (id)colorWithWhite:(double)w alpha:(double)a;
@end
@interface UIFont : NSObject
+ (id)systemFontOfSize:(double)s;
+ (id)boldSystemFontOfSize:(double)s;
@end
@interface UIView : NSObject
- (id)initWithFrame:(CGRect)r;
- (CGRect)bounds;
- (void)setFrame:(CGRect)r;
- (void)insertSubview:(id)v atIndex:(NSInteger)i;
- (void)addSubview:(id)v;
- (void)bringSubviewToFront:(id)v;
- (void)removeFromSuperview;
- (void)removeFromSuperview;
- (id)viewWithTag:(NSInteger)t;
- (id)layer;
- (id)window;
- (void)setBackgroundColor:(id)c;
- (void)setTag:(NSInteger)t;
- (void)setAlpha:(double)a;
- (void)setTransform:(CGAffineTransform)t;
+ (void)animateWithDuration:(double)d delay:(double)dl usingSpringWithDamping:(double)damp initialSpringVelocity:(double)vel options:(NSUInteger)opt animations:(void(^)(void))anim completion:(void(^)(BOOL))comp;
@end

@interface UILabel : UIView
- (id)initWithFrame:(CGRect)r;
- (void)setText:(NSString *)t;
- (void)setFont:(id)f;
- (void)setTextColor:(id)c;
- (void)setTextAlignment:(NSInteger)a;
- (void)setNumberOfLines:(NSInteger)n;
@end

@interface UIControl : UIView
- (void)addTarget:(id)t action:(SEL)a forControlEvents:(NSUInteger)e;
@end
@interface UIWindow : UIView
- (id)initWithFrame:(CGRect)r;
- (void)setWindowLevel:(long)l;
- (void)setHidden:(BOOL)h;
- (void)makeKeyAndVisible;
- (id)scene;
- (void)setWindowScene:(id)s;
- (BOOL)isHidden;
- (UIEdgeInsets)safeAreaInsets;
@end
@interface UIImage : NSObject
+ (id)imageWithContentsOfFile:(NSString *)p;
+ (id)imageWithCGImage:(CGImageRef)cg scale:(double)s orientation:(NSInteger)o;
@end
@interface UIImageView : UIView
- (id)initWithFrame:(CGRect)r;
- (void)setImage:(id)img;
- (void)setAnimationImages:(id)images;
- (void)setAnimationDuration:(double)d;
- (void)setAnimationRepeatCount:(NSInteger)n;
- (BOOL)isAnimating;
- (void)startAnimating;
- (void)stopAnimating;
- (void)setContentMode:(NSInteger)m;
- (void)setAutoresizingMask:(NSUInteger)m;
@end
@interface AVPlayer : NSObject
- (void)setMuted:(BOOL)m;
- (void)play;
- (void)pause;
- (void)replaceCurrentItemWithPlayerItem:(id)item;
- (void)seekToTime:(id)cmtime_wrap;
@end
@interface CALayer : NSObject
- (void)addSublayer:(id)l;
- (void)removeFromSuperlayer;
- (void)setFrame:(CGRect)r;
- (void)setCornerRadius:(double)r;
- (id)superlayer;
- (void)setMasksToBounds:(BOOL)b;
@end

// ---------- 全局 ----------
static NSString *gPrefsKeyEnable, *gPrefsKeyZxh, *gPrefsKeyScale, *gPrefsKeyFolder;
static NSString *gRootDir, *gGifExt, *gVideoExtMp4, *gVideoExtMov;
static NSString *gLoadedPath;
static AVPlayer *gPlayer;
static id gPlayerItem;
static CALayer *gPlayerLayer;
static id gObserver;
static id gFramesCache, gDurationCache;

struct CMTimeRaw { long long value; int timescale; unsigned flags; long long epoch; };

// ---------- 视频循环观察者 ----------
@interface LDDVideoLoopObserver : NSObject
- (void)videoDidEnd:(id)n;
@end
@implementation LDDVideoLoopObserver
- (void)videoDidEnd:(id)n {
    if (gPlayer) {
        typedef id (*Fn)(id, SEL, struct CMTimeRaw);
        Fn fn = (Fn)objc_msgSend;
        struct CMTimeRaw zero = {0, 0, 0, 0};
        fn(gPlayer, sel_registerName("seekToTime:"), zero);
        [gPlayer play];
    }
}
@end

// ---------- prefs (NSUserDefaults + plist 多路径兜底) ----------
static id LoadPrefsValue(NSString *key) {
    // 文件优先: 与原版一致, 跨进程永远新鲜
    const char *paths[] = {
        "/var/jb/User/Library/Preferences/lddgifbg.plist",
        "/var/mobile/Library/Preferences/lddgifbg.plist",
        "@P@/var/jb/User/Library/Preferences/lddgifbg.plist",
        "@P@/var/mobile/Library/Preferences/lddgifbg.plist",
        0
    };
    for (int i = 0; paths[i]; i++) {
        NSString *p = [[NSString alloc] initWithBytes:paths[i] length:strlen(paths[i]) encoding:4];
        NSDictionary *d = [NSDictionary dictionaryWithContentsOfFile:p];
        if (d) {
            id x = [d objectForKeyedSubscript:key];
            if (x) return x;
        }
    }
    NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
    return [ud objectForKey:key];
}
static BOOL IsLddGifBgEnabled(void) {
    id v = LoadPrefsValue(gPrefsKeyEnable);
    return v ? [v boolValue] : YES;
}
static BOOL IsZxhLddGifBgEnabled(void) {
    id v = LoadPrefsValue(gPrefsKeyZxh);
    return v ? [v boolValue] : YES;
}
static double GetLddGifBgScale(void) {
    id v = LoadPrefsValue(gPrefsKeyScale);
    if (!v) return 1.0;
    double d = [v doubleValue];
    return d > 0 ? d : 1.0;
}


// ---------- 注入自检探针: 证明 dylib 已加载 / hook 已触发 ----------
static void ProbeWrite(const char *line) {
    FILE *f = fopen("/var/mobile/lddgifbg/__plugin_probe__.txt", "a");
    if (f) { fprintf(f, "%s\n", line); fclose(f); }
}

// ---------- 素材选择: gif > 视频 > 静态图 ----------
static NSString *GetSelectedImagePath(void) {
    id name = LoadPrefsValue(gPrefsKeyFolder);
    if (!name) return nil;
    NSString *folder = [gRootDir stringByAppendingPathComponent:name];
    BOOL isDir = NO;
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:folder isDirectory:&isDir] || !isDir) return nil;
    NSArray *files = [fm contentsOfDirectoryAtPath:folder error:nil];
    if (!files) return nil;
    NSString *videoPick = nil, *imgPick = nil;
    for (NSString *f in files) {
        NSString *ext = [[f pathExtension] lowercaseString];
        if ([ext isEqualToString:gGifExt]) return [folder stringByAppendingPathComponent:f];
        if ([ext isEqualToString:gVideoExtMp4] || [ext isEqualToString:gVideoExtMov]) {
            if (!videoPick) videoPick = [folder stringByAppendingPathComponent:f];
        }
        if ([ext isEqualToString:@"png"] || [ext isEqualToString:@"jpg"] || [ext isEqualToString:@"jpeg"]) {
            if (!imgPick) imgPick = [folder stringByAppendingPathComponent:f];
        }
    }
    return videoPick ? videoPick : imgPick;
}

// ---------- GIF 载入 ----------
static void LoadGIFWithPathIntoImageView(NSString *path, UIImageView *iv) {
    if (!path || !iv) return;
    id frames = [gFramesCache objectForKeyedSubscript:path];
    id durObj = [gDurationCache objectForKeyedSubscript:path];
    if (frames && durObj) {
        [iv setAnimationImages:frames];
        [iv setAnimationDuration:[durObj doubleValue]];
        [iv setAnimationRepeatCount:0];
        [iv startAnimating];
        return;
    }
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (!data) return;
    void *src = CGImageSourceCreateWithData((__bridge void *)data, 0);
    if (!src) return;
    NSUInteger count = CGImageSourceGetCount(src);
    if (count == 0) { CFRelease(src); return; }
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:count];
    double total = 0.0;
    for (NSUInteger i = 0; i < count; i++) {
        CGImageRef cg = CGImageSourceCreateImageAtIndex(src, i, 0);
        if (!cg) continue;
        void *props = CGImageSourceCopyPropertiesAtIndex(src, i, 0);
        UIImage *img = [UIImage imageWithCGImage:cg scale:1.0 orientation:0];
        [arr addObject:img];
        double delay = 0.1;
        if (props) {
            NSDictionary *gd = [(__bridge NSDictionary *)props objectForKeyedSubscript:(__bridge id)kCGImagePropertyGIFDictionary];
            if (gd) {
                id d1 = [gd objectForKeyedSubscript:(__bridge id)kCGImagePropertyGIFUnclampedDelayTime];
                id d2 = [gd objectForKeyedSubscript:(__bridge id)kCGImagePropertyGIFDelayTime];
                double dd = 0.0;
                if (d1) dd = [d1 doubleValue];
                if (dd <= 0 && d2) dd = [d2 doubleValue];
                if (dd > 0) delay = dd;
            }
            CFRelease(props);
        }
        total += delay;
        CFRelease((void *)cg);
    }
    CFRelease(src);
    [gFramesCache setObject:arr forKeyedSubscript:path];
    NSNumber *dur = [NSNumber numberWithDouble:total];
    [gDurationCache setObject:dur forKeyedSubscript:path];
    [iv setAnimationImages:arr];
    [iv setAnimationDuration:total];
    [iv setAnimationRepeatCount:0];
    [iv startAnimating];
}

// ---------- 视频载入 ----------
static void EnsureAVFoundation(void) {
    static int done = 0;
    if (!done) { dlopen("/System/Library/Frameworks/AVFoundation.framework/AVFoundation", 2); done = 1; }
}
static void LoadVideoWithPathIntoView(NSString *path, UIView *view) {
    EnsureAVFoundation();
    NSURL *url = [NSURL fileURLWithPath:path];
    typedef id (*FnA)(id, SEL, NSURL *);
    FnA fna = (FnA)objc_msgSend;
    if (gPlayer && gPlayerItem) {
        id item = fna((id)objc_getClass("AVPlayerItem"), sel_registerName("playerItemWithURL:"), url);
        [gPlayer replaceCurrentItemWithPlayerItem:item];
    } else {
        gPlayerItem = fna((id)objc_getClass("AVPlayerItem"), sel_registerName("playerItemWithURL:"), url);
        typedef id (*FnB)(id, SEL, id);
        FnB fnb = (FnB)objc_msgSend;
        gPlayer = fnb((id)objc_getClass("AVPlayer"), sel_registerName("playerWithPlayerItem:"), gPlayerItem);
        [gPlayer setMuted:YES];
        gPlayerLayer = fnb((id)objc_getClass("AVPlayerLayer"), sel_registerName("playerLayerWithPlayer:"), gPlayer);
        [gPlayerLayer setValue:@"AVLayerVideoGravityResizeAspectFill" forKey:@"videoGravity"];
        gObserver = [[LDDVideoLoopObserver alloc] init];
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:gObserver selector:@selector(videoDidEnd:) name:@"AVPlayerItemDidPlayToEndTimeNotification" object:gPlayerItem];
    }
    CGRect b = [view bounds];
    [gPlayerLayer setFrame:b];
    if ([gPlayerLayer superlayer] != [view layer]) [[view layer] addSublayer:gPlayerLayer];
    [gPlayer play];
}
static void StopVideo(void) {
    if (gPlayer) [gPlayer pause];
    if (gPlayerLayer) [gPlayerLayer removeFromSuperlayer];
}

// ---------- 素材分发 ----------
static void LoadMediaWithPathIntoImageView(NSString *path, UIImageView *iv) {
    NSString *ext = [[path pathExtension] lowercaseString];
    if ([ext isEqualToString:gGifExt]) {
        StopVideo();
        [iv setImage:nil];
        [iv setAnimationImages:nil];
        LoadGIFWithPathIntoImageView(path, iv);
    } else if ([ext isEqualToString:gVideoExtMp4] || [ext isEqualToString:gVideoExtMov]) {
        [iv stopAnimating];
        [iv setImage:nil];
        [iv setAnimationImages:nil];
        LoadVideoWithPathIntoView(path, iv);
    } else {
        StopVideo();
        [iv stopAnimating];
        [iv setAnimationImages:nil];
        [iv setImage:[UIImage imageWithContentsOfFile:path]];
    }
}



// ---------- 强制上岛预览 (8秒, 不依赖通知系统) ----------
static long gForceUntil = 0;
static void PreviewOverlayDismiss(void);
@interface LDDPreviewDismiss : NSObject
- (void)dismissPreview;
@end
@implementation LDDPreviewDismiss
- (void)dismissPreview;
{
    PreviewOverlayDismiss();
}
@end
static id gPreviewDismissTarget = nil;

static double gForceLast = 0;
static void CheckForcePreviewTick(void) {
    double t = ((double(*)(id, SEL))objc_msgSend)((id)[(id)objc_getClass("NSDate") date], sel_registerName("timeIntervalSince1970"));
    if (t - gForceLast < 0.25) return;
    gForceLast = t;
    if (access("/var/mobile/lddgifbg/__force_preview__", 0) == 0) {
        remove("/var/mobile/lddgifbg/__force_preview__");
        ShowPreviewWindow();
    }
}

static void CheckForcePreview(void) {
    if (access("/var/mobile/lddgifbg/__force_preview__", 0) == 0) {
        remove("/var/mobile/lddgifbg/__force_preview__");
        ShowPreviewWindow();
    }
}
static BOOL ForcePreviewActive(void) { return time(0) < gForceUntil; }

// ---------- prefs 缓存 (1秒节流, 避免每帧读文件/扫目录) ----------
static long gCacheSec = 0;
static BOOL cEnabled, cZxh;
static double cScale;
static NSString *cPath;
static void RefreshPrefsCache(void) {
    long t = time(0);
    if (t == gCacheSec) return;
    gCacheSec = t;
    cEnabled = IsLddGifBgEnabled();
    cZxh = IsZxhLddGifBgEnabled();
    cScale = GetLddGifBgScale();
    cPath = GetSelectedImagePath();
}



static void LogReason(const char *tag, id e) {
    @try {
        id r = ((id(*)(id, SEL))objc_msgSend)(e, sel_registerName("reason"));
        const char *c = r ? ((const char *(*)(id, SEL))objc_msgSend)(r, sel_registerName("UTF8String")) : 0;
        char buf[300]; snprintf(buf, sizeof(buf), "%s: %.220s", tag, c ? c : "?"); ProbeWrite(buf);
    } @catch (id e2) { ProbeWrite(tag); }
}

// ---------- 捕获 BBServer 实例 (hook 其 init) ----------
static id gCapturedServer = nil;
static id (*origBBInit)(id, SEL);
static id HookBBInit(id self, SEL _c) {
    id r = origBBInit(self, _c);
    if (!gCapturedServer) { gCapturedServer = r; ProbeWrite("SBB-CAPTURED-INIT"); }
    return r;
}
static id (*origBBAlloc)(Class, SEL);
static id HookBBAlloc(Class cls, SEL _c) {
    id r = origBBAlloc(cls, _c);
    if (!gCapturedServer) { gCapturedServer = r; ProbeWrite("SBB-CAPTURED-ALLOC"); }
    return r;
}

// ---------- SpringBoard 代发测试通知 (设置端写触发文件) ----------
static long gNotifSec = 0;
static void SBPostTestNotification(void) {
    ProbeWrite("SBB-START");
    @try {
        dlopen("/System/Library/PrivateFrameworks/BulletinBoard.framework/BulletinBoard", 2);
        id clsB = (id)objc_getClass("BBBulletin");
        id clsS = (id)objc_getClass("BBServer");
        if (!clsB || !clsS) { ProbeWrite("SBB-NO-CLASS"); return; }
        // 创建 bulletin: +bulletin 不存在则 alloc/init
        id bulletin = nil;
        if (((BOOL(*)(id, SEL, SEL))objc_msgSend)(clsB, sel_registerName("respondsToSelector:"), sel_registerName("bulletin"))) {
            bulletin = ((id(*)(id, SEL))objc_msgSend)(clsB, sel_registerName("bulletin"));
        }
        if (!bulletin) bulletin = [[clsB alloc] init];
        if (!bulletin) { ProbeWrite("SBB-NO-BULLETIN"); return; }
        ProbeWrite("SBB-B1");
        ((void(*)(id, SEL, NSString *))objc_msgSend)(bulletin, sel_registerName("setTitle:"), @"灵动岛测试");
        ((void(*)(id, SEL, NSString *))objc_msgSend)(bulletin, sel_registerName("setMessage:"), @"查看素材显示效果");
        ((void(*)(id, SEL, NSString *))objc_msgSend)(bulletin, sel_registerName("setSectionID:"), @"com.apple.MobileSMS");
        NSString *uid = [NSString stringWithFormat:@"ldd-%ld", (long)time(0)];
        ((void(*)(id, SEL, NSString *))objc_msgSend)(bulletin, sel_registerName("setPublisherBulletinID:"), uid);
        ((void(*)(id, SEL, NSString *))objc_msgSend)(bulletin, sel_registerName("setRecordID:"), uid);
        id now = [(id)objc_getClass("NSDate") date];
        if (((BOOL(*)(id, SEL, SEL))objc_msgSend)(bulletin, sel_registerName("respondsToSelector:"), sel_registerName("setBulletinID:")))
            ((void(*)(id, SEL, NSString *))objc_msgSend)(bulletin, sel_registerName("setBulletinID:"), uid);
        if (((BOOL(*)(id, SEL, SEL))objc_msgSend)(bulletin, sel_registerName("respondsToSelector:"), sel_registerName("setPublicationDate:")))
            ((void(*)(id, SEL, id))objc_msgSend)(bulletin, sel_registerName("setPublicationDate:"), now);
        ((void(*)(id, SEL, id))objc_msgSend)(bulletin, sel_registerName("setDate:"), now);
        ((void(*)(id, SEL, BOOL))objc_msgSend)(bulletin, sel_registerName("setShowsMessagePreview:"), YES);
        ProbeWrite("SBB-B2");
        // server: 捕获优先, 候选 selector 兜底
        id server = gCapturedServer;
        if (server) ProbeWrite("SBB-SRV-CAPTURED");
        if (!server) {
            const char *cands[] = {"sharedInstance", "sharedInstanceIfExists", "sharedServer", "defaultServer", "server", 0};
            for (int i = 0; cands[i] && !server; i++) {
                SEL s = sel_registerName(cands[i]);
                if (((BOOL(*)(id, SEL, SEL))objc_msgSend)(clsS, sel_registerName("respondsToSelector:"), s)) {
                    server = ((id(*)(id, SEL))objc_msgSend)(clsS, s);
                    if (server) {
                        char lb[64]; snprintf(lb, sizeof(lb), "SBB-SRV-%s", cands[i]); ProbeWrite(lb);
                    }
                }
            }
        }
        if (!server) {
            // 最后兜底: 自建 BBServerConnection 走客户端发布协议
            id clsConn = (id)objc_getClass("BBServerConnection");
            if (clsConn) {
                id conn = [[clsConn alloc] init];
                SEL sp = sel_registerName("publishBulletin:destinations:alwaysToLockScreen:");
                if (conn && ((BOOL(*)(id, SEL, SEL))objc_msgSend)(conn, sel_registerName("respondsToSelector:"), sp)) {
                    ((void(*)(id, SEL, id, NSUInteger, BOOL))objc_msgSend)(conn, sp, bulletin, (NSUInteger)7, YES);
                    ProbeWrite("SBB-CONN-PUB");
                    return;
                }
                ProbeWrite("SBB-CONN-NOPUB");
            }
            ProbeWrite("SBB-NO-SERVER");
            return;
        }
        ProbeWrite("SBB-B3");
        // 发布: 队列安全路线 (主线程直调 server 会触发 dispatch_assert 崩溃)
        SEL sPub = sel_registerName("publishBulletin:destinations:alwaysToLockScreen:");
        // 路线1: BBServerConnection 客户端通道 (内部转发到正确队列)
        id clsConn = (id)objc_getClass("BBServerConnection");
        if (clsConn) {
            id conn = [[clsConn alloc] init];
            if (conn && ((BOOL(*)(id, SEL, SEL))objc_msgSend)(conn, sel_registerName("respondsToSelector:"), sPub)) {
                ((void(*)(id, SEL, id, NSUInteger, BOOL))objc_msgSend)(conn, sPub, bulletin, (NSUInteger)7, YES);
                ProbeWrite("SBB-PUB-CONN");
                return;
            }
            ProbeWrite("SBB-CONN-NOPUB");
        }
        else { ProbeWrite("SBB-CONN-CLASS-NIL"); }
        // 路线2: 扫描 ivar 找内部队列, 异步到该队列发布
        id q = nil;
        @try {
            unsigned int cnt = 0;
            void **ivars = (void **)class_copyIvarList((Class)clsS, &cnt);
            static int ivlogged = 0;
            for (unsigned int i = 0; i < cnt; i++) {
                const char *nm = ivar_getName(ivars[i]);
                if (!nm) continue;
                if (!ivlogged && i < 40) {
                    char lb[96]; snprintf(lb, sizeof(lb), "SBB-IVAR: %s", nm); ProbeWrite(lb);
                }
                if (strstr(nm, "ueue")) {
                    id v = object_getIvar(server, ivars[i]);
                    if (v) { q = v; char lb[96]; snprintf(lb, sizeof(lb), "SBB-QUEUE-IVAR: %s", nm); ProbeWrite(lb); break; }
                }
            }
            ivlogged = 1;
        } @catch (id e) { ProbeWrite("SBB-IVAR-EXC"); }
        if (q) {
            dispatch_async((__bridge void *)q, ^{
                SEL sPub3 = sel_registerName("publishBulletin:destinations:alwaysToLockScreen:");
                SEL sPub2 = sel_registerName("publishBulletin:destinations:");
                SEL sSend = sel_registerName("_sendAddBulletin:toFeeds:");
                BOOL shown = NO;
                // 1) TrollOpen 同款底层通道: feeds 为 NSArray<NSNumber>
                if (!shown && ((BOOL(*)(id, SEL, SEL))objc_msgSend)(server, sel_registerName("respondsToSelector:"), sSend)) {
                    @try {
                        id feeds = [NSArray arrayWithObjects:[NSNumber numberWithInt:1], [NSNumber numberWithInt:2], [NSNumber numberWithInt:4], nil];
                        ((void(*)(id, SEL, id, id))objc_msgSend)(server, sSend, bulletin, feeds);
                        ProbeWrite("SBB-PUB-QS"); shown = YES;
                    } @catch (id e) { LogReason("QS", e); }
                }
                // 2) 三参 publish
                if (!shown && ((BOOL(*)(id, SEL, SEL))objc_msgSend)(server, sel_registerName("respondsToSelector:"), sPub3)) {
                    @try { ((void(*)(id, SEL, id, NSUInteger, BOOL))objc_msgSend)(server, sPub3, bulletin, (NSUInteger)7, YES); ProbeWrite("SBB-PUB-Q3"); shown = YES; }
                    @catch (id e) { LogReason("Q3", e); }
                }
                // 3) 二参 publish
                if (!shown && ((BOOL(*)(id, SEL, SEL))objc_msgSend)(server, sel_registerName("respondsToSelector:"), sPub2)) {
                    @try { ((void(*)(id, SEL, id, NSUInteger))objc_msgSend)(server, sPub2, bulletin, (NSUInteger)7); ProbeWrite("SBB-PUB-Q2"); shown = YES; }
                    @catch (id e) { LogReason("Q2", e); }
                }
                if (!shown) ProbeWrite("SBB-ALL-FAIL");
            });
            ProbeWrite("SBB-QASYNC");
            return;
        }
        ProbeWrite("SBB-NO-PATH");
    } @catch (id e) {
        @try {
            id r = ((id(*)(id, SEL))objc_msgSend)(e, sel_registerName("reason"));
            const char *c = r ? ((const char *(*)(id, SEL))objc_msgSend)(r, sel_registerName("UTF8String")) : 0;
            char buf[300];
            snprintf(buf, sizeof(buf), "SBB-EXC: %.240s", c ? c : "?");
            ProbeWrite(buf);
        } @catch (id e2) { ProbeWrite("SBB-EXC"); }
    }
}

static void CheckTestNotifFlag(void) {
    long t = time(0);
    if (t == gNotifSec) return;
    gNotifSec = t;
    if (access("/var/mobile/lddgifbg/__test_notif__", 0) == 0) {
        remove("/var/mobile/lddgifbg/__test_notif__");
        SBPostTestNotification();
    }
}

// ---------- 诊断占位 (红=无素材, 蓝=加载失败) ----------
static void RemoveTagged(id self, NSInteger tag) {
    id v = [self viewWithTag:tag];
    if (v) [v removeFromSuperview];
}
static void ShowBlock(id self, int colorIsRed) {
    RemoveTagged(self, 9999);
    RemoveTagged(self, 9998);
    id ph = [self viewWithTag:colorIsRed ? 9997 : 9996];
    if (!ph) {
        CGRect b = [self bounds];
        UIView *v = [[UIView alloc] initWithFrame:MakeRect(b.w/2 - 15, b.h/2 - 20, 30, 40)];
        [v setBackgroundColor:(colorIsRed ? [UIColor redColor] : [UIColor blueColor])];
        [v setTag:(colorIsRed ? 9997 : 9996)];
        [self insertSubview:v atIndex:0];
    }
}

// ---------- layoutSubviews hook ----------
static void LDDIslandLayout(id self) {
    static int first = 0;
    if (!first) { first = 1; ProbeWrite("ISLAND-LAYOUT-ENTERED"); }
    void *pool = objc_autoreleasePoolPush();
    // 过滤: 只处理挂在真实窗口、且尺寸接近灵动岛的视图 (排除整屏容器)
    UIView *selfv = (UIView *)self;
    id win = [selfv window];
    if (!win) { objc_autoreleasePoolPop(pool); return; }
    CGRect bb = [selfv bounds];
    if (bb.w > 460.0 || bb.h > 150.0 || bb.w < 40.0 || bb.h < 10.0) {
        objc_autoreleasePoolPop(pool); return;
    }
    static int aclog = 0;
    if (aclog < 8) {
        aclog++;
        char al[128];
        snprintf(al, sizeof(al), "ACCEPT-VIEW: %s %.0fx%.0f", object_getClassName(self), bb.w, bb.h);
        ProbeWrite(al);
    }

    CheckForcePreview();
    RefreshPrefsCache();
    BOOL mainOn = cEnabled;
    BOOL show = NO;
    if (mainOn) {
        CGRect b0 = [self bounds];
        if (cZxh) show = YES;          // 小岛开: 常显
        else if (b0.h >= 65.0) show = YES;               // 小岛关: 仅展开时
    }
    if (!show) {
        RemoveTagged(self, 9999);
        RemoveTagged(self, 9998);
        objc_autoreleasePoolPop(pool);
        return;
    }

    NSString *path = cPath;
    if (!path) {
        ShowBlock(self, 1);   // 红: 没读到素材(可能是 prefs 问题)
        objc_autoreleasePoolPop(pool);
        return;
    }
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:path]) {
        ShowBlock(self, 1);
        return objc_autoreleasePoolPop(pool), (void)0;
    }
    RemoveTagged(self, 9997);
    RemoveTagged(self, 9996);

    UIImageView *view = (UIImageView *)[self viewWithTag:9999];
    if (!view) {
        CGRect b = [self bounds];
        view = [[UIImageView alloc] initWithFrame:MakeRect(0, 0, b.w, b.h)];
        [view setContentMode:2];
        [view setAutoresizingMask:18];
        [view setTag:9999];
        [self insertSubview:view atIndex:0];
    }

    double scale = cScale;
    CGRect b = [self bounds];
    double w = b.w * scale, h = b.h * scale;
    [view setFrame:MakeRect((b.w - w) / 2.0, (b.h - h) / 2.0, w, h)];
    // 药丸圆角, 贴合灵动岛形状
    id vlay = [view layer];
    [vlay setCornerRadius:h / 2.0];
    [vlay setMasksToBounds:YES];

    BOOL needReload = YES;
    if (gLoadedPath && [gLoadedPath isEqualToString:path]) {
        if ([view isAnimating] || gPlayerLayer) needReload = NO;
    }
    if (needReload) {
        gLoadedPath = path;
        LoadMediaWithPathIntoImageView(path, view);
    }
    [self insertSubview:view atIndex:0];
    objc_autoreleasePoolPop(pool);
}

// ---------- 构造 ----------
// 全局 UIView hook: 在每次布局时识别"灵动岛容器视图"(类名含 Aperture)并接管
static void (*origCtrlLayout)(id, SEL);
static void LDDIslandLayout(id self);
static void CtrlLayoutHook(id self, SEL _cmd) {
    static int once = 0;
    if (!once) { once = 1; ProbeWrite("CTRL-HOOK-FIRED"); }
    CheckForcePreviewTick();
    const char *cn = object_getClassName(self);
    if (cn && (strstr(cn, "Aperture") || strstr(cn, "Island"))) {
        static int logged = 0;
        if (!logged) {
            logged = 1;
            char line[160];
            snprintf(line, sizeof(line), "MATCH-CLASS: %s", cn);
            ProbeWrite(line);
        }
        LDDIslandLayout(self);
    }
    if (origCtrlLayout) origCtrlLayout(self, _cmd);
}

static id gPreviewWinHolder = nil;
static id gPreviewOverlay = nil;
static id gPreviewContent = nil;
static CGRect gPreviewPill;
static long gPreviewGen = 0;
static void CollapsePreview(void);
static void PreviewOverlayDismiss(void) { CollapsePreview(); }

static UIImage *FirstImageForPath(NSString *path) {
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (!data) return nil;
    void *src = CGImageSourceCreateWithData((__bridge void *)data, 0);
    if (!src) return nil;
    CGImageRef cg = CGImageSourceCreateImageAtIndex(src, 0, 0);
    CFRelease(src);
    if (!cg) return nil;
    UIImage *img = [UIImage imageWithCGImage:cg scale:1.0 orientation:0];
    CFRelease((void *)cg);
    return img;
}

static double gLastShow = 0;
static void ShowPreviewWindow(void) {
    @try {
        double nowT = ((double(*)(id, SEL))objc_msgSend)((id)[(id)objc_getClass("NSDate") date], sel_registerName("timeIntervalSince1970"));
        if (nowT - gLastShow < 0.8) { ProbeWrite("PREV-DEDUP"); return; }
        gLastShow = nowT;
        RefreshPrefsCache();
        NSString *path = cPath;
        if (!path) { ProbeWrite("PREV-NOPATH"); return; }
        if (gPreviewOverlay) CollapsePreview();
        id app = ((id(*)(id, SEL))objc_msgSend)((id)objc_getClass("UIApplication"), sel_registerName("sharedApplication"));
        // 取 foreground UIWindowScene (iOS16 必须)
        id scenes = ((id(*)(id, SEL))objc_msgSend)(app, sel_registerName("connectedScenes"));
        id scene = nil;
        id sceneArr = scenes ? ((id(*)(id, SEL))objc_msgSend)(scenes, sel_registerName("allObjects")) : nil;
        NSUInteger scn = sceneArr ? ((NSUInteger(*)(id, SEL))objc_msgSend)(sceneArr, sel_registerName("count")) : 0;
        ProbeWrite("PREV-SCENES");
        for (NSUInteger i = 0; i < scn; i++) {
            id s = ((id(*)(id, SEL, NSUInteger))objc_msgSend)(sceneArr, sel_registerName("objectAtIndex:"), i);
            const char *cn = object_getClassName(s);
            if (cn && strstr(cn, "UIWindowScene")) { scene = s; break; }
        }
        if (!scene && scn > 0) scene = ((id(*)(id, SEL, NSUInteger))objc_msgSend)(sceneArr, sel_registerName("objectAtIndex:"), 0);
        id scr = ((id(*)(id, SEL))objc_msgSend)((id)objc_getClass("UIScreen"), sel_registerName("mainScreen"));
        CGRect sb = ((CGRect(*)(id, SEL))objc_msgSend)(scr, sel_registerName("bounds"));
        UIWindow *win = [[UIWindow alloc] initWithFrame:sb];
        if (scene) [win setWindowScene:scene];
        [win setWindowLevel:2001];
        [win setBackgroundColor:[UIColor clearColor]];
        [win setHidden:NO];
        UIEdgeInsets si = [win safeAreaInsets];
        double top = si.top > 0 ? si.top : 10.0;
        double bw = sb.w - 24.0;
        double bh = 122.0;
        CGRect expanded = MakeRect(12.0, top + 2.0, bw, bh);
        double pillY = (si.top > 50.0) ? (si.top - 48.0) : 11.0;
        CGRect pill = MakeRect((sb.w - 125.0) / 2.0, pillY, 125.0, 37.0);
        gPreviewPill = pill;
        UIControl *banner = [[UIControl alloc] initWithFrame:pill];
        [banner setBackgroundColor:[UIColor colorWithWhite:0.05 alpha:1.0]];
        id bl = [banner layer];
        [bl setCornerRadius:20.0];
        [bl setMasksToBounds:YES];
        [win addSubview:banner];
        // GIF 背景 + 缩放
        UIImageView *bg = [[UIImageView alloc] initWithFrame:MakeRect(0, 0, bw, bh)];
        [bg setContentMode:2];
        LoadMediaWithPathIntoImageView(path, bg);
        double scale = cScale > 0 ? cScale : 1.0;
        [bg setTransform:CGMakeScale(scale)];
        [banner addSubview:bg];
        UIView *mk = [[UIView alloc] initWithFrame:MakeRect(0, 0, bw, bh)];
        [mk setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.4]];
        [banner addSubview:mk];
        // 内容层
        UIView *content = [[UIView alloc] initWithFrame:MakeRect(0, 0, bw, bh)];
        [content setAlpha:0.0];
        UIImageView *icon = [[UIImageView alloc] initWithFrame:MakeRect(16, (bh - 44) / 2.0, 44, 44)];
        [icon setImage:FirstImageForPath(path)];
        [icon setContentMode:2];
        id icl = [icon layer];
        [icl setCornerRadius:16.0];
        [icl setMasksToBounds:YES];
        [content addSubview:icon];
        UILabel *nowL = [[UILabel alloc] initWithFrame:MakeRect(72, 12, 120, 16)];
        [nowL setText:@"现在"];
        [nowL setFont:[UIFont systemFontOfSize:12.0]];
        [nowL setTextColor:[UIColor colorWithWhite:1.0 alpha:0.65]];
        [content addSubview:nowL];
        UILabel *tagL = [[UILabel alloc] initWithFrame:MakeRect(bw - 92, 12, 76, 16)];
        [tagL setText:@"灵动通知"];
        [tagL setFont:[UIFont systemFontOfSize:12.0]];
        [tagL setTextColor:[UIColor colorWithWhite:1.0 alpha:0.65]];
        [tagL setTextAlignment:2];
        [content addSubview:tagL];
        UILabel *ti = [[UILabel alloc] initWithFrame:MakeRect(72, 32, bw - 88, 20)];
        [ti setText:@"灵动岛GIF背景给您发来的"];
        [ti setFont:[UIFont boldSystemFontOfSize:15.0]];
        [ti setTextColor:[UIColor whiteColor]];
        [content addSubview:ti];
        UILabel *bo = [[UILabel alloc] initWithFrame:MakeRect(72, 56, bw - 88, 52)];
        [bo setText:@"这是一条GIF背景预览通知，非常完美的展示出来了。您可以实时预览选择的窗口样式！"];
        [bo setFont:[UIFont systemFontOfSize:14.0]];
        [bo setTextColor:[UIColor whiteColor]];
        [bo setNumberOfLines:2];
        [content addSubview:bo];
        [banner addSubview:content];
        [banner addTarget:gPreviewDismissTarget action:@selector(dismissPreview) forControlEvents:1 << 6];
        gPreviewWinHolder = win;
        gPreviewOverlay = banner;
        gPreviewContent = content;
        gPreviewGen++;
        long myGen = gPreviewGen;
        if (!gPreviewDismissTarget) gPreviewDismissTarget = [[LDDPreviewDismiss alloc] init];
        // spring 展开
        ((void(*)(id, SEL, double, double, double, double, NSUInteger, void(^)(void), void(^)(BOOL)))objc_msgSend)(
            (id)objc_getClass("UIView"), sel_registerName("animateWithDuration:delay:usingSpringWithDamping:initialSpringVelocity:options:animations:completion:"),
            0.4, 0.0, 0.85, 0.5, (NSUInteger)0, ^{
                [banner setFrame:expanded];
                [bl setCornerRadius:44.0];
                [content setAlpha:1.0];
            }, ^(BOOL f){
                if (myGen == gPreviewGen) {
                    dispatch_after(dispatch_time(0, 3500000000LL), (void *)&_dispatch_main_q, ^{
                        if (myGen == gPreviewGen) CollapsePreview();
                    });
                }
            });
        ProbeWrite("PREV-BANNER-ON");
    } @catch (id e) { LogReason("PREV-EXC", e); }
}

static void CollapsePreview(void) {
    id banner = gPreviewOverlay;
    id win = gPreviewWinHolder;
    id content = gPreviewContent;
    CGRect pill = gPreviewPill;
    gPreviewOverlay = nil;
    gPreviewWinHolder = nil;
    gPreviewContent = nil;
    gPreviewGen++;
    if (!banner) { if (win) ((void(*)(id, SEL, BOOL))objc_msgSend)(win, sel_registerName("setHidden:"), YES); return; }
    id bl = ((id(*)(id, SEL))objc_msgSend)(banner, sel_registerName("layer"));
    ((void(*)(id, SEL, double, double, double, double, NSUInteger, void(^)(void), void(^)(BOOL)))objc_msgSend)(
        (id)objc_getClass("UIView"), sel_registerName("animateWithDuration:delay:usingSpringWithDamping:initialSpringVelocity:options:animations:completion:"),
        0.35, 0.0, 0.85, 0.5, (NSUInteger)0, ^{
            [banner setFrame:pill];
            [bl setCornerRadius:20.0];
            [content setAlpha:0.0];
        }, ^(BOOL f){
            ((void(*)(id, SEL))objc_msgSend)(banner, sel_registerName("removeFromSuperview"));
            if (win) ((void(*)(id, SEL, BOOL))objc_msgSend)(win, sel_registerName("setHidden:"), YES);
            ProbeWrite("PREV-OFF");
        });
}


__attribute__((constructor))
static void LDDInit(void) {
    ProbeWrite("CONSTRUCTOR-RAN");
    ProbeWrite(LoadPrefsValue(@"SelectedMaterialFolder") ? "SF-OK" : "SF-NIL");
    // 对照组 hook (兼启动延迟器)
    id clsCtrl = objc_getClass("UIView");
    if (clsCtrl) {
        MSHookMessageEx((Class)clsCtrl, sel_registerName("layoutSubviews"), (IMP)CtrlLayoutHook, (IMP *)&origCtrlLayout);
        ProbeWrite("CTRL-HOOK-INSTALLED");
    } else {
        ProbeWrite("CTRL-CLASS-NIL");
    }
    gPrefsKeyEnable = @"Enablelddgifbg";
    gPrefsKeyZxh = @"Enablezxhlddgifbg";
    gPrefsKeyScale = @"lddgifbgScale";
    gPrefsKeyFolder = @"SelectedMaterialFolder";
    gRootDir = @"/var/mobile/lddgifbg";
    gGifExt = @"gif";
    gVideoExtMp4 = @"mp4";
    gVideoExtMov = @"mov";
    NSMutableDictionary *fc = [NSMutableDictionary dictionary];
    NSMutableDictionary *dc = [NSMutableDictionary dictionary];
    gFramesCache = fc;
    gDurationCache = dc;
    // 捕获 BBServer (供测试通知用)
    id clsS0 = objc_getClass("BBServer");
    if (clsS0) {
        dlopen("/System/Library/PrivateFrameworks/BulletinBoard.framework/BulletinBoard", 2);
        clsS0 = objc_getClass("BBServer");
        if (clsS0) {
            MSHookMessageEx((Class)clsS0, sel_registerName("init"), (IMP)HookBBInit, (IMP *)&origBBInit);
            Class meta = (Class)object_getClass((id)clsS0);
            if (meta) { MSHookMessageEx((Class)meta, sel_registerName("alloc"), (IMP)HookBBAlloc, (IMP *)&origBBAlloc); ProbeWrite("SBB-ALLOCHOOK"); }
        }
    }
    // Darwin notify: 设置端点"预览通知"即时触发 (灵动通知同款机制)
    static int notifyTok = 0;
    notify_register_dispatch("com.axs.lddgifbg/TestNotification", &notifyTok, (void *)&_dispatch_main_q, ^(int tok){
        ShowPreviewWindow();
    });
    // 灵动岛 hook 由 CtrlLayoutHook 延迟补挂 (避免构造时机过早)
}
