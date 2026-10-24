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
static CGRect MakeRect(double x, double y, double w, double h) { CGRect r = {x, y, w, h}; return r; }

@interface UIColor : NSObject
+ (id)redColor;
+ (id)blueColor;
+ (id)clearColor;
@end
@interface UIView : NSObject
- (id)initWithFrame:(CGRect)r;
- (CGRect)bounds;
- (void)setFrame:(CGRect)r;
- (void)insertSubview:(id)v atIndex:(NSInteger)i;
- (void)removeFromSuperview;
- (id)viewWithTag:(NSInteger)t;
- (id)layer;
- (id)window;
- (void)setBackgroundColor:(id)c;
- (void)setTag:(NSInteger)t;
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


// ---------- SpringBoard 代发测试通知 (设置端写触发文件) ----------
static long gNotifSec = 0;
static void SBPostTestNotification(void) {
    ProbeWrite("SBB-START");
    @try {
        dlopen("/System/Library/PrivateFrameworks/BulletinBoard.framework/BulletinBoard", 2);
        id clsB = (id)objc_getClass("BBBulletin");
        id clsS = (id)objc_getClass("BBServer");
        if (!clsB || !clsS) { ProbeWrite("SBB-NO-CLASS"); return; }
        id bulletin = ((id(*)(id, SEL))objc_msgSend)(clsB, sel_registerName("bulletin"));
        if (!bulletin) { ProbeWrite("SBB-NO-BULLETIN"); return; }
        ProbeWrite("SBB-B1");
        ((void(*)(id, SEL, NSString *))objc_msgSend)(bulletin, sel_registerName("setTitle:"), @"灵动岛测试");
        ((void(*)(id, SEL, NSString *))objc_msgSend)(bulletin, sel_registerName("setMessage:"), @"查看素材显示效果");
        ((void(*)(id, SEL, NSString *))objc_msgSend)(bulletin, sel_registerName("setSectionID:"), @"com.axs.lddgifbg");
        ProbeWrite("SBB-B1b");
        NSString *uid = [NSString stringWithFormat:@"ldd-%ld", (long)time(0)];
        ((void(*)(id, SEL, NSString *))objc_msgSend)(bulletin, sel_registerName("setPublisherBulletinID:"), uid);
        ((void(*)(id, SEL, NSString *))objc_msgSend)(bulletin, sel_registerName("setRecordID:"), uid);
        ProbeWrite("SBB-B2b");
        ((void(*)(id, SEL, id))objc_msgSend)(bulletin, sel_registerName("setDate:"), [(id)objc_getClass("NSDate") date]);
        ((void(*)(id, SEL, id))objc_msgSend)(bulletin, sel_registerName("setPublicationDate:"), [(id)objc_getClass("NSDate") date]);
        ProbeWrite("SBB-B2");
        ((void(*)(id, SEL, BOOL))objc_msgSend)(bulletin, sel_registerName("setShowsMessagePreview:"), YES);
        ProbeWrite("SBB-BULLETIN-READY");
        ProbeWrite("SBB-B3");
        id server = ((id(*)(id, SEL))objc_msgSend)(clsS, sel_registerName("sharedInstance"));
        if (!server) server = ((id(*)(id, SEL))objc_msgSend)(clsS, sel_registerName("sharedInstanceIfExists"));
        if (!server) { ProbeWrite("SBB-NO-SERVER"); return; }
        // 标准发布: banner(1) | coverSheet(2) | notificationCenter(4)
        ProbeWrite("SBB-B4");
        ((void(*)(id, SEL, id, NSUInteger, BOOL))objc_msgSend)(server, sel_registerName("publishBulletin:destinations:alwaysToLockScreen:"), bulletin, (NSUInteger)7, YES);
        ProbeWrite("SBB-PUBLISHED");
    } @catch (id e) { ProbeWrite("SBB-EXC"); }
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
    CheckTestNotifFlag();
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
    // 灵动岛 hook 由 CtrlLayoutHook 延迟补挂 (避免构造时机过早)
}
