include(CheckCXXSourceCompiles)
include(FeatureSummary)
include(ECMEnableSanitizers)
include(ECMPackageConfigHelpers)

set(ECM_MODULE_DIR ${CMAKE_MODULE_PATH})

set(PROJECT_VERSION_MAJOR 5)
set(PROJECT_VERSION_MINOR 212)
set(PROJECT_VERSION_PATCH 0)
set(PROJECT_VERSION ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH})
set(PROJECT_VERSION_STRING "${PROJECT_VERSION}")

set(STATIC_DEPENDENCIES_CMAKE_FILE "${CMAKE_BINARY_DIR}/QtStaticDependencies.cmake")
if (EXISTS ${STATIC_DEPENDENCIES_CMAKE_FILE})
    file(REMOVE ${STATIC_DEPENDENCIES_CMAKE_FILE})
endif ()

macro(CONVERT_PRL_LIBS_TO_CMAKE _qt_component)
    if (TARGET Qt5::${_qt_component})
        get_target_property(_lib_location Qt5::${_qt_component} LOCATION)
        execute_process(COMMAND ${PERL_EXECUTABLE} ${TOOLS_DIR}/qt/convert-prl-libs-to-cmake.pl
            --lib ${_lib_location}
            --out ${STATIC_DEPENDENCIES_CMAKE_FILE}
            --component ${_qt_component}
            --compiler ${CMAKE_CXX_COMPILER_ID}
        )
    endif ()
endmacro()

