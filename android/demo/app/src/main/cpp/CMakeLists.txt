# For more information about using CMake with Android Studio, read the
# documentation: https://d.android.com/studio/projects/add-native-code.html

# Sets the minimum version of CMake required to build the native library.

cmake_minimum_required(VERSION 3.8)

# Declares and names the project.

project("demo")

message("the path is ${PROJECT_SOURCE_DIR}")

# Creates and names a library, sets it as either STATIC
# or SHARED, and provides the relative paths to its source code.
# You can define multiple libraries, and CMake builds them for you.
# Gradle automatically packages shared libraries with your APK.

add_library( # Sets the name of the library.
        demo

        # Sets the library as a shared library.
        SHARED

        # Provides a relative path to your source file(s).
        native-lib.cpp)

# Searches for a specified prebuilt library and stores the path as a
# variable. Because CMake includes system libraries in the search path by
# default, you only need to specify the name of the public NDK library
# you want to add. CMake verifies that the library exists before
# completing its build.
add_subdirectory(../../../../../../ wxdut)

#SET(OpenCV_DIR ${PROJECT_SOURCE_DIR}/third-party/opencv_high_test/opencv_ndk_3_4_5/sdk/native/jni)
#     #SET(OpenCV_DIR D:/workspace/WeEffectDemo/WeEffect/deps/opencv/android/staticlibs)
#find_package(OpenCV REQUIRED)

target_link_libraries( # Specifies the target library.
        demo
        GLESv2
        log
        wxdut)
