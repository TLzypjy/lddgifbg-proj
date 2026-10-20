// 灵动岛GIF背景 —— 重制版主插件 (1:1 复刻原行为 + 视频素材支持)
// Objective-C++ + MRC, 无 SDK 无头文件, 全部运行时动态解析
// 行为复刻:
//   prefs suite "lddgifbg": Enablelddgifbg / Enablezxhlddgifbg / lddgifbgScale / SelectedMaterialFolder
//   主开关关时: 小岛开 或 island 高度>=65 仍显示
//   素材目录 /var/mobile/lddgifbg/<文件夹>/, 选择 gif > 视频(mp4/mov) > 静态(png/jpg)
//   tag=9999 视图, contentMode=ScaleAspectFill, autoresizing=FlexibleWidth|FlexibleHeight
//   居中缩放 frame=((W-w)/2,(H-h)/2,w,h), w=W*scale h=H*scale, scale<=0 -> 1.0
//   GIF: ImageIO 逐帧 -> animationImages, 默认帧延迟0.1s, frames/duration 缓存
//   视频: AVPlayer + AVPlayerLayer (AspectFill, 静音, 循环) — 动态 dlopen, 无硬链接

#include <stdint.h>
#include <stddef.h>

typedef struct objc_class *Class;
typedef struct objc_object { Class isa; } *id;
typedef struct objc_selector *SEL;
typedef void *IMP;
typedef struct CGImage *CGImageRef;
typedef unsigned char BOOL;
typedef unsigned long NSUInteger;
#define YES 1
#define NO 0
#define nil 0
#define Nil 0

extern "C" id objc_msgSend(id self, SEL op, ...);
extern "C" id objc_getClass(const char *name);
extern "C" SEL sel_registerName(const char *name);
extern "C" void *dlopen(const char *path, int mode);
extern "C" void MSHookMessageEx(Class _class, SEL _sel, IMP _replacement, IMP *_result);
extern "C" void *objc_autoreleasePoolPush(void);
extern "C" void objc_autoreleasePoolPop(void *pool);

extern "C" CGImageRef CGImageSourceCreateImageAtIndex(void *src, size_t idx, void *opts);
extern "C" size_t CGImageSourceGetCount(void *src);
extern "C" void *CGImageSourceCreateWithData(void *data, void *opts);
extern "C" void *CGImageSourceCopyPropertiesAtIndex(void *src, size_t idx, void *opts);
extern "C" void CFRelease(void *cf);
extern "C" { extern void *kCGImagePropertyGIFDictionary; extern void *kCGImagePropertyGIFDelayTime; extern void *kCGImagePropertyGIFUnclampedDelayTime; }

// ---------- ObjC 存根 (仅声明) ----------
@interface NSObject
+ (id)alloc;
- (id)init;
@end
@interface NSString : NSObject
- (NSString *)stringByAppendingPathComponent:(NSString *)str;
- (NSString *)pathExtension;
- (NSString *)lowercaseString;
@end
@interface NSDictionary : NSObject
- (id)objectForKeyedSubscript:(id)key;
@end
@interface NSMutableDictionary : NSDictionary
+ (id)dictionary;
- (void)setObject:(id)obj forKeyedSubscript:(id)key;
@end
@interface NSArray : NSObject
- (unsigned long)count;
@end
@interface NSMutableArray : NSArray
+ (id)arrayWithCapacity:(unsigned long)num;
- (void)addObject:(id)obj;
@end
@interface NSData : NSObject
+ (id)dataWithContentsOfFile:(NSString *)path;
@end
@interface NSNumber : NSObject
+ (id)numberWithDouble:(double)d;
@end
@interface NSFileManager : NSObject
+ (id)defaultManager;
@end
@interface NSUserDefaults : NSObject
- (id)initWithSuiteName:(NSString *)name;
- (id)objectForKey:(NSString *)key;
@end
@interface NSNotificationCenter : NSObject
+ (id)defaultCenter;
- (void)addObserver:(id)obs selector:(SEL)sel name:(NSString *)name object:(id)obj;
@end
@interface NSURL : NSObject
+ (id)fileURLWithPath:(NSString *)path;
@end

