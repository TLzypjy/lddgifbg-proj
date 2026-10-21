// 灵动岛GIF背景 —— 重制版设置 Bundle (v3: 全标准 ObjC 语法, 适配 arm64e)
// 架构: 入口壳(PSListController) -> 模态面板(UITableViewController 自绘) -> 素材选择器(模态)
// 关键: 全部使用 [obj method:] 标准语法, 由编译器生成 arm64e 正确的 objc_msgSend
#include <stdio.h>

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

extern id objc_msgSend(id self, SEL op, ...);
extern id objc_getClass(const char *name);
extern SEL sel_registerName(const char *name);
extern void *dlopen(const char *path, int mode);
extern void *dlsym(void *handle, const char *symbol);
extern void CFRelease(void *cf);

#define CLS(n) objc_getClass(n)
static id CLSSTR(const char *n) { return (id)objc_getClass(n); }

// ---------- ObjC 存根 (标准声明, 供编译期检查) ----------
@interface NSObject
+ (id)alloc;
- (id)init;
- (id)valueForKey:(id)k;
- (void)setValue:(id)v forKey:(id)k;
@end
@interface NSString : NSObject
- (NSString *)stringByAppendingPathComponent:(NSString *)s;
- (NSString *)pathExtension;
- (NSString *)lowercaseString;
- (BOOL)isEqualToString:(NSString *)s;
@end
@interface NSArray : NSObject
+ (id)array;
- (NSUInteger)count;
- (id)objectAtIndex:(NSUInteger)i;
- (id)mutableCopy;
- (NSUInteger)countByEnumeratingWithState:(void *)state objects:(id *)buf count:(NSUInteger)len;
@end
@interface NSMutableArray : NSArray
+ (id)array;
- (void)addObject:(id)obj;
@end
@interface NSDictionary : NSObject
+ (id)dictionary;
- (id)objectForKeyedSubscript:(id)k;
@end
@interface NSMutableDictionary : NSDictionary
+ (id)dictionary;
- (void)setObject:(id)obj forKeyedSubscript:(id)k;
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
- (void)setObject:(id)obj forKey:(id)k;
- (BOOL)synchronize;
@end
@interface NSURL : NSObject
+ (id)fileURLWithPath:(NSString *)p;
@end
@interface NSIndexPath : NSObject
- (NSInteger)row;
@end
@interface NSException : NSObject @end

typedef struct CGRect { double ox, oy, w, h; } CGRect;
typedef struct CGSize { double w, h; } CGSize;
static CGRect MakeRect(double x, double y, double w, double h) { CGRect r = {x, y, w, h}; return r; }

@interface UIColor : NSObject
+ (id)clearColor;
+ (id)redColor;
@end
@interface UIFont : NSObject
+ (id)systemFontOfSize:(double)s;
+ (id)boldSystemFontOfSize:(double)s;
@end
@interface UIView : NSObject
- (id)initWithFrame:(CGRect)r;
- (CGRect)bounds;
- (void)setFrame:(CGRect)r;
- (void)addSubview:(id)v;
- (void)removeFromSuperview;
- (void)setBackgroundColor:(id)c;
- (id)subviews;
- (id)layer;
- (void)setContentMode:(NSInteger)m;
- (void)setClipsToBounds:(BOOL)b;
@end
@interface UILabel : UIView
- (id)initWithFrame:(CGRect)r;
- (void)setText:(NSString *)t;
- (void)setFont:(id)f;
- (void)setTextColor:(id)c;
- (void)setTextAlignment:(NSInteger)a;
@end
@interface UIImage : NSObject
+ (id)imageWithContentsOfFile:(NSString *)p;
+ (id)imageWithCGImage:(CGImageRef)cg scale:(double)s orientation:(NSInteger)o;
@end
@interface UIImageView : UIView
- (id)initWithFrame:(CGRect)r;
- (void)setImage:(id)img;
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
- (void)setMinimumValue:(double)m;
- (void)setMaximumValue:(double)m;
- (void)setValue:(double)v;
- (double)value;
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
- (id)initWithNibName:(id)n bundle:(id)b;
- (id)view;
- (void)setTitle:(NSString *)t;
- (void)viewDidLoad;
- (void)viewDidAppear:(BOOL)a;
- (void)presentViewController:(id)vc animated:(BOOL)a completion:(id)c;
- (void)dismissViewControllerAnimated:(BOOL)a completion:(id)c;
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
@interface UIApplication : NSObject
+ (id)sharedApplication;
- (BOOL)canOpenURL:(id)url;
- (void)openURL:(id)url options:(id)opts completionHandler:(id)handler;
@end
@interface NSTimer : NSObject
+ (id)scheduledTimerWithTimeInterval:(double)t target:(id)target selector:(SEL)s userInfo:(id)info repeats:(BOOL)r;
@end
@interface CALayer : NSObject
- (void)setCornerRadius:(double)r;
- (void)setMasksToBounds:(BOOL)b;
@end
@interface PSListController : UIViewController
- (id)loadSpecifiersFromPlistName:(NSString *)n target:(id)t;
- (id)specifiers;
@end
@interface NSBundle : NSObject
+ (id)mainBundle;
- (NSString *)pathForResource:(NSString *)n ofType:(NSString *)t;
@end

