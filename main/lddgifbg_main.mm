// 灵动岛GIF背景 —— 重制版主插件
// rebuild-trigger-3 (全标准 ObjC 语法, arm64e 安全)
// hook SBSystemApertureContainerViewContentView layoutSubviews
// prefs: suite lddgifbg (NSUserDefaults + plist 文件多路径兜底, 含 @P@ RootHide 路径)
// 素材: /var/mobile/lddgifbg/<文件夹>/, gif > mp4/mov > png/jpg
// 诊断: 无素材=红块, 素材加载失败=蓝块, 正常=素材

#include <stdio.h>
#include <string.h>
#include <time.h>
#include <math.h>
#include <unistd.h>

typedef struct objc_class *Class;
typedef struct objc_object { Class isa; } *id;
typedef struct objc_selector *SEL;

// 手工声明（本文件不使用 objc/runtime.h，避免与手工 typedef 冲突）
extern "C" void *class_addMethod(Class cls, SEL name, void *imp, const char *types);
extern "C" void *class_getInstanceMethod(Class cls, SEL name);
extern "C" void *class_replaceMethod(Class cls, SEL name, void *imp, const char *types);
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
extern "C" void *class_copyMethodList(Class cls, unsigned int *count);
extern "C" void *method_getName(void *method);
extern "C" const char *sel_getName(void *sel);
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
extern "C" double CFAbsoluteTimeGetCurrent(void);
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
- (void)removeObserver:(id)o name:(NSString *)n object:(id)obj;
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
static void PostRealNotification(void);
static void ConsumeForcePreview(void);
static CGRect MakeRect(double x, double y, double w, double h) { CGRect r = {x, y, w, h}; return r; }
typedef struct UIEdgeInsets { double top, left, bottom, right; } UIEdgeInsets;
typedef struct CGAffineTransform { double a, b, c, d, tx, ty; } CGAffineTransform;
static CGAffineTransform CGMakeScale(double s) { CGAffineTransform t = {s, 0, 0, s, 0, 0}; return t; }
static void PreviewAutoClose(void);
@interface UIApplication : NSObject
+ (id)sharedApplication;
- (id)keyWindow;
- (id)windows;
- (id)connectedScenes;
@end
@interface NSTimer : NSObject
+ (id)scheduledTimerWithTimeInterval:(double)ti target:(id)t selector:(SEL)s userInfo:(id)u repeats:(BOOL)r;
- (void)invalidate;
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
// (1.9.77: 移除全帧缓存, 改流式播放)

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

// ---------- 流式 GIF 播放 (优化3: 不再全帧解码, 每帧按时间轴解码, 内存 O(1)) ----------
// 优化6: 已解码帧环形缓存(3帧), 循环播放时重复帧直接复用, 显著降低软解码 CPU(发热/掉帧)
#define LDD_STREAM_CACHE 3
static void *gStreamSrc = NULL;
static NSArray *gStreamDelays = nil;
static NSUInteger gStreamCount = 0;
static NSUInteger gStreamIdx = 0;
static NSTimer *gStreamTimer = nil;
static id gStreamTarget = nil;
static NSString *gStreamPath = nil;
static UIImage *gStreamCur = nil;
static int gStreamFrameCacheIdx = -1;
static UIImage *gStreamCache[LDD_STREAM_CACHE];
static int gStreamCacheIdxArr[LDD_STREAM_CACHE];
static int gStreamCachePos = 0;
static __weak UIImageView *gStreamIV = nil;

@interface LDDStreamTarget : NSObject
- (void)streamTick:(id)t;
@end