macro(CHECK_QT5_PRIVATE_INCLUDE_DIRS _qt_component _header)
    set(INCLUDE_TEST_SOURCE
    "
        #include <${_header}>
        int main() { return 0; }
    "
    )
    set(CMAKE_REQUIRED_INCLUDES ${Qt5${_qt_component}_PRIVATE_INCLUDE_DIRS})
    set(CMAKE_REQUIRED_LIBRARIES Qt5::${_qt_component})

    # Avoid check_include_file_cxx() because it performs linking but doesn't support CMAKE_REQUIRED_LIBRARIES (doh!)
    check_cxx_source_compiles("${INCLUDE_TEST_SOURCE}" Qt5${_qt_component}_PRIVATE_HEADER_FOUND)

    unset(INCLUDE_TEST_SOURCE)
    unset(CMAKE_REQUIRED_INCLUDES)
    unset(CMAKE_REQUIRED_LIBRARIES)

    if (NOT Qt5${_qt_component}_PRIVATE_HEADER_FOUND)
        message(FATAL_ERROR "Header ${_header} is not found. Please make sure that:
    1. Private headers of Qt5${_qt_component} are installed
    2. Qt5${_qt_component}_PRIVATE_INCLUDE_DIRS is correctly defined in Qt5${_qt_component}Config.cmake")
    endif ()
endmacro()

macro(QTWEBKIT_SKIP_AUTOMOC _target)
    foreach (_src ${${_target}_SOURCES})
        set_property(SOURCE ${_src} PROPERTY SKIP_AUTOMOC ON)
    endforeach ()
endmacro()

macro(QTWEBKIT_GENERATE_MOC_FILES_CPP _target)
    if (${ARGC} LESS 2)
        message(FATAL_ERROR "QTWEBKIT_GENERATE_MOC_FILES_CPP must be called with at least 2 arguments")
    endif ()
    foreach (_file ${ARGN})
        get_filename_component(_ext ${_file} EXT)
        if (NOT _ext STREQUAL ".cpp")
            message(FATAL_ERROR "QTWEBKIT_GENERATE_MOC_FILES_CPP must be used for .cpp files only")
        endif ()
        get_filename_component(_name_we ${_file} NAME_WE)
        set(_moc_name "${CMAKE_CURRENT_BINARY_DIR}/${_name_we}.moc")
        qt5_generate_moc(${_file} ${_moc_name} TARGET ${_target})
        ADD_SOURCE_DEPENDENCIES(${_file} ${_moc_name})
    endforeach ()
endmacro()

macro(QTWEBKIT_GENERATE_MOC_FILE_H _target _header _source)
    get_filename_component(_header_ext ${_header} EXT)
    get_filename_component(_source_ext ${_source} EXT)
    if ((NOT _header_ext STREQUAL ".h") OR (NOT _source_ext STREQUAL ".cpp"))
        message(FATAL_ERROR "QTWEBKIT_GENERATE_MOC_FILE_H must be called with arguments being .h and .cpp files")
    endif ()
    get_filename_component(_name_we ${_header} NAME_WE)
    set(_moc_name "${CMAKE_CURRENT_BINARY_DIR}/moc_${_name_we}.cpp")
    qt5_generate_moc(${_header} ${_moc_name} TARGET ${_target})
    ADD_SOURCE_DEPENDENCIES(${_source} ${_moc_name})
endmacro()

macro(QTWEBKIT_GENERATE_MOC_FILES_H _target)
    if (${ARGC} LESS 2)
        message(FATAL_ERROR "QTWEBKIT_GENERATE_MOC_FILES_H must be called with at least 2 arguments")
    endif ()
    foreach (_header ${ARGN})
        get_filename_component(_header_dir ${_header} DIRECTORY)
        get_filename_component(_name_we ${_header} NAME_WE)
        set(_source "${_header_dir}/${_name_we}.cpp")
        QTWEBKIT_GENERATE_MOC_FILE_H(${_target} ${_header} ${_source})
    endforeach ()
endmacro()

macro(QTWEBKIT_SEPARATE_DEBUG_INFO _target _target_debug)
    if (MINGW OR UNIX AND NOT APPLE) # Not using COMPILER_IS_GCC_OR_CLANG because other ELF compilers may work as well
        if (NOT CMAKE_OBJCOPY)
            message(WARNING "CMAKE_OBJCOPY is not defined - debug information will not be split")
        else ()
            set(_target_file "$<TARGET_FILE:${_target}>")
            set(${_target_debug} "${_target_file}.debug")

            if (TRUE)
                set(EXTRACT_DEBUG_INFO_COMMAND COMMAND ${CMAKE_OBJCOPY} --only-keep-debug ${_target_file} ${${_target_debug}})
            endif ()

            add_custom_command(TARGET ${_target} POST_BUILD
                ${EXTRACT_DEBUG_INFO_COMMAND}
                COMMAND ${CMAKE_OBJCOPY} --strip-debug ${_target_file}
                COMMAND ${CMAKE_OBJCOPY} --add-gnu-debuglink=${${_target_debug}} ${_target_file}
                VERBATIM
            )
            unset(_target_file)
        endif ()
    endif ()
endmacro()

add_definitions(-DBUILDING_QT__=1)
add_definitions(-DQT_NO_EXCEPTIONS)
add_definitions(-DQT_USE_QSTRINGBUILDER)
add_definitions(-DQT_NO_CAST_TO_ASCII -DQT_ASCII_CAST_WARNINGS)
add_definitions(-DQT_DEPRECATED_WARNINGS -DQT_DISABLE_DEPRECATED_BEFORE=0x050000)

# We use -fno-rtti with GCC and Clang, see OptionsCommon.cmake
if (COMPILER_IS_GCC_OR_CLANG)
    add_definitions(-DQT_NO_DYNAMIC_CAST)
endif ()

WEBKIT_OPTION_BEGIN()

if (TRUE)
    set(USE_LIBHYPHEN_DEFAULT ON)
    set(USE_GSTREAMER_DEFAULT ON)
endif ()

if (WTF_CPU_X86_64)
    set(ENABLE_FTL_DEFAULT ON)
else ()
    set(ENABLE_FTL_DEFAULT OFF)
endif ()

# FIXME: Move Qt handling here
set(REQUIRED_QT_VERSION 5.15.0)
find_package(Qt5 ${REQUIRED_QT_VERSION} REQUIRED COMPONENTS Core Gui QUIET)

if (TRUE)
    set(ICU_LIBRARY_PREFIX "")
    set(ENABLE_WEBKIT2_DEFAULT OFF)
endif ()

if (TARGET Qt5::QXcbIntegrationPlugin)
    set(ENABLE_X11_TARGET_DEFAULT ON)
else ()
    set(ENABLE_X11_TARGET_DEFAULT OFF)
endif ()

if (TRUE)
    set(ENABLE_NETSCAPE_PLUGIN_API_DEFAULT OFF)
endif ()

# Public options specific to the Qt port. Do not add any options here unless
# there is a strong reason we should support changing the value of the option,
# and the option is not relevant to any other WebKit ports.
WEBKIT_OPTION_DEFINE(USE_GSTREAMER "Use GStreamer implementation of MediaPlayer" PUBLIC ${USE_GSTREAMER_DEFAULT})
WEBKIT_OPTION_DEFINE(USE_LIBHYPHEN "Use automatic hyphenation with LibHyphen" PUBLIC ${USE_LIBHYPHEN_DEFAULT})
WEBKIT_OPTION_DEFINE(ENABLE_INSPECTOR_UI "Include Inspector UI into resources" PUBLIC ON)
WEBKIT_OPTION_DEFINE(ENABLE_WEBKIT2 "Enable WebKit2 (QML API)" PUBLIC OFF) # WebKit2 disabled
WEBKIT_OPTION_DEFINE(ENABLE_X11_TARGET "Whether to enable support for the X11 windowing target." PUBLIC ${ENABLE_X11_TARGET_DEFAULT})

option(GENERATE_DOCUMENTATION "Generate HTML and QCH documentation" OFF)

# Public options shared with other WebKit ports. There must be strong reason
# to support changing the value of the option.
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_ACCELERATED_2D_CANVAS PUBLIC OFF) # GL disabled
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_ALLINONE_BUILD PUBLIC ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_API_TESTS PUBLIC OFF) # FIXME: tests disabled
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_CSS_GRID_LAYOUT PUBLIC ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_DATABASE_PROCESS PUBLIC ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_DATALIST_ELEMENT PUBLIC ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_DEVICE_ORIENTATION PUBLIC OFF)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_FULLSCREEN_API PUBLIC ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_GAMEPAD_DEPRECATED PUBLIC OFF)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_INDEXED_DATABASE PUBLIC ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_LEGACY_WEB_AUDIO PUBLIC ${USE_GSTREAMER_DEFAULT})
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_LINK_PREFETCH PUBLIC ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_MEDIA_SOURCE PUBLIC ${USE_GSTREAMER_DEFAULT})
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_NETSCAPE_PLUGIN_API PUBLIC OFF) # plugins disabled
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_XSLT PUBLIC ON)

WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_DRAG_SUPPORT PUBLIC ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_GEOLOCATION PUBLIC OFF)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_ICONDATABASE PUBLIC ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_JIT PUBLIC ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_SAMPLING_PROFILER PUBLIC ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_SPELLCHECK PUBLIC ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_TOUCH_EVENTS PUBLIC ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_VIDEO PUBLIC ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_WEB_AUDIO PUBLIC ${USE_GSTREAMER_DEFAULT})
WEBKIT_OPTION_DEFAULT_PORT_VALUE(USE_SYSTEM_MALLOC PUBLIC OFF)

# Private options shared with other WebKit ports. Add options here when
# we need a value different from the default defined in WebKitFeatures.cmake.
# Changing these options is completely unsupported.
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_3D_TRANSFORMS PRIVATE OFF) # GL disabled
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_CSS_COMPOSITING PRIVATE ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_CSS_IMAGE_SET PRIVATE ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_CSS_REGIONS PRIVATE ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_CSS_SHAPES PRIVATE ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_CSS_SELECTORS_LEVEL4 PRIVATE ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_DOM4_EVENTS_CONSTRUCTOR PRIVATE ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_DOWNLOAD_ATTRIBUTE PRIVATE ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_FTL_JIT PRIVATE ${ENABLE_FTL_DEFAULT})
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_FTPDIR PRIVATE OFF)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_INPUT_TYPE_COLOR PRIVATE ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_INPUT_TYPE_COLOR_POPOVER PRIVATE ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_MEDIA_CONTROLS_SCRIPT PRIVATE ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_MHTML PRIVATE ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_NOTIFICATIONS PRIVATE ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_SMOOTH_SCROLLING PRIVATE OFF)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_USERSELECT_ALL PRIVATE ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_VIDEO_TRACK PRIVATE ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_WEB_TIMING PRIVATE ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_WEBGL PRIVATE OFF) # GL disabled