// ---------- 素材缩略图 ----------
static void *gImageIO = NULL;
static void *gAVF = NULL;
static void *fnCGSrcCreate = NULL, *fnCGSrcImg = NULL;
static void EnsureLibs(void) {
    if (!gImageIO) {
        gImageIO = dlopen("/System/Library/Frameworks/ImageIO.framework/ImageIO", 2);
        if (gImageIO) {
            fnCGSrcCreate = dlsym(gImageIO, "CGImageSourceCreateWithData");
            fnCGSrcImg = dlsym(gImageIO, "CGImageSourceCreateImageAtIndex");
        }
    }
    if (!gAVF) gAVF = dlopen("/System/Library/Frameworks/AVFoundation.framework/AVFoundation", 2);
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

// ---------- 素材选择器 ----------
@interface LDDMaterialPickerController : UITableViewController
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv;
- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)s;
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)ip;
- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)ip;
@end
@implementation LDDMaterialPickerController
{
    id _folders;
    id _thumbs;
    NSString *_sel;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"选择素材"];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir = NO;
    _folders = nil;
    if ([fm fileExistsAtPath:@"/var/mobile/lddgifbg" isDirectory:&isDir] && isDir) {
        _folders = [fm contentsOfDirectoryAtPath:@"/var/mobile/lddgifbg" error:nil];
    }
    _thumbs = [NSMutableDictionary dictionary];
    NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
    _sel = [ud objectForKey:@"SelectedMaterialFolder"];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv { return 1; }
- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)s {
    return _folders ? (NSInteger)[_folders count] : 0;
}
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)ip {
    NSInteger row = [ip row];
    if (!_folders || row >= (NSInteger)[_folders count]) return nil;
    NSString *name = [_folders objectAtIndex:(NSUInteger)row];
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"mat"];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:1 reuseIdentifier:@"mat"];
    for (UIView *v in [[cell contentView] subviews]) { if (v) [v removeFromSuperview]; }

    NSString *full = [@"/var/mobile/lddgifbg" stringByAppendingPathComponent:name];
    UIImage *thumb = [_thumbs objectForKeyedSubscript:name];
    if (!thumb) {
        NSFileManager *fm = [NSFileManager defaultManager];
        NSArray *files = [fm contentsOfDirectoryAtPath:full error:nil];
        for (NSString *f in files) {
            NSString *ext = [[f pathExtension] lowercaseString];
            if ([ext isEqualToString:@"gif"] || [ext isEqualToString:@"mp4"] || [ext isEqualToString:@"mov"] ||
                [ext isEqualToString:@"png"] || [ext isEqualToString:@"jpg"] || [ext isEqualToString:@"jpeg"]) {
                NSString *media = [full stringByAppendingPathComponent:f];
                thumb = ThumbForPath(media);
                break;
            }
        }
        if (thumb) [_thumbs setObject:thumb forKeyedSubscript:name];
    }
    if (thumb) {
        UIImageView *iv = [[UIImageView alloc] initWithFrame:MakeRect(8, 8, 44, 44)];
        [iv setImage:thumb];
        [iv setContentMode:1];
        [iv setClipsToBounds:YES];
        [[iv layer] setCornerRadius:6.0];
        [[iv layer] setMasksToBounds:YES];
        [[cell contentView] addSubview:iv];
    }
    CGRect b = [[cell contentView] bounds];
    UILabel *label = [[UILabel alloc] initWithFrame:MakeRect(60, 10, b.w - 70, 22)];
    [label setText:name];
    [label setFont:[UIFont boldSystemFontOfSize:16.0]];
    [[cell contentView] addSubview:label];
    UILabel *sub = [[UILabel alloc] initWithFrame:MakeRect(60, 33, b.w - 70, 16)];
    NSString *typeDesc = @"GIF";
    NSFileManager *fm2 = [NSFileManager defaultManager];
    NSArray *files2 = [fm2 contentsOfDirectoryAtPath:full error:nil];
    for (NSString *f in files2) {
        NSString *ext = [[f pathExtension] lowercaseString];
        if ([ext isEqualToString:@"mp4"] || [ext isEqualToString:@"mov"]) { typeDesc = @"视频"; break; }
        if ([ext isEqualToString:@"png"] || [ext isEqualToString:@"jpg"] || [ext isEqualToString:@"jpeg"]) typeDesc = @"静态图";
    }
    [sub setText:typeDesc];
    [sub setFont:[UIFont systemFontOfSize:12.0]];
    [[cell contentView] addSubview:sub];
    if (_sel && [_sel isEqualToString:name]) [cell setAccessoryType:3];
    else [cell setAccessoryType:0];
    return cell;
}
- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)ip {
    NSInteger row = [ip row];
    if (!_folders || row >= (NSInteger)[_folders count]) return;
    NSString *name = [_folders objectAtIndex:(NSUInteger)row];
    NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
    [ud setObject:name forKey:@"SelectedMaterialFolder"];
    [ud synchronize];
    [self dismissViewControllerAnimated:YES completion:0];
}
@end

