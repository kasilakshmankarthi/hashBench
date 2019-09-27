# IMPORTANT for A32 change ABI to armeabi-v7a in Application.mk
export NDK_PROJECT_PATH=$(pwd)

~/Android/Sdk/ndk-bundle/ndk-build V=1 NDK_APPLICATION_MK=Application.mk clean
~/Android/Sdk/ndk-bundle/ndk-build V=1 NDK_APPLICATION_MK=Application.mk
