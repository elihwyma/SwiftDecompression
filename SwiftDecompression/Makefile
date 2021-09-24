THEOS_DEVICE_IP = 127.0.0.1
THEOS_DEVICE_PORT = 2222
TARGET = iphone:13.3:14.0
ARCHS = arm64
INSTALL_TARGET_PROCESSES = SwiftDecompression

include $(THEOS)/makefiles/common.mk

XCODEPROJ_NAME = SwiftDecompression
SwiftDecompression_XCODE_SCHEME = SwiftDecompression
SwiftDecompression_CODESIGN_FLAGS = -SSwiftDecompression.xml

include $(THEOS_MAKE_PATH)/xcodeproj.mk