// ---------- 模态设置面板 ----------
@interface LDDMainSettingsController : UITableViewController
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv;
- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)s;
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)ip;
- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)ip;
@end
@implementation LDDMainSettingsController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"灵动岛GIF背景"];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv { return 1; }
- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)s { return 6; }
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)ip {
    NSInteger row = [ip row];
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"c"];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:1 reuseIdentifier:@"c"];
    for (UIView *v in [[cell contentView] subviews]) { if (v) [v removeFromSuperview]; }
    CGRect b = [[cell contentView] bounds];
    [cell setSelectionStyle:0];
    [cell setAccessoryType:0];
    if (row == 0 || row == 1) {
        UILabel *label = [[UILabel alloc] initWithFrame:MakeRect(16, 14, b.w - 110, 22)];
        [label setText:(row == 0 ? @"启用总开关" : @"启用小岛")];
        [label setFont:[UIFont systemFontOfSize:16.0]];
        [[cell contentView] addSubview:label];
        UISwitch *sw = [[UISwitch alloc] initWithFrame:MakeRect(b.w - 66, 9, 50, 30)];
        [sw setTag:(row == 0 ? 1001 : 1002)];
        NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
        id v = [ud objectForKey:(row == 0 ? @"Enablelddgifbg" : @"Enablezxhlddgifbg")];
        BOOL on = v ? [v boolValue] : YES;
        [sw setOn:on animated:NO];
        [sw addTarget:(id)self action:@selector(switchToggled:) forControlEvents:1 << 12];
        [[cell contentView] addSubview:sw];
    } else if (row == 2) {
        UILabel *label = [[UILabel alloc] initWithFrame:MakeRect(16, 10, b.w - 32, 20)];
        [label setText:@"缩放比例"];
        [label setFont:[UIFont systemFontOfSize:15.0]];
        [[cell contentView] addSubview:label];
        UISlider *sl = [[UISlider alloc] initWithFrame:MakeRect(16, 34, b.w - 32, 30)];
        [sl setMinimumValue:0.1];
        [sl setMaximumValue:2.0];
        NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
        id v = [ud objectForKey:@"lddgifbgScale"];
        double dv = v ? [v doubleValue] : 1.0;
        if (dv <= 0) dv = 1.0;
        [sl setValue:dv];
        [sl addTarget:(id)self action:@selector(sliderChanged:) forControlEvents:1 << 12];
        [[cell contentView] addSubview:sl];
    } else {
        NSString *t = (row == 3 ? @"选择素材" : (row == 4 ? @"跳转素材目录" : @"完成"));
        UILabel *label = [[UILabel alloc] initWithFrame:MakeRect(16, 14, b.w - 60, 22)];
        [label setText:t];
        [label setFont:[UIFont systemFontOfSize:16.0]];
        if (row == 5) [label setTextColor:[UIColor redColor]];
        [[cell contentView] addSubview:label];
        [cell setSelectionStyle:1];
    }
    return cell;
}
- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)ip {
    NSInteger row = [ip row];
    [tv deselectRowAtIndexPath:ip animated:YES];
    if (row == 3) {
        LDDMaterialPickerController *pc = [[LDDMaterialPickerController alloc] initWithStyle:1];
        [self presentViewController:pc animated:YES completion:0];
    } else if (row == 4) {
        UIApplication *app = [UIApplication sharedApplication];
        NSURL *url = [NSURL fileURLWithPath:@"/var/mobile/lddgifbg"];
        [app openURL:url options:[NSDictionary dictionary] completionHandler:0];
    } else if (row == 5) {
        [self dismissViewControllerAnimated:YES completion:0];
    }
}
- (void)switchToggled:(UISwitch *)sw {
    NSString *key = ([sw tag] == 1001 ? @"Enablelddgifbg" : @"Enablezxhlddgifbg");
    BOOL on = [sw isOn];
    NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
    [ud setObject:[NSNumber numberWithBool:on] forKey:key];
    [ud synchronize];
}
- (void)sliderChanged:(UISlider *)sl {
    double dv = [sl value];
    NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
    [ud setObject:[NSNumber numberWithDouble:dv] forKey:@"lddgifbgScale"];
    [ud synchronize];
}
@end

// ---------- 入口壳 ----------
@interface lddgifbgRootListController : PSListController
@end
@implementation lddgifbgRootListController
- (void)viewDidLoad {
    @try { [super viewDidLoad]; } @catch (id e) {}
    [self setTitle:@"灵动岛GIF背景"];
}
- (void)viewDidAppear:(BOOL)a {
    [super viewDidAppear:1];
    static int shown = 0;
    if (!shown) {
        shown = 1;
        [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(showPanel:) userInfo:0 repeats:NO];
    }
}
- (void)showPanel:(id)t {
    LDDMainSettingsController *panel = [[LDDMainSettingsController alloc] initWithStyle:1];
    [self presentViewController:panel animated:YES completion:0];
}
- (id)specifiers {
    @try { return [self loadSpecifiersFromPlistName:@"Root" target:self]; }
    @catch (id e) { return [NSArray array]; }
}
@end