// 灵动岛GIF背景 —— 重制版设置 Bundle (v3: 全标准 ObjC 语法, 适配 arm64e)
// 架构: 入口壳(PSListController) -> 模态面板(UITableViewController 自绘) -> 素材选择器(模态)
// 关键: 全部使用 [obj method:] 标准语法, 由编译器生成 arm64e 正确的 objc_msgSend
#include <stdio.h>
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
extern "C" id UIImagePNGRepresentation(id img);

#define CLS(n) objc_getClass(n)
static id CLSSTR(const char *n) { return (id)objc_getClass(n); }

// ---------- ObjC 存根 (标准声明, 供编译期检查) ----------
@interface NSObject
+ (id)alloc;
+ (id)class;
- (id)init;
- (id)valueForKey:(id)k;
- (void)setValue:(id)v forKey:(id)k;
- (void)performSelector:(SEL)s withObject:(id)o afterDelay:(double)d;
@end
@interface NSString : NSObject
- (id)initWithBytes:(const void *)b length:(NSUInteger)l encoding:(NSUInteger)e;
+ (id)stringWithFormat:(NSString *)f, ...;
- (NSString *)stringByAppendingPathComponent:(NSString *)s;
- (NSString *)pathExtension;
- (NSString *)lowercaseString;
- (BOOL)isEqualToString:(NSString *)s;
@end
@interface NSArray : NSObject
+ (id)array;
+ (id)arrayWithObjects:(id)first, ...;
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
@end
@interface NSFileManager : NSObject
+ (id)defaultManager;
- (BOOL)fileExistsAtPath:(NSString *)p;
- (BOOL)fileExistsAtPath:(NSString *)p isDirectory:(BOOL *)d;
- (BOOL)createDirectoryAtPath:(NSString *)p withIntermediateDirectories:(BOOL)b attributes:(id)a error:(id *)e;
- (BOOL)copyItemAtURL:(id)src toURL:(id)dst error:(id *)e;
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

typedef struct CGRect { double ox, oy, w, h; } CGRect;
typedef struct CGSize { double w, h; } CGSize;
typedef struct UIEdgeInsets { double top, left, bottom, right; } UIEdgeInsets;
static CGRect MakeRect(double x, double y, double w, double h) { CGRect r = {x, y, w, h}; return r; }