static void StreamRestartTimer(void);
static void StreamPause(void) {
    // 只停 timer, 保留素材/帧状态 -> 岛再次展开时走最稳的续播路径
    if (gStreamTimer) {
        static int plog = 0;
        if (plog < 8) { plog++; ProbeWrite("STREAM-PAUSE"); }
        [gStreamTimer invalidate]; gStreamTimer = nil;
    }
}static void StreamStop(void) {
    StreamPause();
    if (gStreamSrc) { CFRelease(gStreamSrc); gStreamSrc = NULL; }
    gStreamDelays = nil; gStreamCount = 0; gStreamIdx = 0;
    gStreamPath = nil; gStreamCur = nil; gStreamFrameCacheIdx = -1;
    gStreamIV = nil;
    for (int i = 0; i < LDD_STREAM_CACHE; i++) { gStreamCache[i] = nil; gStreamCacheIdxArr[i] = -1; }
    gStreamCachePos = 0;
}
static void StreamCachePut(UIImage *img, int frameIdx) {
    gStreamCache[gStreamCachePos] = img;
    gStreamCacheIdxArr[gStreamCachePos] = frameIdx;
    gStreamCachePos = (gStreamCachePos + 1) % LDD_STREAM_CACHE;
}
static UIImage *StreamCacheGet(int frameIdx) {
    for (int i = 0; i < LDD_STREAM_CACHE; i++) {
        if (gStreamCacheIdxArr[i] == frameIdx && gStreamCache[i]) return gStreamCache[i];
    }
    return nil;
}
static void StreamAdvance(void) {
    if (!gStreamSrc || gStreamCount == 0) { StreamStop(); return; }
    static int tlog = 0;
    if (tlog < 5) { tlog++; char tb[64]; snprintf(tb, sizeof(tb), "STREAM-TICK %lu", (unsigned long)gStreamIdx); ProbeWrite(tb); }
    gStreamIdx = (gStreamIdx + 1) % gStreamCount;
    if ((int)gStreamIdx != gStreamFrameCacheIdx) {
        gStreamCur = StreamCacheGet((int)gStreamIdx);
        if (!gStreamCur) {
            CGImageRef cg = CGImageSourceCreateImageAtIndex(gStreamSrc, (size_t)gStreamIdx, 0);
            if (cg) {
                gStreamCur = [UIImage imageWithCGImage:cg scale:1.0 orientation:0];
                CFRelease((void *)cg);
                StreamCachePut(gStreamCur, (int)gStreamIdx);
            }
        }
        gStreamFrameCacheIdx = (int)gStreamIdx;
    }
    if (gStreamIV) [gStreamIV setImage:gStreamCur];
    else { StreamPause(); return; }  // 优化7: 视图被 SB 重建(weak 失效)时只暂停不杀流, 下次布局续播恢复
    StreamRestartTimer();
}
static void StreamRestartTimer(void) {
    if (gStreamTimer) { [gStreamTimer invalidate]; gStreamTimer = nil; }
    if (!gStreamSrc || gStreamCount == 0) return;
    if (!gStreamTarget) gStreamTarget = [[LDDStreamTarget alloc] init];
    double d = 0.1;
    if (gStreamDelays) {
        NSUInteger dcnt = ((NSUInteger(*)(id, SEL))objc_msgSend)((id)gStreamDelays, sel_registerName("count"));
        if (gStreamIdx < dcnt) {
            id dobj = ((id(*)(id, SEL, NSUInteger))objc_msgSend)((id)gStreamDelays, sel_registerName("objectAtIndex:"), gStreamIdx);
            double dd = dobj ? ((double(*)(id, SEL))objc_msgSend)(dobj, sel_registerName("doubleValue")) : 0.1;
            if (dd >= 0.02) d = dd;
        }
    }
    gStreamTimer = [NSTimer scheduledTimerWithTimeInterval:d target:gStreamTarget selector:@selector(streamTick:) userInfo:nil repeats:NO];
    // 优化9: 加入 common modes —— 横幅展开动画在 tracking 模式下跑, default 模式 timer 不回调
    // (这就是"首次通知不动, 连续通知才动"的根因: 首次加载后动画窗口内一次都不触发, 收起即被暂停)
    id rl = ((id(*)(id, SEL))objc_msgSend)((id)objc_getClass("NSRunLoop"), sel_registerName("mainRunLoop"));
    if (rl) ((void(*)(id, SEL, id, id))objc_msgSend)(rl, sel_registerName("addTimer:forMode:"), gStreamTimer, @"kCFRunLoopCommonModes");
    static int rlog2 = 0;
    if (rlog2 < 8) { rlog2++; ProbeWrite("STREAM-RESTART"); }
}
static void LoadGIFWithPathIntoImageView(NSString *path, UIImageView *iv) {
    if (!path || !iv) return;
    if (gStreamPath && [gStreamPath isEqualToString:path] && gStreamSrc) {
        // 同素材续播 (隐藏时 timer 已停); 布局高频时仅 timer 停止才恢复, 避免反复重启卡帧
        static int rlog = 0;
        if (rlog < 10) { rlog++; ProbeWrite("STREAM-RESUME"); }
        gStreamIV = iv;
        if (gStreamCur) [iv setImage:gStreamCur];
        if (!gStreamTimer) StreamRestartTimer();
        return;
    }
    ProbeWrite("STREAM-RELOAD");
    StreamStop();
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (!data) return;
    void *src = CGImageSourceCreateWithData((__bridge void *)data, 0);
    if (!src) return;
    NSUInteger count = CGImageSourceGetCount(src);
    if (count == 0) { CFRelease(src); return; }
    // 只读帧延迟表 (不解码图像, 毫秒级)
    NSMutableArray *delays = [NSMutableArray arrayWithCapacity:count];
    for (NSUInteger i = 0; i < count; i++) {
        double delay = 0.1;
        void *props = CGImageSourceCopyPropertiesAtIndex(src, i, 0);
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
        [delays addObject:[NSNumber numberWithDouble:delay]];
    }
    // 首帧立即显示
    CGImageRef cg0 = CGImageSourceCreateImageAtIndex(src, 0, 0);
    UIImage *img0 = cg0 ? [UIImage imageWithCGImage:cg0 scale:1.0 orientation:0] : nil;
    if (cg0) CFRelease((void *)cg0);
    [iv setImage:img0];
    gStreamSrc = src;
    gStreamDelays = delays;
    gStreamCount = count;
    gStreamIdx = 0;
    gStreamPath = path;
    gStreamIV = iv;
    gStreamFrameCacheIdx = 0;
    gStreamCur = img0;
    for (int i = 0; i < LDD_STREAM_CACHE; i++) { gStreamCache[i] = nil; gStreamCacheIdxArr[i] = -1; }
    gStreamCachePos = 0;
    if (img0) StreamCachePut(img0, 0);
    StreamRestartTimer();
    static int slog = 0;
    if (slog < 3) { slog++; char lb[96]; snprintf(lb, sizeof(lb), "STREAM-START %lu", (unsigned long)count); ProbeWrite(lb); }
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
        // replace 后通知对象变成新 item: 换绑循环观察者, 否则第二次通知起视频播完不循环
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc removeObserver:gObserver name:@"AVPlayerItemDidPlayToEndTimeNotification" object:gPlayerItem];
        gPlayerItem = item;
        [nc addObserver:gObserver selector:@selector(videoDidEnd:) name:@"AVPlayerItemDidPlayToEndTimeNotification" object:gPlayerItem];
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
@implementation LDDStreamTarget
- (void)streamTick:(id)t;
{
    StreamAdvance();
}
@end

static double gForceLast = 0;
// 消费去重 v2: 不依赖文件内容 (bundle 旧版写空内容也生效)
//   1) 消费后 rename 成 .consumed (残留/第二消费点 access 原文件失败)
//   2) 4.5s 时间防抖 (第一条通知显示期间的二次消费忽略)
static double gLastConsumeT = 0;
static void ConsumeForcePreview(void) {
    const char *fp = "/var/mobile/lddgifbg/__force_preview__";
    if (access(fp, 0) != 0) return;
    rename(fp, "/var/mobile/lddgifbg/__force_preview__.consumed");
    double now = CFAbsoluteTimeGetCurrent();
    if (now - gLastConsumeT < 1.0) { ProbeWrite("RN-CONSUME-DUP"); return; }
    gLastConsumeT = now;
    PostRealNotification();
}
static void CheckForcePreviewTick(void) {
    double t = CFAbsoluteTimeGetCurrent();
    if (t - gForceLast < 0.05) return;
    gForceLast = t;
    ConsumeForcePreview();
}