# Building video without these options is not supported
WEBKIT_OPTION_DEPEND(ENABLE_VIDEO ENABLE_VIDEO_TRACK)
WEBKIT_OPTION_DEPEND(ENABLE_VIDEO ENABLE_MEDIA_CONTROLS_SCRIPT)

# WebAudio and MediaSource are supported with GStreamer only
WEBKIT_OPTION_DEPEND(ENABLE_WEB_AUDIO USE_GSTREAMER)
WEBKIT_OPTION_DEPEND(ENABLE_LEGACY_WEB_AUDIO USE_GSTREAMER)
WEBKIT_OPTION_DEPEND(ENABLE_MEDIA_SOURCE USE_GSTREAMER)

WEBKIT_OPTION_END()

# FTL JIT and IndexedDB support require GCC 4.9
# TODO: Patch code to avoid variadic lambdas
if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    if (ENABLE_FTL_JIT OR ENABLE_INDEXED_DATABASE)
        if (CMAKE_CXX_COMPILER_VERSION VERSION_LESS "4.9.0")
            message(FATAL_ERROR "GCC 4.9.0 is required to build QtWebKit with FTL JIT, Indexed Database, and Database Process (WebKit 2). Use a newer GCC version or clang, or disable these features")
        endif ()
    else ()
        if (CMAKE_CXX_COMPILER_VERSION VERSION_LESS "4.8.0")
            message(FATAL_ERROR "GCC 4.8.0 is required to build QtWebKit, use a newer GCC version or clang")
        endif ()
    endif ()
endif ()

set(ENABLE_WEBKIT ON)
set(WTF_USE_UDIS86 1)

if (TRUE)
    set(JavaScriptCore_LIBRARY_TYPE STATIC)
    set(WebCoreTestSupport_LIBRARY_TYPE STATIC)
endif ()

SET_AND_EXPOSE_TO_BUILD(USE_TEXTURE_MAPPER TRUE)

if (TRUE)
    find_package(Sqlite REQUIRED)
endif ()

find_package(Threads REQUIRED)

if (TRUE)
    # Additional names of libjpeg to search (fixed in CMake 3.12.0)
    set(JPEG_NAMES jpeg-static libjpeg-static)
    find_package(JPEG REQUIRED)
    find_package(PNG REQUIRED)
    find_package(ZLIB REQUIRED)
    find_package(ICU REQUIRED)
    find_package(LibXml2 2.8.0 REQUIRED)
    if (ENABLE_XSLT)
        find_package(LibXslt 1.1.7 REQUIRED)
    endif ()
endif ()

find_package(WebP)

if (WEBP_FOUND)
    SET_AND_EXPOSE_TO_BUILD(USE_WEBP 1)
endif ()

set(QT_REQUIRED_COMPONENTS Core Gui Network)

# FIXME: Allow building w/o these components
list(APPEND QT_REQUIRED_COMPONENTS
    Widgets
)

if (TRUE)
    SET_AND_EXPOSE_TO_BUILD(USE_UNIX_DOMAIN_SOCKETS 1)
endif ()

