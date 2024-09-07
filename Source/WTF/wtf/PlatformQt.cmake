list(APPEND WTF_SOURCES
    qt/MainThreadQt.cpp
    qt/RunLoopQt.cpp

    text/qt/StringQt.cpp
)
QTWEBKIT_GENERATE_MOC_FILES_CPP(WTF qt/MainThreadQt.cpp qt/RunLoopQt.cpp)

list(APPEND WTF_SYSTEM_INCLUDE_DIRECTORIES
    ${Qt5Core_INCLUDE_DIRS}
)

list(APPEND WTF_LIBRARIES
    ${Qt5Core_LIBRARIES}
    ${CMAKE_THREAD_LIBS_INIT}
)

if (SHARED_CORE)
    set(WTF_LIBRARY_TYPE SHARED)
else ()
    set(WTF_LIBRARY_TYPE STATIC)
endif ()

if (QT_STATIC_BUILD)
    list(APPEND WTF_LIBRARIES
        ${STATIC_LIB_DEPENDENCIES}
    )
endif ()

if (TRUE)
    list(APPEND WTF_SOURCES
        UniStdExtras.cpp

        qt/WorkQueueQt.cpp
    )
    QTWEBKIT_GENERATE_MOC_FILES_CPP(WTF qt/WorkQueueQt.cpp)

    list(APPEND WTF_SOURCES
        glib/GRefPtr.cpp
    )
    list(APPEND WTF_SYSTEM_INCLUDE_DIRECTORIES
        ${GLIB_INCLUDE_DIRS}
    )
    list(APPEND WTF_LIBRARIES
        ${GLIB_GOBJECT_LIBRARIES}
        ${GLIB_LIBRARIES}
    )

    check_function_exists(clock_gettime CLOCK_GETTIME_EXISTS)
    if (NOT CLOCK_GETTIME_EXISTS)
        set(CMAKE_REQUIRED_LIBRARIES rt)
        check_function_exists(clock_gettime CLOCK_GETTIME_REQUIRES_LIBRT)
        if (CLOCK_GETTIME_REQUIRES_LIBRT)
            list(APPEND WTF_LIBRARIES rt)
        endif ()
    endif ()
endif ()