@interface UIColor : NSObject
+ (id)clearColor;
+ (id)whiteColor;
+ (id)redColor;
+ (id)colorWithWhite:(double)w alpha:(double)a;
+ (id)systemBlueColor;
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
- (id)navigationItem;
- (void)setLeftBarButtonItem:(id)b;
- (void)setRightBarButtonItem:(id)b;
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
@interface UIScreen : NSObject
+ (id)mainScreen;
- (CGRect)bounds;
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
    for (NSString *k in [NSArray arrayWithObjects:@"Enablelddgifbg", @"Enablezxhlddgifbg", @"lddgifbgScale", @"SelectedMaterialFolder", nil]) {
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

// ---------- 素材选择器: 卡片网格 ----------
@interface LDDMaterialPickerController : UIViewController
- (NSInteger)collectionView:(id)cv numberOfItemsInSection:(NSInteger)s;
- (id)collectionView:(id)cv cellForItemAtIndexPath:(id)ip;
- (void)collectionView:(id)cv didSelectItemAtIndexPath:(id)ip;
- (CGSize)collectionView:(id)cv layout:(id)layout sizeForItemAtIndexPath:(id)ip;
- (void)closeTapped;
@end
@implementation LDDMaterialPickerController
{
    id _folders;
    id _thumbs;
    NSString *_sel;
    id _cv;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"素材库"];
    UIBarButtonItem *close = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:0 target:self action:@selector(closeTapped)];
    [[self navigationItem] setLeftBarButtonItem:close];
    UIBarButtonItem *imp = [[UIBarButtonItem alloc] initWithTitle:@"导入" style:0 target:self action:@selector(importTapped)];
    [[self navigationItem] setRightBarButtonItem:imp];
    [[self view] setBackgroundColor:[UIColor colorWithWhite:0.94 alpha:1.0]];

    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir = NO;
    if ([fm fileExistsAtPath:@"/var/mobile/lddgifbg" isDirectory:&isDir] && isDir) {
        _folders = [fm contentsOfDirectoryAtPath:@"/var/mobile/lddgifbg" error:nil];
    }
    _thumbs = [NSMutableDictionary dictionary];
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
    id utImage = [(id)objc_getClass("UTType") performSelector:sel_registerName("image")];
    id utMovie = [(id)objc_getClass("UTType") performSelector:sel_registerName("movie")];
    UIDocumentPickerViewController *dp = [[UIDocumentPickerViewController alloc] initForOpeningContentTypes:[NSArray arrayWithObjects:utImage, utMovie, nil]];
    [dp setDelegate:self];
    [self presentViewController:dp animated:YES completion:0];
}
// 相册回调
- (void)imagePickerController:(id)picker didFinishPickingMediaWithInfo:(id)info {
    [self dismissViewControllerAnimated:YES completion:0];
    NSString *mt = [info objectForKeyedSubscript:@"UIImagePickerControllerMediaType"];
    id img = [info objectForKeyedSubscript:@"UIImagePickerControllerOriginalImage"];
    id mediaURL = [info objectForKeyedSubscript:@"UIImagePickerControllerMediaURL"];
    BOOL isVideo = mt && [mt isEqualToString:@"public.movie"];
    [self askNameAndSave:img url:mediaURL isVideo:isVideo];
}
- (void)imagePickerControllerDidCancel:(id)picker {
    [self dismissViewControllerAnimated:YES completion:0];
}
// 文件回调
- (void)documentPicker:(id)controller didPickDocumentsAtURLs:(id)urls {
    [self dismissViewControllerAnimated:YES completion:0];
    id url = [urls objectAtIndex:0];
    [self askNameAndSave:0 url:url isVideo:NO];
}
- (void)documentPickerWasCancelled:(id)controller {
    [self dismissViewControllerAnimated:YES completion:0];
}
// 命名 + 保存
- (void)askNameAndSave:(id)img url:(id)srcURL isVideo:(BOOL)isVideo {
    UIAlertController *al = [UIAlertController alertControllerWithTitle:@"命名素材" message:@"给这个素材起个名字" preferredStyle:1];
    [al addTextFieldWithConfigurationHandler:^(id tf){
        [tf setPlaceholder:@"素材名称"];
    }];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"保存" style:0 handler:^(UIAlertAction *a){
        id tfs = [al textFields];
        NSString *nm = [tfs objectAtIndex:0];
        if (!nm || [nm length] == 0) nm = @"新素材";
        [self saveMaterial:nm image:img url:srcURL isVideo:isVideo];
    }];
    UIAlertAction *cc = [UIAlertAction actionWithTitle:@"取消" style:1 handler:0];
    [al addAction:ok];
    [al addAction:cc];
    [self presentViewController:al animated:YES completion:0];
}
- (void)saveMaterial:(NSString *)nm image:(id)img url:(id)srcURL isVideo:(BOOL)isVideo {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *dir = [@"/var/mobile/lddgifbg" stringByAppendingPathComponent:nm];
    [fm createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:0 error:0];
    BOOL ok = NO;
    if (img) {
        id data = UIImagePNGRepresentation(img);
        ok = [data writeToFile:[dir stringByAppendingPathComponent:@"imported.png"] atomically:YES];
    } else if (srcURL) {
        NSString *ext = isVideo ? @"mov" : @"png";
        ok = [fm copyItemAtURL:srcURL toURL:[NSURL fileURLWithPath:[dir stringByAppendingPathComponent:[NSString stringWithFormat:@"imported.%@", ext]]] error:0];
    }
    // 刷新列表
    _folders = [fm contentsOfDirectoryAtPath:@"/var/mobile/lddgifbg" error:nil];
    NSString *cnt = [NSString stringWithFormat:@"素材库 (%lu)", (unsigned long)[_folders count]];
    [self setTitle:cnt];
    [(UICollectionView *)_cv reloadData];
    (void)ok;
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
    UIView *dot = [[UIView alloc] initWithFrame:MakeRect(cb.w / 2 - 11, imgH + 38, 22, 22)];
    [[dot layer] setCornerRadius:11.0];
    [[dot layer] setMasksToBounds:YES];
    [dot setBackgroundColor:on ? [UIColor systemBlueColor] : [UIColor colorWithWhite:0.80 alpha:1.0]];
    [[cell contentView] addSubview:dot];
    return cell;
}
- (void)collectionView:(id)cv didSelectItemAtIndexPath:(id)ip {
    NSInteger row = [ip row];
    if (!_folders || row >= (NSInteger)[_folders count]) return;
    NSString *name = [_folders objectAtIndex:(NSUInteger)row];
    _sel = name;
    NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
    [ud setObject:name forKey:@"SelectedMaterialFolder"];
    [ud synchronize];
    WritePrefsFile(@"SelectedMaterialFolder", name);
    [(UICollectionView *)cv reloadData];
}
@end

