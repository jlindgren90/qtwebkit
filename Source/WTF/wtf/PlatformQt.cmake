list(APPEND WTF_SOURCES
    UniStdExtras.cpp

    generic/MainThreadGeneric.cpp
    generic/WorkQueueGeneric.cpp

    glib/FileSystemGlib.cpp
    glib/GLibUtilities.cpp
    glib/GRefPtr.cpp
    glib/RunLoopGLib.cpp
    glib/URLGLib.cpp

    linux/CurrentProcessMemoryStatus.cpp
    linux/MemoryFootprintLinux.cpp
    linux/MemoryPressureHandlerLinux.cpp

    posix/OSAllocatorPOSIX.cpp
    posix/ThreadingPOSIX.cpp

    text/qt/StringQt.cpp

    text/unix/TextBreakIteratorInternalICUUnix.cpp

    unix/CPUTimeUnix.cpp
    unix/LanguageUnix.cpp
)

list(APPEND WTF_LIBRARIES
    ${CMAKE_THREAD_LIBS_INIT}
    ${GLIB_GIO_LIBRARIES}
    ${GLIB_GOBJECT_LIBRARIES}
    ${GLIB_LIBRARIES}
    ${Qt5Core_LIBRARIES}
    ${ZLIB_LIBRARIES}
)

list(APPEND WTF_SYSTEM_INCLUDE_DIRECTORIES
    ${GIO_UNIX_INCLUDE_DIRS}
    ${GLIB_INCLUDE_DIRS}
    ${Qt5Core_INCLUDE_DIRS}
)