typedef struct CGRect { double ox, oy, w, h; } CGRect;

@interface UIView : NSObject
- (CGRect)bounds;
- (void)setFrame:(CGRect)r;
- (void)insertSubview:(id)view atIndex:(long)index;
- (void)removeFromSuperview;
- (id)viewWithTag:(long)tag;
- (id)layer;
@end
@interface UIImage : NSObject
+ (id)imageWithContentsOfFile:(NSString *)path;
+ (id)imageWithCGImage:(CGImageRef)cg scale:(double)scale orientation:(long)orientation;
@end
@interface UIImageView : UIView
- (id)initWithFrame:(CGRect)r;
- (void)setImage:(id)img;
- (void)setAnimationImages:(id)images;
- (void)setAnimationDuration:(double)d;
- (void)setAnimationRepeatCount:(long)n;
- (void)startAnimating;
- (void)stopAnimating;
- (void)setContentMode:(long)mode;
- (void)setAutoresizingMask:(unsigned long)mask;
- (void)setTag:(long)tag;
@end
@interface CALayer : NSObject
- (void)addSublayer:(id)layer;
- (void)removeFromSuperlayer;
- (void)setFrame:(CGRect)r;
@end

// ---------- 类型安全调用宏 ----------
static SEL S(const char *s) { return sel_registerName(s); }
#define MSG(recv, sel, ...)  objc_msgSend((id)(recv), S(sel) __VA_OPT__(,) __VA_ARGS__)
#define MSGB(recv, sel, ...) ((BOOL(*)(id, SEL, ...))objc_msgSend)((id)(recv), S(sel) __VA_OPT__(,) __VA_ARGS__)
#define MSGD(recv, sel, ...) ((double(*)(id, SEL, ...))objc_msgSend)((id)(recv), S(sel) __VA_OPT__(,) __VA_ARGS__)
#define MSGR(recv, sel)      ((CGRect(*)(id, SEL))objc_msgSend)((id)(recv), S(sel))
#define CLS(n) objc_getClass(n)

// ---------- 全局 ----------
static NSString *gPrefsKeyEnable, *gPrefsKeyZxh, *gPrefsKeyScale, *gPrefsKeyFolder;
static NSString *gRootDir, *gGifExt, *gVideoExtMp4, *gVideoExtMov;
static NSString *gLoadedPath;
static id gPlayer, gPlayerItem, gPlayerLayer, gObserver;
static id gFramesCache, gDurationCache;
static void (*origLayoutSubviews)(id, SEL);

struct CMTimeRaw { long long value; int timescale; unsigned flags; long long epoch; };

// ---------- 视频循环观察者 ----------
@interface LDDVideoLoopObserver : NSObject
- (void)videoDidEnd:(id)n;
@end
@implementation LDDVideoLoopObserver
- (void)videoDidEnd:(id)n {
    if (gPlayer) {
        struct CMTimeRaw zero = {0, 0, 0, 0};
        ((id(*)(id, SEL, struct CMTimeRaw))objc_msgSend)(gPlayer, S("seekToTime:"), zero);
        MSG(gPlayer, "play");
    }
}
@end

// ---------- prefs ----------
static id LoadPrefs(void) {
    id ud = MSG(CLS("NSUserDefaults"), "alloc");
    return MSG(ud, "initWithSuiteName:", @"lddgifbg");
}
static id NSString_fromCStr(const char *s) {
    return MSG(CLS("NSString"), "stringWithUTF8String:", s);
}
// RootHide 下 NSUserDefaults 可能与原版直接读的 plist 文件不同步, 做多路径兜底
static id LoadPrefsValue(NSString *key) {
    id v = MSG(LoadPrefs(), "objectForKey:", key);
    if (v) return v;
    const char *paths[] = {
        "/var/jb/User/Library/Preferences/lddgifbg.plist",
        "/var/mobile/Library/Preferences/lddgifbg.plist",
        "@P@/var/jb/User/Library/Preferences/lddgifbg.plist",
        0
    };
    for (int i = 0; paths[i]; i++) {
        id d = MSG(CLS("NSDictionary"), "dictionaryWithContentsOfFile:", NSString_fromCStr(paths[i]));
        if (d) {
            id x = MSG(d, "objectForKey:", key);
            if (x) return x;
        }
    }
    return nil;
}
static BOOL IsLddGifBgEnabled(void) {
    id v = LoadPrefsValue(gPrefsKeyEnable);
    return v ? MSGB(v, "boolValue") : YES;
}
static BOOL IsZxhLddGifBgEnabled(void) {
    id v = LoadPrefsValue(gPrefsKeyZxh);
    return v ? MSGB(v, "boolValue") : YES;
}
static double GetLddGifBgScale(void) {
    id v = LoadPrefsValue(gPrefsKeyScale);
    if (!v) return 1.0;
    double d = MSGD(v, "doubleValue");
    return d > 0 ? d : 1.0;
}

