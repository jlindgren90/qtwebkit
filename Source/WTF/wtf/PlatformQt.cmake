list(APPEND WTF_SOURCES
    PlatformUserPreferredLanguagesUnix.cpp
    UniStdExtras.cpp

    generic/WorkQueueGeneric.cpp

    glib/GLibUtilities.cpp
    glib/GRefPtr.cpp
    glib/MainThreadGLib.cpp
    glib/RunLoopGLib.cpp

    text/qt/StringQt.cpp
    text/qt/TextBreakIteratorInternalICUQt.cpp

    linux/CurrentProcessMemoryStatus.cpp
    linux/MemoryPressureHandlerLinux.cpp

    unix/CPUTimeUnix.cpp
)

list(APPEND WTF_SYSTEM_INCLUDE_DIRECTORIES
    ${GLIB_INCLUDE_DIRS}
    ${Qt5Core_INCLUDE_DIRS}
)

list(APPEND WTF_LIBRARIES
    ${GLIB_GOBJECT_LIBRARIES}
    ${GLIB_LIBRARIES}
    ${Qt5Core_LIBRARIES}
    ${CMAKE_THREAD_LIBS_INIT}
)

if (TRUE)
    set(WTF_LIBRARY_TYPE STATIC)

    check_function_exists(clock_gettime CLOCK_GETTIME_EXISTS)
    if (NOT CLOCK_GETTIME_EXISTS)
        set(CMAKE_REQUIRED_LIBRARIES rt)
        check_function_exists(clock_gettime CLOCK_GETTIME_REQUIRES_LIBRT)
        if (CLOCK_GETTIME_REQUIRES_LIBRT)
            list(APPEND WTF_LIBRARIES rt)
        endif ()
    endif ()
endif ()