find_package(Qt5 ${REQUIRED_QT_VERSION} REQUIRED COMPONENTS ${QT_REQUIRED_COMPONENTS})

CHECK_QT5_PRIVATE_INCLUDE_DIRS(Gui private/qhexstring_p.h)
if (TRUE)
    CHECK_QT5_PRIVATE_INCLUDE_DIRS(Network private/http2protocol_p.h)
endif ()

foreach (qt_module ${QT_OPTIONAL_COMPONENTS})
    find_package("Qt5${qt_module}" ${REQUIRED_QT_VERSION} PATHS ${_qt5_install_prefix} NO_DEFAULT_PATH)
endforeach ()

if (COMPILER_IS_GCC_OR_CLANG)
    if (TRUE)
        set(USE_LINKER_VERSION_SCRIPT_DEFAULT ON)
    endif ()
else ()
    set(USE_LINKER_VERSION_SCRIPT_DEFAULT OFF)
endif ()

option(USE_LINKER_VERSION_SCRIPT "Use linker script for ABI compatibility with Qt libraries" ${USE_LINKER_VERSION_SCRIPT_DEFAULT})

# Find includes in corresponding build directories
set(CMAKE_INCLUDE_CURRENT_DIR ON)

# TODO: figure out if we can run automoc only on Qt sources

# From OptionsEfl.cmake
# Optimize binary size for release builds by removing dead sections on unix/gcc.
if (COMPILER_IS_GCC_OR_CLANG)
    if (TRUE)
        set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -ffunction-sections -fdata-sections")
        set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -ffunction-sections -fdata-sections")
        set(CMAKE_SHARED_LINKER_FLAGS_RELEASE "${CMAKE_SHARED_LINKER_FLAGS_RELEASE} -Wl,--gc-sections")
        set(CMAKE_C_FLAGS "-fvisibility=hidden ${CMAKE_C_FLAGS}")
        set(CMAKE_CXX_FLAGS "-fvisibility=hidden -fvisibility-inlines-hidden ${CMAKE_CXX_FLAGS}")
    endif ()
endif ()

# Improvised backport of r222112 - not needed with current WebKit
# -Wexpansion-to-defined produces false positives with GCC but not Clang
# https://bugs.webkit.org/show_bug.cgi?id=167643#c13
if (CMAKE_COMPILER_IS_GNUCXX AND (NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS "7.0.0"))
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-expansion-to-defined")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-expansion-to-defined")
endif ()

# See also FORCE_DEBUG_INFO in Source/PlatformQt.cmake
if (FORCE_DEBUG_INFO)
    if (COMPILER_IS_GCC_OR_CLANG)
        # Enable debug info in Release builds
        set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -g")
        set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -g")
    endif ()
    if (USE_LD_GOLD)
       set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,--gdb-index")
       set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,--gdb-index")
    endif ()
endif ()

if (ENABLE_MATHML)
    SET_AND_EXPOSE_TO_BUILD(ENABLE_OPENTYPE_MATH 1)
endif ()

SET_AND_EXPOSE_TO_BUILD(WTF_PLATFORM_X11 ${ENABLE_X11_TARGET})

if (ENABLE_X11_TARGET)
    find_package(X11 REQUIRED)
    if (NOT X11_Xcomposite_FOUND)
        message(FATAL_ERROR "libXcomposite is required for ENABLE_X11_TARGET")
    elseif (NOT X11_Xrender_FOUND)
        message(FATAL_ERROR "libXrender is required for ENABLE_X11_TARGET")
    endif ()
endif ()

if (NOT ENABLE_VIDEO)
    if (NOT ENABLE_WEB_AUDIO)
        set(USE_GSTREAMER OFF) # TODO: What about MEDIA_STREAM?
    endif ()
endif ()

SET_AND_EXPOSE_TO_BUILD(USE_GLIB 1)
find_package(GLIB 2.36 REQUIRED COMPONENTS gio gobject)

