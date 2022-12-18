#include <jni.h>
#include "../../../../../include/wxdut.h"

extern "C"
JNIEXPORT void JNICALL
Java_com_wxdut_cmake_MainActivity_testJNI(JNIEnv *env, jclass clazz) {
    wxdut::testOpenCV();
}