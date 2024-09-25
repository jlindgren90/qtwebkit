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

include(GStreamerDefinitions)

# Public options specific to the Qt port. Do not add any options here unless
# there is a strong reason we should support changing the value of the option,
# and the option is not relevant to any other WebKit ports.
WEBKIT_OPTION_DEFINE(USE_LIBHYPHEN "Use automatic hyphenation with LibHyphen" PUBLIC ON)
WEBKIT_OPTION_DEFINE(ENABLE_INSPECTOR_UI "Include Inspector UI into resources" PUBLIC ON)

option(GENERATE_DOCUMENTATION "Generate HTML and QCH documentation" OFF)

# Public options shared with other WebKit ports. There must be strong reason
# to support changing the value of the option.
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_ACCELERATED_2D_CANVAS PUBLIC OFF) # GL disabled
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_API_TESTS PUBLIC OFF) # FIXME: tests disabled
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_DATALIST_ELEMENT PUBLIC ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_DEVICE_ORIENTATION PUBLIC OFF)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_FULLSCREEN_API PUBLIC ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_INDEXED_DATABASE PUBLIC ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_MEDIA_SOURCE PUBLIC ON)
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
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_WEB_AUDIO PUBLIC ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(USE_SYSTEM_MALLOC PUBLIC OFF)

# Private options shared with other WebKit ports. Add options here when
# we need a value different from the default defined in WebKitFeatures.cmake.
# Changing these options is completely unsupported.
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_3D_TRANSFORMS PRIVATE OFF) # GL disabled
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_CSS_COMPOSITING PRIVATE ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_CSS_SELECTORS_LEVEL4 PRIVATE ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_DOWNLOAD_ATTRIBUTE PRIVATE ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_FTPDIR PRIVATE OFF)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_INPUT_TYPE_COLOR PRIVATE ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_MEDIA_CONTROLS_SCRIPT PRIVATE ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_MHTML PRIVATE ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_NOTIFICATIONS PRIVATE ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_REMOTE_INSPECTOR PRIVATE OFF)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_SMOOTH_SCROLLING PRIVATE OFF)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_SUBTLE_CRYPTO PRIVATE OFF)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_USERSELECT_ALL PRIVATE ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_VIDEO_TRACK PRIVATE ON)
WEBKIT_OPTION_DEFAULT_PORT_VALUE(ENABLE_WEBGL PRIVATE OFF) # GL disabled

# Building video without these options is not supported
WEBKIT_OPTION_DEPEND(ENABLE_VIDEO ENABLE_VIDEO_TRACK)
WEBKIT_OPTION_DEPEND(ENABLE_VIDEO ENABLE_MEDIA_CONTROLS_SCRIPT)

include(GStreamerDependencies)

WEBKIT_OPTION_END()

set(ENABLE_WEBKIT_LEGACY ON)
set(ENABLE_WEBKIT OFF)

set(JavaScriptCore_LIBRARY_TYPE STATIC)
set(WebCoreTestSupport_LIBRARY_TYPE STATIC)
set(WebKitLegacy_LIBRARY_TYPE SHARED)
set(WebKitWidgets_LIBRARY_TYPE SHARED)
set(WTF_LIBRARY_TYPE STATIC)

find_package(Cairo 1.10.2 REQUIRED)
find_package(Fontconfig 2.8.0 REQUIRED)
find_package(Freetype2 2.4.2 REQUIRED)
find_package(GLIB 2.40.0 REQUIRED COMPONENTS gio gio-unix gobject gthread gmodule)
find_package(HarfBuzz 0.9.18 REQUIRED)
find_package(ICU REQUIRED)
find_package(JPEG REQUIRED)
find_package(LibGcrypt 1.6.0 REQUIRED)
find_package(LibSoup 2.42.0 REQUIRED)
find_package(LibXml2 2.8.0 REQUIRED)
find_package(LibXslt 1.1.7 REQUIRED)
find_package(PNG REQUIRED)
find_package(Qt5 5.15.0 REQUIRED COMPONENTS Core Gui Network Widgets)
find_package(Sqlite REQUIRED)
find_package(Threads REQUIRED)
find_package(WebP REQUIRED)
find_package(ZLIB REQUIRED)

SET_AND_EXPOSE_TO_BUILD(USE_CAIRO ON)
SET_AND_EXPOSE_TO_BUILD(USE_GSTREAMER_GL OFF)

option(USE_LINKER_VERSION_SCRIPT "Use linker script for ABI compatibility with Qt libraries" ON)

# Find includes in corresponding build directories
set(CMAKE_INCLUDE_CURRENT_DIR ON)

# TODO: figure out if we can run automoc only on Qt sources

# From OptionsEfl.cmake
# Optimize binary size for release builds by removing dead sections on unix/gcc.
set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -ffunction-sections -fdata-sections")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -ffunction-sections -fdata-sections")
set(CMAKE_SHARED_LINKER_FLAGS_RELEASE "${CMAKE_SHARED_LINKER_FLAGS_RELEASE} -Wl,--gc-sections")
set(CMAKE_C_FLAGS "-fvisibility=hidden ${CMAKE_C_FLAGS}")
set(CMAKE_CXX_FLAGS "-fvisibility=hidden -fvisibility-inlines-hidden ${CMAKE_CXX_FLAGS}")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,--no-undefined")

# FIXME: remove once deprecations are addressed
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-deprecated")

if (ENABLE_MATHML)
    SET_AND_EXPOSE_TO_BUILD(ENABLE_OPENTYPE_MATH 1)
endif ()

include(GStreamerChecks)

if (USE_LIBHYPHEN)
    find_package(Hyphen REQUIRED)
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
