export THEOS_PACKAGE_SCHEME = rootless
export ARCHS = arm64 arm64e
export TARGET = iphone:clang:latest:15.0
export DEBUG = 0

TWEAK_NAME = 灵动岛GIF背景
灵动岛GIF背景_FILES = main/lddgifbg_main.mm
灵动岛GIF背景_CFLAGS = -fno-objc-arc
灵动岛GIF背景_FRAMEWORKS = ImageIO
灵动岛GIF背景_LDFLAGS = -lsubstrate

BUNDLE_NAME = lddgifbg
lddgifbg_FILES = bundle/lddgifbg_bundle.mm
lddgifbg_CFLAGS = -fobjc-arc -Wno-unused-function
lddgifbg_FRAMEWORKS = UIKit
lddgifbg_LDFLAGS = -Wl,-undefined,dynamic_lookup
lddgifbg_INSTALL_PATH = /Library/PreferenceBundles

include $(THEOS)/makefiles/common.mk
include $(THEOS)/makefiles/tweak.mk
include $(THEOS)/makefiles/bundle.mk