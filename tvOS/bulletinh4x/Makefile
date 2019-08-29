INSTALL_TARGET_PROCESSES = PineBoard ReProvision
ARCHS = arm64
TARGET = appletv
target ?= appletv:clang:11.4.1:10.0
export GO_EASY_ON_ME=1
export SDKVERSION=12.1
THEOS_DEVICE_IP=twelve.local

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = bulletinh4x

bulletinh4x_FILES = Tweak.xm
bulletinh4x_CFLAGS = -fobjc-arc
bulletinh4x_PRIVATE_FRAMEWORKS = PineBoardServices

include $(THEOS_MAKE_PATH)/tweak.mk