// ---------- 素材文件选择 (gif > 视频 > 静态图) ----------
static NSString *GetSelectedImagePath(void) {
    id name = LoadPrefsValue(gPrefsKeyFolder);
    if (!name) return nil;
    NSString *folder = (NSString *)MSG(gRootDir, "stringByAppendingPathComponent:", name);
    BOOL isDir = NO;
    id fm = MSG(CLS("NSFileManager"), "defaultManager");
    if (!MSGB(fm, "fileExistsAtPath:isDirectory:", folder, &isDir) || !isDir) return nil;
    id files = MSG(fm, "contentsOfDirectoryAtPath:error:", folder, nil);
    if (!files) return nil;
    NSString *videoPick = nil, *imgPick = nil;
    for (id f in files) {
        id ext = MSG(MSG(f, "pathExtension"), "lowercaseString");
        if (MSGB(ext, "isEqualToString:", gGifExt))
            return (NSString *)MSG(folder, "stringByAppendingPathComponent:", f);
        if (MSGB(ext, "isEqualToString:", gVideoExtMp4) || MSGB(ext, "isEqualToString:", gVideoExtMov))
            if (!videoPick) videoPick = (NSString *)MSG(folder, "stringByAppendingPathComponent:", f);
        if (MSGB(ext, "isEqualToString:", @"png") || MSGB(ext, "isEqualToString:", @"jpg") || MSGB(ext, "isEqualToString:", @"jpeg"))
            if (!imgPick) imgPick = (NSString *)MSG(folder, "stringByAppendingPathComponent:", f);
    }
    return videoPick ? videoPick : imgPick;
}

// ---------- GIF 载入 ----------
static void LoadGIFWithPathIntoImageView(NSString *path, UIImageView *iv) {
    if (!path || !iv) return;
    id frames = MSG(gFramesCache, "objectForKeyedSubscript:", path);
    id durObj = MSG(gDurationCache, "objectForKeyedSubscript:", path);
    if (frames && durObj) {
        MSG(iv, "setAnimationImages:", frames);
        MSG(iv, "setAnimationDuration:", MSGD(durObj, "doubleValue"));
        MSG(iv, "setAnimationRepeatCount:", 0);
        MSG(iv, "startAnimating");
        return;
    }
    id data = MSG(CLS("NSData"), "dataWithContentsOfFile:", path);
    if (!data) return;
    void *src = CGImageSourceCreateWithData((void *)data, 0);
    if (!src) return;
    size_t count = CGImageSourceGetCount(src);
    if (count == 0) { CFRelease(src); return; }
    id arr = MSG(CLS("NSMutableArray"), "arrayWithCapacity:", (unsigned long)count);
    double total = 0.0;
    for (size_t i = 0; i < count; i++) {
        CGImageRef cg = CGImageSourceCreateImageAtIndex(src, i, 0);
        if (!cg) continue;
        void *props = CGImageSourceCopyPropertiesAtIndex(src, i, 0);
        id img = MSG(CLS("UIImage"), "imageWithCGImage:scale:orientation:", (void *)cg, 1.0, 0);
        MSG(arr, "addObject:", img);
        double delay = 0.1;
        if (props) {
            id gd = MSG((id)props, "objectForKeyedSubscript:", (id)kCGImagePropertyGIFDictionary);
            if (gd) {
                id d1 = MSG(gd, "objectForKeyedSubscript:", (id)kCGImagePropertyGIFUnclampedDelayTime);
                id d2 = MSG(gd, "objectForKeyedSubscript:", (id)kCGImagePropertyGIFDelayTime);
                double dd = 0.0;
                if (d1) dd = MSGD(d1, "doubleValue");
                if (dd <= 0 && d2) dd = MSGD(d2, "doubleValue");
                if (dd > 0) delay = dd;
            }
            CFRelease(props);
        }
        total += delay;
        CFRelease((void *)cg);
    }
    CFRelease(src);
    MSG(gFramesCache, "setObject:forKeyedSubscript:", arr, path);
    id dur = MSG(CLS("NSNumber"), "numberWithDouble:", total);
    MSG(gDurationCache, "setObject:forKeyedSubscript:", dur, path);
    MSG(iv, "setAnimationImages:", arr);
    MSG(iv, "setAnimationDuration:", total);
    MSG(iv, "setAnimationRepeatCount:", 0);
    MSG(iv, "startAnimating");
}