# From OptionsGTK.cmake
# FIXME: Refactor to avoid duplication
if (USE_GSTREAMER)
    set(GSTREAMER_COMPONENTS app pbutils)

    if (ENABLE_VIDEO)
        list(APPEND GSTREAMER_COMPONENTS video mpegts tag gl)
    endif ()

    if (ENABLE_WEB_AUDIO)
        list(APPEND GSTREAMER_COMPONENTS audio fft)
    endif ()

    find_package(GStreamer 1.0.3 REQUIRED COMPONENTS ${GSTREAMER_COMPONENTS})

    if (ENABLE_WEB_AUDIO)
        if (NOT PC_GSTREAMER_AUDIO_FOUND OR NOT PC_GSTREAMER_FFT_FOUND)
            message(FATAL_ERROR "WebAudio requires the audio and fft GStreamer libraries. Please check your gst-plugins-base installation.")
        else ()
            SET_AND_EXPOSE_TO_BUILD(USE_WEBAUDIO_GSTREAMER TRUE)
        endif ()
    endif ()

    if (ENABLE_VIDEO)
        if (NOT PC_GSTREAMER_APP_FOUND OR NOT PC_GSTREAMER_PBUTILS_FOUND OR NOT PC_GSTREAMER_TAG_FOUND OR NOT PC_GSTREAMER_VIDEO_FOUND)
            message(FATAL_ERROR "Video playback requires the following GStreamer libraries: app, pbutils, tag, video. Please check your gst-plugins-base installation.")
        endif ()
    endif ()

    if (USE_GSTREAMER_MPEGTS)
        if (NOT PC_GSTREAMER_MPEGTS_FOUND)
            message(FATAL_ERROR "GStreamer MPEG-TS is needed for USE_GSTREAMER_MPEGTS.")
        endif ()
    endif ()

    if (USE_GSTREAMER_GL)
        if (NOT PC_GSTREAMER_GL_FOUND)
            message(FATAL_ERROR "GStreamerGL is needed for USE_GSTREAMER_GL.")
        endif ()
    endif ()
endif ()

if (USE_LIBHYPHEN)
    find_package(Hyphen REQUIRED)
    if (NOT HYPHEN_FOUND)
       message(FATAL_ERROR "libhyphen is needed for USE_LIBHYPHEN.")
    endif ()
endif ()

# You can build JavaScriptCore as a static library if you specify it as STATIC
# set(JavaScriptCore_LIBRARY_TYPE STATIC)

if (NOT RUBY_FOUND AND RUBY_EXECUTABLE AND NOT RUBY_VERSION VERSION_LESS 1.9)
    get_property(_packages_found GLOBAL PROPERTY PACKAGES_FOUND)
    list(APPEND _packages_found Ruby)
    set_property(GLOBAL PROPERTY PACKAGES_FOUND ${_packages_found})

    get_property(_packages_not_found GLOBAL PROPERTY PACKAGES_NOT_FOUND)
    list(REMOVE_ITEM _packages_not_found Ruby)
    set_property(GLOBAL PROPERTY PACKAGES_NOT_FOUND ${_packages_not_found})
endif ()

set_package_properties(Ruby PROPERTIES TYPE REQUIRED)
feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)


include(ECMQueryQmake)

query_qmake(qt_install_prefix_dir QT_INSTALL_PREFIX)
if (CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set(CMAKE_INSTALL_PREFIX "${qt_install_prefix_dir}" CACHE PATH "Install path prefix, prepended onto install directories." FORCE)
endif ()

include(KDEInstallDirs)

if (NOT qt_install_prefix_dir STREQUAL "${CMAKE_INSTALL_PREFIX}")
    set(KDE_INSTALL_USE_QT_SYS_PATHS OFF)
endif ()

# We split all installed files into 2 components: Code and Data. This is different from
# traditional approach with Runtime and Devel, but we need it to fix concurrent installation of
# debug and release builds in qmake-based build
set(CMAKE_INSTALL_DEFAULT_COMPONENT_NAME "Code")