// 触发监控: 独立 GCD 轮询 (0.1s), 不依赖 SB 布局回调。
// 之前 CheckForcePreviewTick 只在 CtrlLayoutHook 里调用且被尺寸过滤挡掉,
// 用户在设置页点预览时若 SB 无布局事件, 触发文件无人消费 -> "要点好几次才弹"。
static void ForceMonitorTick(void) {
    CheckForcePreviewTick();
    dispatch_after(dispatch_time(0, 100 * 1000000LL), &_dispatch_main_q, ^{ ForceMonitorTick(); });
}
static void StartForceMonitor(void) {
    dispatch_after(dispatch_time(0, 100 * 1000000LL), &_dispatch_main_q, ^{ ForceMonitorTick(); });
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

// ---------- 捕获横幅呈现层 (hook SBNotificationBannerDestination init) ----------
static id gPresentLayer = nil;
static id (*origBNDInit)(id, SEL);
static id HookBNDInit(id self, SEL _c) {
    id r = origBNDInit(self, _c);
    if (!gPresentLayer) { gPresentLayer = r; ProbeWrite("BND-CAPTURED"); }
    return r;
}
// 运行时兜底: 从 dispatcher destinations / SB ivar 找呈现层
static void FindLayerConsider(id o, SEL sISL, SEL sPost, id *bestISL, id *bestPost) {
    if (!o) return;
    const char *cn = class_getName((__bridge void *)object_getClass(o));
    if (cn) {
        char line[128];
        snprintf(line, sizeof(line), "PRES-CAND-%s", cn);
        ProbeWrite(line);
        if (strstr(cn, "BannerManager") || strstr(cn, "NotificationDispatcher")) {
            static int enl = 0;
            if (enl < 80) {
                unsigned int mc = 0;
                void **ms = (void **)class_copyMethodList((Class)object_getClass(o), &mc);
                if (ms) {
                    for (unsigned int i = 0; i < mc && enl < 80; i++) {
                        if (!ms[i]) continue;
                        void *m = method_getName(ms[i]);
                        if (!m) continue;
                        const char *mn = sel_getName((SEL)m);
                        if (!mn) continue;
                        enl++;
                        char ml[192];
                        snprintf(ml, sizeof(ml), "PRES-%s-METHOD-%s", cn, mn);
                        ProbeWrite(ml);
                    }
                }
            }
        }
    }
    if (!*bestISL && ((BOOL(*)(id, SEL, SEL))objc_msgSend)(o, sel_registerName("respondsToSelector:"), sISL)) *bestISL = o;
    if (!*bestPost && ((BOOL(*)(id, SEL, SEL))objc_msgSend)(o, sel_registerName("respondsToSelector:"), sPost)) *bestPost = o;
}
static id FindPresentLayer(void) {
    // 优化17: 不再被 BND-CAPTURED 锁死 —— 遍历全部候选呈现层,
    // 优先选支持 presentModalBannerAndExpandForNotificationRequest: 的(直接上岛, 一条),
    // 其次支持 postNotificationRequest: 的; BND 缓存仅作最后兜底。
    id bestISL = nil, bestPost = nil;
    SEL sISL = sel_registerName("presentModalBannerAndExpandForNotificationRequest:");
    SEL sPost = sel_registerName("postNotificationRequest:");
    // 路线1: NCNotificationDispatcher 的 destinations 集合
    id clsD = (id)objc_getClass("NCNotificationDispatcher");
    if (clsD) ProbeWrite("PRES-DISP-CLS-YES"); else ProbeWrite("PRES-DISP-CLS-NO");
    id disp = nil;
    if (clsD) {
        const char *sels[] = {"sharedInstance", "defaultDispatcher", "sharedDispatcher",
                             "sharedNotificationDispatcher", "defaultNotificationDispatcher",
                             "notificationDispatcher", "dispatcher", 0};
        for (int i = 0; sels[i] && !disp; i++) {
            SEL s = sel_registerName(sels[i]);
            if (((BOOL(*)(id, SEL, SEL))objc_msgSend)(clsD, sel_registerName("respondsToSelector:"), s))
                disp = ((id(*)(id, SEL))objc_msgSend)(clsD, s);
        }
    }
    if (disp) {
        ProbeWrite("PRES-DISP-OBJ-YES");
        unsigned int cnt = 0;
        void **ivars = (void **)class_copyIvarList((Class)clsD, &cnt);
        char dbg[192];
        snprintf(dbg, sizeof(dbg), "PRES-DISP-IVARS-%u", cnt);
        ProbeWrite(dbg);
        for (unsigned int i = 0; i < cnt; i++) {
            const char *nm = ivar_getName(ivars[i]);
            if (!nm) continue;
            if (strstr(nm, "estination")) {
                id coll = object_getIvar(disp, ivars[i]);
                if (!coll) continue;
                {
                    char dn[192];
                    snprintf(dn, sizeof(dn), "PRES-DEST-COLL-%s", nm);
                    ProbeWrite(dn);
                }
                id arr = nil;
                SEL sAll = sel_registerName("allObjects");
                if (((BOOL(*)(id, SEL, SEL))objc_msgSend)(coll, sel_registerName("respondsToSelector:"), sAll))
                    arr = ((id(*)(id, SEL))objc_msgSend)(coll, sAll);
                else arr = coll;
                NSUInteger n = ((NSUInteger(*)(id, SEL))objc_msgSend)(arr, sel_registerName("count"));
                {
                    char cn[128];
                    snprintf(cn, sizeof(cn), "PRES-DEST-N-%lu", (unsigned long)n);
                    ProbeWrite(cn);
                }
                for (NSUInteger k = 0; k < n; k++) {
                    id obj = ((id(*)(id, SEL, NSUInteger))objc_msgSend)(arr, sel_registerName("objectAtIndex:"), k);
                    FindLayerConsider(obj, sISL, sPost, &bestISL, &bestPost);
                }
            }
        }
        if (bestISL) { ProbeWrite("PRES-CHOOSE-DEST-ISL"); gPresentLayer = bestISL; return bestISL; }
        if (bestPost) { ProbeWrite("PRES-CHOOSE-DEST-POST"); gPresentLayer = bestPost; return bestPost; }
    }
    // 路线2: UIApplication(SpringBoard 实例) ivar 扫 —— iOS16.4 呈现层由 SpringBoard 持有
    id sb = ((id(*)(id, SEL))objc_msgSend)((id)objc_getClass("UIApplication"), sel_registerName("sharedApplication"));
    if (sb) ProbeWrite("PRES-UIAPP-YES"); else ProbeWrite("PRES-UIAPP-NO");
    if (sb) {
        unsigned int cnt = 0;
        void **ivars = (void **)class_copyIvarList((Class)objc_getClass("SpringBoard"), &cnt);
        for (unsigned int i = 0; i < cnt; i++) {
            const char *nm = ivar_getName(ivars[i]);
            if (!nm) continue;
            if (strstr(nm, "anner") || strstr(nm, "otification") || strstr(nm, "ispatcher") || strstr(nm, "perture") || strstr(nm, "resentab")) {
                {
                    char ivn[192];
                    snprintf(ivn, sizeof(ivn), "PRES-SBIVAR-%s", nm);
                    ProbeWrite(ivn);
                }
                id v = object_getIvar(sb, ivars[i]);
                if (v) {
                    const char *vcn = class_getName((__bridge void *)object_getClass(v));
                    if (vcn) {
                        char vn[192];
                        snprintf(vn, sizeof(vn), "PRES-SBIVAR-VAL-%s", vcn);
                        ProbeWrite(vn);
                    }
                }
                FindLayerConsider(v, sISL, sPost, &bestISL, &bestPost);
            }
        }
        if (bestISL) { ProbeWrite("PRES-CHOOSE-SB-ISL"); gPresentLayer = bestISL; return bestISL; }
        if (bestPost) { ProbeWrite("PRES-CHOOSE-SB-POST"); gPresentLayer = bestPost; return bestPost; }
    }
    // 路线3: BND-CAPTURED 缓存兜底
    if (gPresentLayer) { ProbeWrite("PRES-BND-FALLBACK"); return gPresentLayer; }
    return nil;
}

static long gNotifSec = 0;
static void CheckTestNotifFlag(void) {
    long t = time(0);
    if (t == gNotifSec) return;
    gNotifSec = t;
    if (access("/var/mobile/lddgifbg/__test_notif__", 0) == 0) {
        remove("/var/mobile/lddgifbg/__test_notif__");
        PostRealNotification();
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
    // 优化10: 仅接管真正的内容层 _SBSystemApertureContainerViewContentView。
    // 特效层(MagiciansCurtain/GainMap)与容器层若各自创建 GIF 子视图,
    // 首屏会被挂到不可见层 -> 首次通知"不动"; 连续通知时特效层停摆、内容层重建才恢复。
    const char *cn = object_getClassName(self);
    if (!cn || !strstr(cn, "ContainerViewContentView")) {
        static int skiplog = 0;
        if (skiplog < 5) { skiplog++; char lb[96]; snprintf(lb, sizeof(lb), "LDD-SKIP-OTHER: %s", cn ? cn : "?"); ProbeWrite(lb); }
        objc_autoreleasePoolPop(pool);
        return;
    }
    static int cvlog = 0;
    if (cvlog < 3) { cvlog++; char lb[128]; snprintf(lb, sizeof(lb), "LDD-CONTENT-VIEW: %s", cn); ProbeWrite(lb); }
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
    static int slog2 = 0;
    if (slog2 < 20) {
        slog2++;
        char sb[96];
        snprintf(sb, sizeof(sb), "SHOW-%d h=%.0f", show ? 1 : 0, bb.h);
        ProbeWrite(sb);
    }
    if (!show) {
        // 优化4: 岛隐藏时停止一切播放; 保留素材状态与视图 -> 下次通知走续播秒恢复
        UIImageView *oldV = (UIImageView *)[self viewWithTag:9999];
        if (oldV) { [oldV stopAnimating]; [oldV setImage:nil]; [oldV setAnimationImages:nil]; }
        StopVideo();
        StreamPause();
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
        // 视频"播放中"必须 layer 还挂在 view 上 (StopVideo 已移除 layer 但 gPlayerLayer 非 nil -> 旧判定误判跳过重载 = 二次通知无背景 bug)
        BOOL playing = [view isAnimating];
        if (!playing && gPlayerLayer) {
            id sl = ((id(*)(id, SEL))objc_msgSend)(gPlayerLayer, sel_registerName("superlayer"));
            id vly = ((id(*)(id, SEL))objc_msgSend)(view, sel_registerName("layer"));
            if (sl == vly) playing = YES;
        }
        if (playing) needReload = NO;
        // 优化8: GIF 流仍挂在当前 view 上 -> 免重载; 若 timer 被暂停(岛隐藏/视图重建)立即保活恢复
        if (gStreamSrc && gStreamIV == view) {
            needReload = NO;
            if (!gStreamTimer) StreamRestartTimer();
        }
    }
    if (needReload) {
        gLoadedPath = path;
        LoadMediaWithPathIntoImageView(path, view);
    }
    // 优化5: 仅在不在 index0 时才重插 (避免布局涟漪)
    id subs = ((id(*)(id, SEL))objc_msgSend)(self, sel_registerName("subviews"));
    id firstSub = subs ? ((id(*)(id, SEL))objc_msgSend)(subs, sel_registerName("firstObject")) : nil;
    if (firstSub != view) [self insertSubview:view atIndex:0];
    objc_autoreleasePoolPop(pool);
}

// ---------- 构造 ----------
// 全局 UIView hook: 在每次布局时识别"灵动岛容器视图"(类名含 Aperture)并接管
static void (*origCtrlLayout)(id, SEL);
static void LDDIslandLayout(id self);
static void CtrlLayoutHook(id self, SEL _cmd) {
    static int once = 0;
    if (!once) { once = 1; ProbeWrite("CTRL-HOOK-FIRED"); }
    // 优化1: 尺寸快速过滤 (绝大多数视图整屏/极小, 直接跳过, 零消息开销之外的成本)
    CGRect bb = ((CGRect(*)(id, SEL))objc_msgSend)(self, sel_registerName("bounds"));
    if (bb.w > 460.0 || bb.h > 150.0 || bb.w < 40.0 || bb.h < 10.0) {
        if (origCtrlLayout) origCtrlLayout(self, _cmd);
        return;
    }
    CheckForcePreviewTick();
    // 优化2: 类名匹配缓存 (同一类只做一次 strstr, 之后指针比较)
    static const char *gMatchNames[16]; static int gMatchN = 0;
    static const char *gSkipNames[64]; static int gSkipN = 0;
    const char *cn = object_getClassName(self);
    if (cn) {
        for (int i = 0; i < gMatchN; i++) {
            if (gMatchNames[i] == cn) { LDDIslandLayout(self); break; }
        }
        int hit = 0;
        for (int i = 0; i < gMatchN; i++) if (gMatchNames[i] == cn) hit = 1;
        if (!hit) {
            int skip = 0;
            for (int i = 0; i < gSkipN; i++) if (gSkipNames[i] == cn) { skip = 1; break; }
            if (!skip) {
                if (strstr(cn, "Aperture") || strstr(cn, "Island")) {
                    if (gMatchN < 16) gMatchNames[gMatchN++] = cn;
                    static int logged = 0;
                    if (!logged) {
                        logged = 1;
                        char line[160];
                        snprintf(line, sizeof(line), "MATCH-CLASS: %s", cn);
                        ProbeWrite(line);
                    }
                    LDDIslandLayout(self);
                } else if (gSkipN < 64) {
                    gSkipNames[gSkipN++] = cn;
                }
            }
        }
    }
    if (origCtrlLayout) origCtrlLayout(self, _cmd);
}

// 给 UNNotificationRequest 动态补 iOS16 缺失的私有方法（initWithNotificationRequest: 内部会依次访问这些 selector）
static NSString *LDDUnreqSection(id self, SEL _c) { return @"com.apple.MobileMail"; }
static NSString *LDDUnreqNotifID(id self, SEL _c) {
    // 基于公开的 identifier 生成通知唯一标识
    id ident = ((id(*)(id, SEL))objc_msgSend)(self, sel_registerName("identifier"));
    return ident ? ident : @"ldd-preview";
}
static NSString *LDDUnreqSectionLegacy(id self, SEL _c) { return @"com.apple.MobileMail"; }
static id LDDUnreqSource(id self, SEL _c) { return nil; }
static BOOL LDDUnreqFromNC(id self, SEL _c) { return NO; }
static BOOL LDDUnreqIsRemote(id self, SEL _c) { return YES; }
static NSString *LDDUnreqStr(id self, SEL _c) { return @"ldd-preview"; }
static NSString *LDDUnreqEmpty(id self, SEL _c) { return @""; }
static id LDDUnreqDate2(id self, SEL _c) { return ((id(*)(id, SEL))objc_msgSend)((id)objc_getClass("NSDate"), sel_registerName("date")); }
static id LDDUnreqNil(id self, SEL _c) { return nil; }
static id LDDUnreqDict(id self, SEL _c) { return ((id(*)(id, SEL))objc_msgSend)((id)objc_getClass("NSDictionary"), sel_registerName("dictionary")); }
static id LDDUnreqArray(id self, SEL _c) { return ((id(*)(id, SEL))objc_msgSend)((id)objc_getClass("NSArray"), sel_registerName("array")); }
static double LDDUnreqZeroD(id self, SEL _c) { return 0.0; }
static NSUInteger LDDUnreqZeroQ(id self, SEL _c) { return 0; }

// ---------- 万能转发兜底 (根治"未知私有方法逐个冒") ----------
// SB 渲染层 / initWithNotificationRequest: 会访问 UNNotificationRequest 与
// UNNotificationContent 上我们未预知的私有 getter (iOS17+ 头)。逐名补齐不可穷举,
// 这里给两个类挂 methodSignatureForSelector: + forwardInvocation:, 任何未识别
// selector 一律返回签名 "@@:"(id, 8字节缓冲) 并归零返回值 -> nil/0/NO,
// 对所有标量与 id 类型安全, 不再抛 unrecognized selector。
static id LDD_FwdSigFn(id self, SEL _cmd, SEL aSel) {
    id clsMS = (id)objc_getClass("NSMethodSignature");
    if (!clsMS) return nil;
    return ((id(*)(id, SEL, const char*))objc_msgSend)(clsMS, sel_registerName("signatureWithObjCTypes:"), "@@:");
}
static void LDD_FwdInvFn(id self, SEL _cmd, id inv) {
    id invObj = inv;
    if (!invObj) return;
    SEL sMS = sel_registerName("methodSignature");
    if (!((BOOL(*)(id, SEL, SEL))objc_msgSend)(invObj, sel_registerName("respondsToSelector:"), sMS)) return;
    id sig = ((id(*)(id, SEL))objc_msgSend)(invObj, sMS);
    if (!sig) return;
    NSUInteger rl = ((NSUInteger(*)(id, SEL))objc_msgSend)(sig, sel_registerName("methodReturnLength"));
    if (rl > 0 && rl <= 64) {
        char buf[64]; memset(buf, 0, sizeof(buf));
        SEL sSRV = sel_registerName("setReturnValue:");
        if (((BOOL(*)(id, SEL, SEL))objc_msgSend)(invObj, sel_registerName("respondsToSelector:"), sSRV))
            ((void(*)(id, SEL, const void*))objc_msgSend)(invObj, sSRV, buf);
    }
}
static void LDDInstallFwd(id cls) {
    if (!cls) return;
    Class k = (Class)cls;
    SEL sFS = sel_registerName("methodSignatureForSelector:");
    if (class_getInstanceMethod(k, sFS)) class_replaceMethod(k, sFS, (IMP)LDD_FwdSigFn, "@@::");
    else class_addMethod(k, sFS, (IMP)LDD_FwdSigFn, "@@::");
    SEL sFI = sel_registerName("forwardInvocation:");
    if (class_getInstanceMethod(k, sFI)) class_replaceMethod(k, sFI, (IMP)LDD_FwdInvFn, "v@:@");
    else class_addMethod(k, sFI, (IMP)LDD_FwdInvFn, "v@:@");
}

// ---------- 6秒自动关闭 (用户方案: 第一条弹出6秒后模拟手动关闭, 阻断第二条标准横幅) ----------
static int gCloseEnumerated = 0;
static id gLastReq = nil;
static void LDDCloseFirstBanner(id req) {
    @try {
        if (!gCloseEnumerated) {
            gCloseEnumerated = 1;
            // 探针: 枚举候选关闭 API (一次性)
            const char *clsNames[] = {"SBSystemApertureController", "SBNCNotificationDispatcher", "SBBannerManager", "SBNotificationBannerDestination", 0};
            for (int i = 0; clsNames[i]; i++) {
                id cls = (id)objc_getClass(clsNames[i]);
                if (!cls) continue;
                unsigned int mc = 0;
                void **ms = (void **)class_copyMethodList((Class)cls, &mc);
                for (unsigned int k = 0; k < mc; k++) {
                    if (!ms[k]) continue;
                    void *m = method_getName(ms[k]);
                    if (!m) continue;
                    const char *mn = sel_getName((SEL)m);
                    if (!mn) continue;
                    if (strstr(mn, "dismiss") || strstr(mn, "collapse") || strstr(mn, "contract") ||
                        strstr(mn, "withdraw") || strstr(mn, "remove") || strstr(mn, "revoke") ||
                        strstr(mn, "Presentable")) {
                        char ml[320];
                        snprintf(ml, sizeof(ml), "CLOSE-METHOD-%s-%s", clsNames[i], mn);
                        ProbeWrite(ml);
                    }
                }
            }
        }
        // 候选1(安全): 视图层收起岛展开 —— 遍历窗口树找 SBSystemApertureContainerView, 设 collapsed=YES
        // (纯视图状态切换, 无消息签名风险; 1.9.121 探针: +[UIApplication keyWindow] 是实例方法, 类方法调用会 EXC)
        BOOL collapsedAny = NO;
        id clsAV = (id)objc_getClass("SBSystemApertureContainerView");
        if (clsAV) {
            @try {
                SEL sCollapse = sel_registerName("setCollapsed:");
                id app = ((id(*)(id, SEL))objc_msgSend)((id)objc_getClass("UIApplication"), sel_registerName("sharedApplication"));
                id wins = app ? ((id(*)(id, SEL))objc_msgSend)(app, sel_registerName("windows")) : nil;
                if (wins) {
                    NSArray *ws = (NSArray *)wins;
                    if (ws) {
                        for (id w in ws) {
                            if (!w) continue;
                            // 纯 C BFS 遍历窗口树找容器视图 (不依赖 Foundation 类型接口)
                            id queue[128]; int qh = 0, qt = 0;
                            queue[qt++] = w;
                            while (qh < qt && qt < 128) {
                                id v = queue[qh++];
                                if (!v) continue;
                                if (object_getClass(v) == (Class)clsAV ||
                                    (object_getClassName(v) && strstr(object_getClassName(v), "ApertureContainerView"))) {
                                    if (((BOOL(*)(id, SEL, SEL))objc_msgSend)(v, sel_registerName("respondsToSelector:"), sCollapse)) {
                                        ((void(*)(id, SEL, BOOL))objc_msgSend)(v, sCollapse, YES);
                                        collapsedAny = YES;
                                    }
                                    continue;
                                }
                                id subs = ((id(*)(id, SEL))objc_msgSend)(v, sel_registerName("subviews"));
                                if (subs) {
                                    NSArray *svs = (NSArray *)subs;
                                    if (svs) {
                                        NSUInteger c = ((NSUInteger(*)(id, SEL))objc_msgSend)(svs, sel_registerName("count"));
                                        for (NSUInteger bi = 0; bi < c && qt < 64; bi++) {
                                            id sv = ((id(*)(id, SEL, NSUInteger))objc_msgSend)(svs, sel_registerName("objectAtIndex:"), bi);
                                            if (sv) queue[qt++] = sv;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } @catch (id e) { LogReason("CLOSE-COLLAPSE-EXC", e); }
        }
        ProbeWrite(collapsedAny ? "CLOSE-COLLAPSE-OK" : "CLOSE-COLLAPSE-NOVIEW");
        // 候选2: SBNCNotificationDispatcher removeNotificationRequest: (对象参数, 无签名风险)
        // 移除通知请求 -> 通知从呈现队列移除, 阻断自动降级为标准横幅
        id sb2 = ((id(*)(id, SEL))objc_msgSend)((id)objc_getClass("UIApplication"), sel_registerName("sharedApplication"));
        if (sb2) {
            unsigned int cnt2 = 0;
            void **ivars2 = (void **)class_copyIvarList((Class)objc_getClass("SpringBoard"), &cnt2);
            id dispatcher = nil;
            for (unsigned int i = 0; i < cnt2; i++) {
                const char *nm2 = ivar_getName(ivars2[i]);
                if (nm2 && strstr(nm2, "NotificationDispatcher")) { dispatcher = object_getIvar(sb2, ivars2[i]); break; }
            }
            if (dispatcher) {
                SEL sRm = sel_registerName("removeNotificationRequest:");
                if (((BOOL(*)(id, SEL, SEL))objc_msgSend)(dispatcher, sel_registerName("respondsToSelector:"), sRm)) {
                    ProbeWrite("CLOSE-REMOVE-TRY");
                    @try {
                        ((void(*)(id, SEL, id))objc_msgSend)(dispatcher, sRm, req);
                        ProbeWrite("CLOSE-REMOVE-OK");
                        return;
                    } @catch (id e) { LogReason("CLOSE-REMOVE-EXC", e); }
                }
            }
        }
        // 候选3: SBBannerManager dismissAllBannersInAllWindowScenesAnimated:reason: 传对象
        // (1.9.120 崩因: reason 传 1(数字) 被当对象 retain; 传 NSString 对象在两种签名下均安全)
        id sb3 = ((id(*)(id, SEL))objc_msgSend)((id)objc_getClass("UIApplication"), sel_registerName("sharedApplication"));
        id bm3 = nil;
        if (sb3) {
            unsigned int cnt3 = 0;
            void **ivars3 = (void **)class_copyIvarList((Class)objc_getClass("SpringBoard"), &cnt3);
            for (unsigned int i = 0; i < cnt3; i++) {
                const char *nm3 = ivar_getName(ivars3[i]);
                if (nm3 && strstr(nm3, "annerManager")) { bm3 = object_getIvar(sb3, ivars3[i]); break; }
            }
        }
        if (bm3) {
            SEL sD3 = sel_registerName("dismissAllBannersInAllWindowScenesAnimated:reason:");
            if (((BOOL(*)(id, SEL, SEL))objc_msgSend)(bm3, sel_registerName("respondsToSelector:"), sD3)) {
                ProbeWrite("CLOSE-DISMISS-ALL-TRY");
                @try {
                    ((void(*)(id, SEL, BOOL, id))objc_msgSend)(bm3, sD3, YES, @"ldd-autoclose");
                    ProbeWrite("CLOSE-DISMISS-ALL-OK");
                    return;
                } @catch (id e) { LogReason("CLOSE-DISMISS-ALL-EXC", e); }
            }
        }
        ProbeWrite("CLOSE-NOMETHOD");
    } @catch (id e) { LogReason("CLOSE-EXC", e); }
}
static void LDDCloseAfter(double sec) {
    dispatch_after(dispatch_time(0, (int64_t)(sec * 1000000000LL)), &_dispatch_main_q, ^{ LDDCloseFirstBanner(gLastReq); });
    // 第二波: 10秒再撤一次 —— 撤掉 6 秒后系统自动降级出现的第二条标准横幅
    dispatch_after(dispatch_time(0, (int64_t)((sec + 4.0) * 1000000000LL)), &_dispatch_main_q, ^{ LDDCloseFirstBanner(gLastReq); });
}

// ---------- 真实通知呈现 (灵动通知同款: 直接驱动 SB 横幅呈现层, 不入通知中心) ----------
static double gLastPostT = 0;
static void PostRealNotification(void) {
    // 优化11: 去重 —— 已单通道化(设置页只写文件)且轮询即时消费, 每次点击必弹一条。
    // 窗口 4.5s ≈ 横幅显示时长: 第一条显示期间的连点全部去重,
    // 消除"第一条关闭后紧跟第二条"的队列排队; 等第一条关完再点即弹新的。
    double nowT = CFAbsoluteTimeGetCurrent();
    if (nowT - gLastPostT < 1.0) return;
    gLastPostT = nowT;
    ProbeWrite("RN-START");
    @try {
        dlopen("/System/Library/Frameworks/UserNotifications.framework/UserNotifications", 2);
        dlopen("/System/Library/PrivateFrameworks/NotificationCenter.framework/NotificationCenter", 2);
        NSString *uid = [NSString stringWithFormat:@"lddpres-%ld", (long)time(0)];

        // === 1. UN 层内容 (供 contentProvider / initWithNotificationRequest 使用) ===
        id clsContent = (id)objc_getClass("UNMutableNotificationContent");
        id content = clsContent ? ((id(*)(id, SEL))objc_msgSend)((id)clsContent, sel_registerName("new")) : nil;
        if (content) {
            ((void(*)(id, SEL, id))objc_msgSend)(content, sel_registerName("setTitle:"), @"灵动岛GIF背景");
            ((void(*)(id, SEL, id))objc_msgSend)(content, sel_registerName("setBody:"), @"预览通知：岛展开显示您的背景");
        }
        // 优化12: 不再创建 UNTimeIntervalNotificationTrigger (传 nil)。
        // 根因: 2a initWithNotificationRequest: 崩前已把带 0.1s trigger 的 UN 请求部分注册,
        // 0.1 秒后系统自动弹出一条真实 UN 通知(默认铃声图标) -> "第一条关闭后第二条紧跟弹出"。
        // 去掉 trigger 后 UN 层无可调度请求, 只剩 postNotificationRequest: 一条横幅。
        id trigger = nil;
        id unreq = nil;
        id clsUNReq = (id)objc_getClass("UNNotificationRequest");
        if (clsUNReq && content) {
            SEL sR = sel_registerName("requestWithIdentifier:content:trigger:");
            unreq = ((id(*)(id, SEL, id, id, id))objc_msgSend)(clsUNReq, sR, uid, content, trigger);
        }
        if (unreq) ProbeWrite("RN-UN-BUILT");

        // === 2. NCNotificationRequest + ContentProvider ===
        // 修复思路: iOS16 的 initWithNotificationRequest: 内部会访问 UNNotificationRequest.sectionIdentifier,
        // 该 selector 在 iOS16 上不存在导致崩溃。这里先动态给 UNNotificationRequest 补上该方法,
        // 让系统转换能走通, 构造出的 req 字段完整, postNotificationRequest: 内部字典不会插入 nil。
        id clsReq = (id)objc_getClass("NCNotificationRequest");
        id req = nil;
        if (clsReq) {
            // 动态补全 iOS16 缺失的 UNNotificationRequest 私有方法
            id clsUNR = (id)objc_getClass("UNNotificationRequest");
            if (clsUNR) {
                struct { const char *name; void *imp; const char *types; } patches[] = {
                    {"sectionIdentifier",        (void*)LDDUnreqSection,      "@@:"},
                    {"notificationIdentifier",   (void*)LDDUnreqNotifID,      "@@:"},
                    {"section",                  (void*)LDDUnreqSectionLegacy, "@@:"},
                    {"source",                   (void*)LDDUnreqSource,       "@@:"},
                    {"isFromNotificationCenter", (void*)LDDUnreqFromNC,       "c@:"},
                    {"isRemote",                 (void*)LDDUnreqIsRemote,     "c@:"},
                    {"threadIdentifier",         (void*)LDDUnreqStr,          "@@:"},
                    {"requestIdentifier",        (void*)LDDUnreqNotifID,      "@@:"},
                    {"subSectionIdentifiers",    (void*)LDDUnreqArray,        "@@:"},
                    {"highestPrioritySubSectionIdentifier", (void*)LDDUnreqNil, "@@:"},
                    {"intentIdentifiers",        (void*)LDDUnreqArray,        "@@:"},
                    {"peopleIdentifiers",        (void*)LDDUnreqArray,        "@@:"},
                    {"parentSectionIdentifier",  (void*)LDDUnreqEmpty,        "@@:"},
                    {"timestamp",                (void*)LDDUnreqDate2,        "@@:"},
                    {"isUniqueThreadIdentifier", (void*)LDDUnreqFromNC,       "c@:"},
                    {"date",                     (void*)LDDUnreqDate2,        "@@:"},
                    {"subtitle",                 (void*)LDDUnreqEmpty,        "@@:"},
                    {"launchImageName",          (void*)LDDUnreqEmpty,        "@@:"},
                    {"categoryIdentifier",       (void*)LDDUnreqEmpty,        "@@:"},
                    {"summaryArgument",          (void*)LDDUnreqEmpty,        "@@:"},
                    {"targetContentIdentifier",  (void*)LDDUnreqNil,          "@@:"},
                    {"sound",                    (void*)LDDUnreqNil,          "@@:"},
                    {"badge",                    (void*)LDDUnreqNil,          "@@:"},
                    {"userInfo",                 (void*)LDDUnreqDict,         "@@:"},
                    {"isTransactional",          (void*)LDDUnreqFromNC,       "c@:"},
                    {"relevanceScore",           (void*)LDDUnreqZeroD,        "d@:"},
                    {"interruptionLevel",        (void*)LDDUnreqZeroQ,        "Q@:"},
                    {"summaryArgumentCount",     (void*)LDDUnreqZeroQ,        "Q@:"},
                    {"requestDestinations",       (void*)LDDUnreqZeroQ,        "Q@:"},
                    {"options",                   (void*)LDDUnreqZeroQ,        "Q@:"},
                    {"alertOptions",               (void*)LDDUnreqZeroQ,        "Q@:"},
                    // iOS17+ 私有 getter 一次性补齐 (id→nil / BOOL→NO / NSUInteger→0)
                    {"context",                    (void*)LDDUnreqNil,          "@@:"},
                    {"contentImage",               (void*)LDDUnreqNil,          "@@:"},
                    {"attachments",                (void*)LDDUnreqArray,        "@@:"},
                    {"associatedIconIdentifier",   (void*)LDDUnreqNil,          "@@:"},
                    {"shouldPreserveContent",      (void*)LDDUnreqFromNC,       "c@:"},
                    {"destinations",               (void*)LDDUnreqZeroQ,        "Q@:"},
                    {"shouldHideFromGroup",        (void*)LDDUnreqFromNC,       "c@:"},
                    {"settingsSections",           (void*)LDDUnreqArray,        "@@:"},
                };
                for (size_t i = 0; i < sizeof(patches)/sizeof(patches[0]); i++) {
                    SEL sSel = sel_registerName(patches[i].name);
                    if (!((BOOL(*)(id, SEL, SEL))objc_msgSend)((id)clsUNR, sel_registerName("respondsToSelector:"), sSel)) {
                        class_addMethod((Class)clsUNR, sSel, (IMP)patches[i].imp, patches[i].types);
                    }
                }
                ProbeWrite("RN-REQ-ADDSECTION");
                // 万能转发兜底: 未预知的 UNNotificationRequest 私有 getter 不再抛异常
                LDDInstallFwd(clsUNR);
            }
            id inst = ((id(*)(id, SEL))objc_msgSend)((id)clsReq, sel_registerName("alloc"));
            ProbeWrite(inst ? "RN-REQ-ALLOC-OK" : "RN-REQ-ALLOC-FAIL");
            // 2a. initWithNotificationRequest: (UN 层转系统层)。单独包 @try:
            // 该函数在 iOS16 内部会访问 UNNotificationRequest 的私有方法, 万一仍有缺失,
            // 异常在此捕获, 不中断后续 2b/2c 兜底。
            SEL sInitN = sel_registerName("initWithNotificationRequest:");
            @try {
                if (inst && unreq && ((BOOL(*)(id, SEL, SEL))objc_msgSend)(inst, sel_registerName("respondsToSelector:"), sInitN)) {
                    ProbeWrite("RN-REQ-INITN-TRY");
                    req = ((id(*)(id, SEL, id))objc_msgSend)(inst, sInitN, unreq);
                    if (req) ProbeWrite("RN-REQ-INITN-OK"); else ProbeWrite("RN-REQ-INITN-NIL");
                } else {
                    ProbeWrite(inst ? (unreq ? "RN-REQ-NOINITN" : "RN-REQ-NOUNREQ") : "RN-REQ-NOALLOC");
                }
            } @catch (id e) {
                LogReason("RN-INITN-EXC", e);
                req = nil;
            }
            // 2b. 兜底: alloc/init + setContentProvider
            if (!req && inst) {
                ProbeWrite("RN-REQ-FB-TRY");
                req = ((id(*)(id, SEL))objc_msgSend)(inst, sel_registerName("init"));
                id clsCP = (id)objc_getClass("NCNotificationRequestContentProvider");
                if (req && clsCP) {
                    id cpinst = ((id(*)(id, SEL))objc_msgSend)((id)clsCP, sel_registerName("alloc"));
                    id cp = nil;
                    // 依次尝试 ContentProvider 初始化方法
                    const char *cpInits[] = {"initWithObject:identifier:", "initWithNotificationRequest:", "initWithIdentifier:content:trigger:", 0};
                    for (int i = 0; cpInits[i] && !cp; i++) {
                        SEL sCPI = sel_registerName(cpInits[i]);
                        if (cpinst && ((BOOL(*)(id, SEL, SEL))objc_msgSend)(cpinst, sel_registerName("respondsToSelector:"), sCPI)) {
                            ProbeWrite(i == 0 ? "RN-REQ-CP-IOI" : "RN-REQ-CP-ALT");
                            if (i == 0) cp = ((id(*)(id, SEL, id, id))objc_msgSend)(cpinst, sCPI, (unreq ? (id)unreq : (id)content), uid);
                            else if (i == 1) cp = ((id(*)(id, SEL, id))objc_msgSend)(cpinst, sCPI, unreq);
                            else cp = ((id(*)(id, SEL, id, id, id))objc_msgSend)(cpinst, sCPI, uid, content, trigger);
                        }
                    }
                    if (cp) {
                        ProbeWrite("RN-REQ-CP-OK");
                        SEL sSetCP = sel_registerName("setContentProvider:");
                        if (((BOOL(*)(id, SEL, SEL))objc_msgSend)(req, sel_registerName("respondsToSelector:"), sSetCP)) {
                            ((void(*)(id, SEL, id))objc_msgSend)(req, sSetCP, cp);
                            ProbeWrite("RN-REQ-CP-SET");
                        } else ProbeWrite("RN-REQ-NOSETCP");
                    } else ProbeWrite("RN-REQ-CP-FAIL");
                } else {
                    ProbeWrite(req ? "RN-REQ-NOCP" : "RN-REQ-EMPTYINIT");
                }
                // 2c. 终极兜底: setter 填充关键字段 (identifier/sectionIdentifier/content)
                if (req) {
                    SEL sSetId = sel_registerName("setIdentifier:");
                    SEL sSetSec = sel_registerName("setSectionIdentifier:");
                    SEL sSetContent = sel_registerName("setContent:");
                    if (((BOOL(*)(id, SEL, SEL))objc_msgSend)(req, sel_registerName("respondsToSelector:"), sSetId))
                        ((void(*)(id, SEL, id))objc_msgSend)(req, sSetId, uid);
                    if (((BOOL(*)(id, SEL, SEL))objc_msgSend)(req, sel_registerName("respondsToSelector:"), sSetSec))
                        ((void(*)(id, SEL, id))objc_msgSend)(req, sSetSec, @"com.apple.MobileMail");
                    if (((BOOL(*)(id, SEL, SEL))objc_msgSend)(req, sel_registerName("respondsToSelector:"), sSetContent)) {
                        // 尝试构造 NCNotificationContent
                        id clsNCContent = (id)objc_getClass("NCNotificationContent");
                        if (clsNCContent) {
                            id ncInst = ((id(*)(id, SEL))objc_msgSend)((id)clsNCContent, sel_registerName("alloc"));
                            const char *ncInits[] = {"initWithNotificationRequest:", "initWithTitle:message:", "initWithTitle:message:body:", 0};
                            id ncContent = nil;
                            for (int j = 0; ncInits[j] && !ncContent; j++) {
                                SEL sNCI = sel_registerName(ncInits[j]);
                                if (ncInst && ((BOOL(*)(id, SEL, SEL))objc_msgSend)(ncInst, sel_registerName("respondsToSelector:"), sNCI)) {
                                    if (j == 0) ncContent = ((id(*)(id, SEL, id))objc_msgSend)(ncInst, sNCI, unreq);
                                    else if (j == 1) ncContent = ((id(*)(id, SEL, id, id))objc_msgSend)(ncInst, sNCI, @"灵动岛GIF背景", @"预览通知");
                                    else ncContent = ((id(*)(id, SEL, id, id, id))objc_msgSend)(ncInst, sNCI, @"灵动岛GIF背景", @"预览通知", @"岛展开显示您的背景");
                                }
                            }
                            if (ncContent) {
                                ((void(*)(id, SEL, id))objc_msgSend)(req, sSetContent, ncContent);
                                ProbeWrite("RN-REQ-SETCONTENT-OK");
                            } else ProbeWrite("RN-REQ-SETCONTENT-NOC");
                        } else ProbeWrite("RN-REQ-SETCONTENT-NOCLS");
                    }
                    ProbeWrite("RN-REQ-SETTERS-DONE");
                }
            }
        } else {
            ProbeWrite("RN-REQ-NOCLS");
        }
        if (req) ProbeWrite("RN-REQ-BUILT"); else ProbeWrite("RN-REQ-FAIL");

        // === 3. 找呈现层并投递 ===
        id layer = FindPresentLayer();
        if (layer) ProbeWrite("RN-PRES-FOUND"); else ProbeWrite("RN-PRES-NIL");
        if (req && layer) {
            // 3a. (已删除) 持久化标记 setPersistentNotificationAppBundleIdentifiers:
            // 曾导致一次投递被呈现层渲染成两条横幅(持久条目 + 普通横幅), 用户要求只显示一条。
            // 3b. 投递: postNotificationRequest: / prepareForIncomingNotificationRequest:
            // 优化14: postNotificationRequest: 内部会依次访问 UNNotificationContent 的一串私有
            // header 方法 (iOS16 缺失): customHeader -> defaultHeader -> topHeader -> hiddenPreviews...
            // 缺一个就抛 unrecognized selector -> post 失败 -> 回退自绘横幅。这里一次性批量补全
            // (全部返回 nil), 避免逐版本逐个补的来回迭代。
            id clsUNC = (id)objc_getClass("UNNotificationContent");
            if (clsUNC) {
                const char *contentSel[] = {
                    "customHeader", "defaultHeader", "topHeader",
                    "hiddenPreviewsHeaderPlaceholder",
                    "attributedCustomHeader", "attributedDefaultHeader", "attributedTopHeader",
                    // iOS17+ 私有 getter 一次性补齐 (id→nil)
                    "soundPath", "summaryText", "categorySummaryFormat",
                    "dateComponents", "alertSuppressionContext",
                    "contentImage", "icon", "headerIcon", "headerImage", "backgroundImage",
                    "attributedTitle", "attributedBody", "attributedSubtitle",
                    "attributedSummary",
                    "timeZone"
                };
                for (size_t ci = 0; ci < sizeof(contentSel)/sizeof(contentSel[0]); ci++) {
                    SEL sM = sel_registerName(contentSel[ci]);
                    if (!class_getInstanceMethod((Class)clsUNC, sM))
                        class_addMethod((Class)clsUNC, sM, (IMP)LDDUnreqNil, "@@:");
                }
                // isDateAllDay 是 BOOL 方法, 单独补 (返回 NO)
                SEL sD = sel_registerName("isDateAllDay");
                if (!class_getInstanceMethod((Class)clsUNC, sD))
                    class_addMethod((Class)clsUNC, sD, (IMP)LDDUnreqFromNC, "c@:");
                // 万能转发兜底: 未预知的 UNNotificationContent 私有 getter 不再抛异常
                LDDInstallFwd(clsUNC);
            }
            // 优化27: 统一走 postNotificationRequest: (1.9.95 起验证有效)
            // ISL-TRY2(presentModalBannerAndExpand) 1.9.116/1.9.121 已两次证死: 呈现后设置页卡死
            // post 呈现为 岛展开(第一条) + 标准横幅(第二条), 由 6 秒自动关闭阻断第二条
            SEL sPost = sel_registerName("postNotificationRequest:");
            if (((BOOL(*)(id, SEL, SEL))objc_msgSend)(layer, sel_registerName("respondsToSelector:"), sPost)) {
                ProbeWrite("RN-PRES-TRYPOST");
                gLastReq = req;
                ((void(*)(id, SEL, id))objc_msgSend)(layer, sPost, req);
                ProbeWrite("RN-PRES-SENT");
                LDDCloseAfter(6.0);
                return;
            }
            ProbeWrite("RN-PRES-NOMETHOD");
        }
        ProbeWrite("RN-ALL-FAIL");
    } @catch (id e) { LogReason("RN-EXC", e); }
}


__attribute__((constructor))
static void LDDInit(void) {
    ProbeWrite("LDD-BUILD actions-1.9.123-dblclose");
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
    // 捕获横幅呈现层 (SBNotificationBannerDestination init)
    id clsBND = objc_getClass("SBNotificationBannerDestination");
    if (clsBND) { MSHookMessageEx((Class)clsBND, sel_registerName("init"), (IMP)HookBNDInit, (IMP *)&origBNDInit); ProbeWrite("BND-HOOK"); }
    // Darwin notify: 设置端点"预览通知"即时触发 (灵动通知同款机制)
    static int notifyTok = 0;
    notify_register_dispatch("com.tlzypjy.github/TestNotification", &notifyTok, (void *)&_dispatch_main_q, ^(int tok){
        PostRealNotification();
    });
    // 触发文件独立轮询: 与布局无关, 点预览后 0.1s 内即弹
    StartForceMonitor();
    // 灵动岛 hook 由 CtrlLayoutHook 延迟补挂 (避免构造时机过早)
}
