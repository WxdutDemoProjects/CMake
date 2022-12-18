cmake_minimum_required(VERSION 3.8.0) # 指定 cmake 最低版本

set(LIB_NAME "wxdut")
project(${LIB_NAME}) # 项目名称

set(CMAKE_CXX_STANDARD 17) # 编译用到的 c++ 版本

# c/cpp compile flags
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -fPIC -frtti -fexceptions -flax-vector-conversions -mfloat-abi=softfp -mfpu=neon")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -fPIC -frtti -fexceptions -flax-vector-conversions -mfloat-abi=softfp -mfpu=neon")

# 生产环境都是编译 Release 包，本地环境就编译 Debug 包。可以给不同的 Scheme 指定不同的编译参数
set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS} -Os -DNDEBUG")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS} -Os -DNDEBUG")
set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS} -O0 -DDEBUG")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS} -O0 -DDEBUG")
# 在 iOS 上可能有一些比较特殊的 Scheme，比如 Debug_test，可以通过 CMAKE_CXX_FLAGS_ 拼接 Scheme 名字的方式指定特殊参数
# 比如给 Debug_test 这种 Scheme 设置 -Os 的 Optimization Level
set(CMAKE_C_FLAGS_DEBUG_TEST "${CMAKE_C_FLAGS} -Os")
set(CMAKE_CXX_FLAGS_DEBUG_TEST "${CMAKE_CXX_FLAGS} -Os")

set(LINK_LIBRARY) # 设置一个名为 LINK_LIBRARY 的变量，并且值为空，下面会把需要链接的库都加进去

if (CMAKE_SYSTEM_NAME MATCHES "iOS") ## CMAKE 开头的变量一般都是 CMAKE 预定义的，我们可以根据这些参数判断平台、架构等等
    set(IOS ON)
    add_definitions(-D__IOS__) # 添加一些宏定义，这些宏定义是可以在代码中使用的，比如在代码中通过 #ifdef __IOS__ 判断当前是否是 iOS 平台
endif()

if (CMAKE_SYSTEM_NAME MATCHES "Android")
    set(ANDROID ON)
    add_definitions(-D__Android__ -D__ANDROID__)
    if (CMAKE_ANDROID_ARCH_ABI STREQUAL "arm64-v8a") # 判断安卓的 ABI
    endif ()
endif()

# Headers
include_directories(src/include) # 通过这种方式导入头文件，这样就可以在 c/cpp 文件中 #include 这些头文件了
file(GLOB_RECURSE EXPORT_HEADER_FILES src/include/*.h)
# 这种方式是给所有 target 引入头文件，还有个 target_include_directories 可以给特定的 target 引入头文件

# 在添加资源文件时不可能枚举所有文件，所以更常见的是使用下面这种递归+模糊搜索的方式
file(GLOB_RECURSE SRC_SOURCE_FILES src/*.cc) # 递归的查找 src 文件夹下的所有以 .cc 结尾的文件，并将文件路径存到数组 SRC_SOURCE_FILES 中

# 导入库可以用下面这种方式，iOS 和 Android 都是类似的，只不过有一些小区别，比如 Android 需要判断 CMAKE_ANDROID_ARCH_ABI，iOS 一般都是双架构的库

if (ANDROID)
    # 导入 .a 和 .so
    include_directories(${PROJECT_SOURCE_DIR}/third-party/opencv/android/include)
    set(LINK_LIBRARY ${LINK_LIBRARY} ${PROJECT_SOURCE_DIR}/third-party/opencv/android/${CMAKE_ANDROID_ARCH_ABI}/libopencv_world.so)
endif(ANDROID)
if (IOS)
    # 导入 framework
    set(LINK_LIBRARY ${LINK_LIBRARY} ${PROJECT_SOURCE_DIR}/third-party/opencv/ios/opencv2.framework)
    # tips: 通过上面这个方式链接 framework 时，实际上生成的 xcode 工程里会自动把这个 framework 所在的文件夹加到 Framework Search Paths 里，所以不需要手动调用 include_directories 包含头文件
endif(IOS)

if (IOS)
    add_library(${LIB_NAME} STATIC # 创建一个名为 ${LIB_NAME} 的静态库，资源文件为 ${SRC_SOURCE_FILES} 和 ${EXPORT_HEADER_FILES}
        ${SRC_SOURCE_FILES}
        ${EXPORT_HEADER_FILES}
    )

    set_target_properties(${LIB_NAME} PROPERTIES
        FRAMEWORK TRUE # 生成的库为 framework 方式
        FRAMEWORK_VERSION A
        MACOSX_FRAMEWORK_IDENTIFIER com.wxdut.${LIB_NAME}
        RESOURCE ""
    )
    
    # 让 xcode 生成并保留调试符号
    set_xcode_property(${LIB_NAME} GCC_GENERATE_DEBUGGING_SYMBOLS "YES" "All")
    set_xcode_property(${LIB_NAME} DEPLOYMENT_POSTPROCESSING "NO" "All")
    set_xcode_property(${LIB_NAME} STRIP_INSTALLED_PRODUCT "NO" "All")

    foreach(hfile ${EXPORT_HEADER_FILES}) # framework 里有一些暴漏出去的头文件，可以以这种方式拷贝过去
        set_property(SOURCE ${hfile} PROPERTY
            MACOSX_PACKAGE_LOCATION Headers/ # 头文件会放到 ${LIB_NAME}.framework/Headers 文件夹下
        )
    endforeach(hfile)

    target_link_libraries(${LIB_NAME} PRIVATE
        ${LINK_LIBRARY} # LINK_LIBRARY 是一个数组，上面手动导入的库，这里链接到 ${LIB_NAME}.framework
        "-framework JavaScriptCore" # 可以通过这种方式链接一些系统库
    )
endif(IOS)

if (ANDROID)
    add_library(${LIB_NAME} SHARED
        ${SRC_SOURCE_FILES}
        ${EXPORT_HEADER_FILES}
    )

    set_target_properties(${LIB_NAME} PROPERTIES VERSION 1.0.0 SOVERSION 1 LINK_FLAGS "${LINK_FLAGS}")
    target_link_libraries(${LIB_NAME} EGL GLESv2 android log camera2ndk mediandk ${LINK_LIBRARY}) # 链接一些库，比如系统库，或者我们手动导入的库
    foreach(hfile ${EXPORT_HEADER_FILES}) # 安卓上库的头文件一般会导出到一个文件夹里，我们可以通过这种方式拷贝过去
        file(COPY ${hfile} DESTINATION ${PROJECT_SOURCE_DIR}/android/include/)
    endforeach(hfile)

endif(ANDROID)