// ---------- 视频载入 ----------
static void EnsureAVFoundation(void) {
    static int done = 0;
    if (!done) { dlopen("/System/Library/Frameworks/AVFoundation.framework/AVFoundation", 2); done = 1; }
}
static void LoadVideoWithPathIntoView(NSString *path, UIView *view) {
    EnsureAVFoundation();
    id url = MSG(CLS("NSURL"), "fileURLWithPath:", path);
    if (gPlayer && gPlayerItem) {
        MSG(gPlayer, "replaceCurrentItemWithPlayerItem:", MSG(CLS("AVPlayerItem"), "playerItemWithURL:", url));
    } else {
        gPlayerItem = MSG(CLS("AVPlayerItem"), "playerItemWithURL:", url);
        gPlayer = MSG(CLS("AVPlayer"), "playerWithPlayerItem:", gPlayerItem);
        MSG(gPlayer, "setMuted:", 1);
        gPlayerLayer = MSG(CLS("AVPlayerLayer"), "playerLayerWithPlayer:", gPlayer);
        MSG(gPlayerLayer, "setVideoGravity:", @"AVLayerVideoGravityResizeAspectFill");
        gObserver = (id)[[LDDVideoLoopObserver alloc] init];
        id nc = MSG(CLS("NSNotificationCenter"), "defaultCenter");
        MSG(nc, "addObserver:selector:name:object:", gObserver, S("videoDidEnd:"), @"AVPlayerItemDidPlayToEndTimeNotification", gPlayerItem);
    }
    CGRect b = MSGR(view, "bounds");
    MSG(gPlayerLayer, "setFrame:", b);
    MSG(MSG(view, "layer"), "addSublayer:", gPlayerLayer);
    MSG(gPlayer, "play");
}
static void StopVideo(void) {
    if (gPlayer) MSG(gPlayer, "pause");
    if (gPlayerLayer) MSG(gPlayerLayer, "removeFromSuperlayer");
}

// ---------- 素材分发 ----------
static void LoadMediaWithPathIntoImageView(NSString *path, UIImageView *iv) {
    id ext = MSG(MSG(path, "pathExtension"), "lowercaseString");
    if (MSGB(ext, "isEqualToString:", gGifExt)) {
        StopVideo();
        MSG(iv, "setImage:", nil);
        MSG(iv, "setAnimationImages:", nil);
        LoadGIFWithPathIntoImageView(path, iv);
    } else if (MSGB(ext, "isEqualToString:", gVideoExtMp4) || MSGB(ext, "isEqualToString:", gVideoExtMov)) {
        MSG(iv, "stopAnimating");
        MSG(iv, "setImage:", nil);
        MSG(iv, "setAnimationImages:", nil);
        LoadVideoWithPathIntoView(path, iv);
    } else {
        StopVideo();
        MSG(iv, "stopAnimating");
        MSG(iv, "setImage:", MSG(CLS("UIImage"), "imageWithContentsOfFile:", path));
    }
}

