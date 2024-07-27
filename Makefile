THEOS_DEVICE_IP = 192.168.1.18
GO_EASY_ON_ME = 1

include theos/makefiles/common.mk

BUNDLE_NAME = Configurator
Configurator_FILES = Configurator.mm ADVCell.m OTAModule.m
Configurator_INSTALL_PATH = /System/Library/PreferenceBundles
Configurator_FRAMEWORKS = UIKit CoreGraphics QuartzCore
Configurator_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