// ---------- 设置主控制器: PSListController 子类 + 直接自绘 6 行 (无模态无延迟) ----------
@interface lddgifbgRootListController : PSListController
- (NSInteger)numberOfSectionsInTableView:(id)tv;
- (NSInteger)tableView:(id)tv numberOfRowsInSection:(NSInteger)s;
- (id)tableView:(id)tv cellForRowAtIndexPath:(id)ip;
- (void)tableView:(id)tv didSelectRowAtIndexPath:(id)ip;
@end
@implementation lddgifbgRootListController
- (void)viewDidLoad {
    LogB("ROOT-VIEWDIDLOAD");
    @try { [super viewDidLoad]; } @catch (id e) { LogB("ROOT-VD-EXC"); }
    [self setTitle:@"灵动岛GIF背景"];
}
- (id)specifiers {
    @try { return [self loadSpecifiersFromPlistName:@"Root" target:self]; }
    @catch (id e) { LogB("ROOT-SPEC-EXC"); }
    return [NSArray array];
}
- (NSInteger)numberOfSectionsInTableView:(id)tv { return 1; }
- (NSInteger)tableView:(id)tv numberOfRowsInSection:(NSInteger)s { return 6; }
- (double)tableView:(id)tv heightForRowAtIndexPath:(id)ip { return 60.0; }
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
        UILabel *label = [[UILabel alloc] initWithFrame:MakeRect(16, 8, b.w - 32, 20)];
        [label setText:@"缩放比例"];
        [label setFont:[UIFont systemFontOfSize:15.0]];
        [[cell contentView] addSubview:label];
        UISlider *sl = [[UISlider alloc] initWithFrame:MakeRect(16, 30, b.w - 32, 28)];
        [sl setMinimumValue:0.1];
        [sl setMaximumValue:2.0];
        NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
        id v = [ud objectForKey:@"lddgifbgScale"];
        double dv = v ? [v doubleValue] : 1.0;
        if (dv <= 0) dv = 1.0;
        [sl setValue:dv];
        [sl addTarget:self action:@selector(sliderChanged:) forControlEvents:1 << 12];
        [[cell contentView] addSubview:sl];
    } else {
        NSString *t = (row == 3 ? @"选择素材" : (row == 4 ? @"跳转素材目录" : @"立即注销"));
        UILabel *label = [[UILabel alloc] initWithFrame:MakeRect(16, 19, b.w - 60, 22)];
        [label setText:t];
        [label setFont:[UIFont systemFontOfSize:16.0]];
        if (row == 5) [label setTextColor:[UIColor redColor]];
        [[cell contentView] addSubview:label];
        [cell setSelectionStyle:1];
    }
    return cell;
}
- (void)tableView:(id)tv didSelectRowAtIndexPath:(id)ip {
    NSInteger row = [ip row];
    [(UITableView *)tv deselectRowAtIndexPath:ip animated:YES];
    if (row == 3) {
        LDDMaterialPickerController *pc = [[LDDMaterialPickerController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:pc];
        [self presentViewController:nav animated:YES completion:0];
    } else if (row == 4) {
        UIApplication *app = [UIApplication sharedApplication];
        NSURL *fz = [NSURL URLWithString:@"filza://view/var/mobile/lddgifbg/"];
        [app openURL:fz options:[NSDictionary dictionary] completionHandler:^(BOOL ok){
            if (!ok) {
                NSURL *url = [NSURL fileURLWithPath:@"/var/mobile/lddgifbg"];
                [app openURL:url options:[NSDictionary dictionary] completionHandler:0];
            }
        }];
    } else if (row == 5) {
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
- (void)sliderChanged:(UISlider *)sl {
    double dv = [sl value];
    NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
    [ud setObject:[NSNumber numberWithDouble:dv] forKey:@"lddgifbgScale"];
    [ud synchronize];
    WritePrefsFile(@"lddgifbgScale", [NSNumber numberWithDouble:dv]);
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