// ---------- 占位方块 (诊断用: 插件活着但无素材时会显示) ----------
static void RemovePlaceholder(id self) {
    id ph = MSG(self, "viewWithTag:", 9998);
    if (ph) MSG(ph, "removeFromSuperview");
}
static void ShowPlaceholder(id self) {
    RemovePlaceholder(self);
    id v = MSG(self, "viewWithTag:", 9999);
    if (v) MSG(v, "removeFromSuperview");
    id ph = MSG(self, "viewWithTag:", 9998);
    if (!ph) {
        CGRect b = MSGR(self, "bounds");
        ph = MSG(MSG(CLS("UIView"), "alloc"), "initWithFrame:", (CGRect){ b.w / 2.0 - 15, b.h / 2.0 - 20, 30, 40 });
        MSG(ph, "setBackgroundColor:", MSG(CLS("UIColor"), "redColor"));
        MSG(ph, "setTag:", 9998);
        MSG(self, "insertSubview:atIndex:", ph, 0);
    }
}

// ---------- layoutSubviews hook ----------
static void LDDNewLayoutSubviews(id self, SEL _cmd) {
    origLayoutSubviews(self, _cmd);
    void *pool = objc_autoreleasePoolPush();

    BOOL show = IsLddGifBgEnabled();
    if (!show && IsZxhLddGifBgEnabled()) show = YES;
    if (!show) {
        CGRect b = MSGR(self, "bounds");
        if (b.h >= 65.0) show = YES;
    }
    if (!show) {
        id v = MSG(self, "viewWithTag:", 9999);
        if (v) MSG(v, "removeFromSuperview");
        RemovePlaceholder(self);
        objc_autoreleasePoolPop(pool);
        return;
    }

    NSString *path = (NSString *)GetSelectedImagePath();
    if (!path) {
        ShowPlaceholder(self);
        objc_autoreleasePoolPop(pool);
        return;
    }
    id fm = MSG(CLS("NSFileManager"), "defaultManager");
    if (!MSGB(fm, "fileExistsAtPath:", path)) {
        ShowPlaceholder(self);
        objc_autoreleasePoolPop(pool);
        return;
    }
    RemovePlaceholder(self);

    UIImageView *view = (UIImageView *)MSG(self, "viewWithTag:", 9999);
    if (!view) {
        CGRect b = MSGR(self, "bounds");
        view = (UIImageView *)MSG(MSG(CLS("UIImageView"), "alloc"), "initWithFrame:", (CGRect){0, 0, b.w, b.h});
        MSG(view, "setContentMode:", 2);
        MSG(view, "setAutoresizingMask:", 18);
        MSG(view, "setTag:", 9999);
        MSG(self, "insertSubview:atIndex:", view, 0);
    }

    double scale = GetLddGifBgScale();
    CGRect b = MSGR(self, "bounds");
    double w = b.w * scale, h = b.h * scale;
    MSG(view, "setFrame:", (CGRect){ (b.w - w) / 2.0, (b.h - h) / 2.0, w, h });

    BOOL needReload = YES;
    if (gLoadedPath && MSGB(gLoadedPath, "isEqualToString:", path)) {
        if (MSGB(view, "isAnimating") || gPlayerLayer) needReload = NO;
    }
    if (needReload) {
        gLoadedPath = path;
        LoadMediaWithPathIntoImageView(path, view);
    }
    MSG(self, "insertSubview:atIndex:", view, 0);
    objc_autoreleasePoolPop(pool);
}

// ---------- 构造 ----------
__attribute__((constructor))
static void LDDInit(void) {
    gPrefsKeyEnable = @"Enablelddgifbg";
    gPrefsKeyZxh = @"Enablezxhlddgifbg";
    gPrefsKeyScale = @"lddgifbgScale";
    gPrefsKeyFolder = @"SelectedMaterialFolder";
    gRootDir = @"/var/mobile/lddgifbg";
    gGifExt = @"gif";
    gVideoExtMp4 = @"mp4";
    gVideoExtMov = @"mov";
    gFramesCache = MSG(CLS("NSMutableDictionary"), "dictionary");
    gDurationCache = MSG(CLS("NSMutableDictionary"), "dictionary");
    Class cls = (Class)objc_getClass("SBSystemApertureContainerViewContentView");
    if (cls) {
        MSHookMessageEx(cls, S("layoutSubviews"), (IMP)LDDNewLayoutSubviews, (IMP *)&origLayoutSubviews);
    }
}