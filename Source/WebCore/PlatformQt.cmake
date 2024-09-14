include(platform/ImageDecoders.cmake)
include(platform/Linux.cmake)

if (JPEG_DEFINITIONS)
    add_definitions(${JPEG_DEFINITIONS})
endif ()

list(APPEND WebCore_INCLUDE_DIRECTORIES
    "${DERIVED_SOURCES_JAVASCRIPTCORE_DIR}"
    "${DERIVED_SOURCES_JAVASCRIPTCORE_DIR}/inspector"
    "${JAVASCRIPTCORE_DIR}"
    "${JAVASCRIPTCORE_DIR}/ForwardingHeaders"
    "${JAVASCRIPTCORE_DIR}/API"
    "${JAVASCRIPTCORE_DIR}/assembler"
    "${JAVASCRIPTCORE_DIR}/bytecode"
    "${JAVASCRIPTCORE_DIR}/bytecompiler"
    "${JAVASCRIPTCORE_DIR}/dfg"
    "${JAVASCRIPTCORE_DIR}/disassembler"
    "${JAVASCRIPTCORE_DIR}/domjit"
    "${JAVASCRIPTCORE_DIR}/heap"
    "${JAVASCRIPTCORE_DIR}/debugger"
    "${JAVASCRIPTCORE_DIR}/interpreter"
    "${JAVASCRIPTCORE_DIR}/jit"
    "${JAVASCRIPTCORE_DIR}/llint"
    "${JAVASCRIPTCORE_DIR}/parser"
    "${JAVASCRIPTCORE_DIR}/profiler"
    "${JAVASCRIPTCORE_DIR}/runtime"
    "${JAVASCRIPTCORE_DIR}/yarr"
    "${THIRDPARTY_DIR}/ANGLE/"
    "${THIRDPARTY_DIR}/ANGLE/include/KHR"
    "${WEBCORE_DIR}/Modules/gamepad"
    "${WEBCORE_DIR}/bridge/qt"
    "${WEBCORE_DIR}/dom/qt"
    "${WEBCORE_DIR}/editing/qt"
    "${WEBCORE_DIR}/history/qt"
    "${WEBCORE_DIR}/page/qt"
    "${WEBCORE_DIR}/platform/qt"
    "${WEBCORE_DIR}/platform/audio/qt"
    "${WEBCORE_DIR}/platform/cairo"
    "${WEBCORE_DIR}/platform/graphics/cairo"
    "${WEBCORE_DIR}/platform/graphics/egl"
    "${WEBCORE_DIR}/platform/graphics/glx"
    "${WEBCORE_DIR}/platform/graphics/freetype"
    "${WEBCORE_DIR}/platform/graphics/harfbuzz/"
    "${WEBCORE_DIR}/platform/graphics/harfbuzz/ng"
    "${WEBCORE_DIR}/platform/graphics/opengl"
    "${WEBCORE_DIR}/platform/graphics/opentype"
    "${WEBCORE_DIR}/platform/network/soup"
    "${WEBCORE_DIR}/platform/text/qt"
    "${WEBCORE_DIR}/platform/graphics/x11"
    "${WTF_DIR}"
)

list(APPEND WebCore_SOURCES
    accessibility/qt/AccessibilityObjectQt.cpp

    bindings/js/ScriptControllerQt.cpp

    bridge/qt/qt_class.cpp
    bridge/qt/qt_instance.cpp
    bridge/qt/qt_runtime.cpp

    editing/qt/EditorQt.cpp

    loader/soup/CachedRawResourceSoup.cpp
    loader/soup/SubresourceLoaderSoup.cpp

    page/qt/DragControllerQt.cpp
    page/qt/EventHandlerQt.cpp

    platform/KillRingNone.cpp

    platform/audio/qt/AudioBusQt.cpp

    platform/crypto/qt/CryptoDigestQt.cpp

    platform/graphics/ImageSource.cpp
    platform/graphics/PlatformDisplay.cpp
    platform/graphics/WOFFFileFormat.cpp

    platform/graphics/cairo/BackingStoreBackendCairoImpl.cpp
    platform/graphics/cairo/BackingStoreBackendCairoX11.cpp
    platform/graphics/cairo/CairoUtilities.cpp
    platform/graphics/cairo/FloatRectCairo.cpp
    platform/graphics/cairo/FontCairo.cpp
    platform/graphics/cairo/FontCairoHarfbuzzNG.cpp
    platform/graphics/cairo/GradientCairo.cpp
    platform/graphics/cairo/GraphicsContext3DCairo.cpp
    platform/graphics/cairo/GraphicsContextCairo.cpp
    platform/graphics/cairo/ImageBufferCairo.cpp
    platform/graphics/cairo/ImageCairo.cpp
    platform/graphics/cairo/IntRectCairo.cpp
    platform/graphics/cairo/NativeImageCairo.cpp
    platform/graphics/cairo/PathCairo.cpp
    platform/graphics/cairo/PatternCairo.cpp
    platform/graphics/cairo/PlatformContextCairo.cpp
    platform/graphics/cairo/PlatformPathCairo.cpp
    platform/graphics/cairo/RefPtrCairo.cpp
    platform/graphics/cairo/TransformationMatrixCairo.cpp

    platform/graphics/freetype/FontCacheFreeType.cpp
    platform/graphics/freetype/FontCustomPlatformDataFreeType.cpp
    platform/graphics/freetype/FontPlatformDataFreeType.cpp
    platform/graphics/freetype/GlyphPageTreeNodeFreeType.cpp
    platform/graphics/freetype/SimpleFontDataFreeType.cpp

    platform/graphics/gstreamer/ImageGStreamerCairo.cpp

    platform/graphics/harfbuzz/HarfBuzzFace.cpp
    platform/graphics/harfbuzz/HarfBuzzFaceCairo.cpp
    platform/graphics/harfbuzz/HarfBuzzShaper.cpp

    platform/graphics/opentype/OpenTypeVerticalData.cpp

    platform/graphics/qt/IconQt.cpp
    platform/graphics/qt/ImageQt.cpp

    platform/graphics/x11/PlatformDisplayX11.cpp
    platform/graphics/x11/XUniqueResource.cpp

    platform/image-decoders/cairo/ImageBackingStoreCairo.cpp

    platform/network/soup/AuthenticationChallengeSoup.cpp
    platform/network/soup/CertificateInfo.cpp
    platform/network/soup/CookieJarSoup.cpp
    platform/network/soup/CookieStorageSoup.cpp
    platform/network/soup/CredentialStorageSoup.cpp
    platform/network/soup/DNSSoup.cpp
    platform/network/soup/GRefPtrSoup.cpp
    platform/network/soup/NetworkStorageSessionSoup.cpp
    platform/network/soup/ProxyServerSoup.cpp
    platform/network/soup/ResourceErrorSoup.cpp
    platform/network/soup/ResourceHandleSoup.cpp
    platform/network/soup/ResourceRequestSoup.cpp
    platform/network/soup/ResourceResponseSoup.cpp
    platform/network/soup/SocketStreamHandleImplSoup.cpp
    platform/network/soup/SoupNetworkSession.cpp
    platform/network/soup/SynchronousLoaderClientSoup.cpp
    platform/network/soup/WebKitSoupRequestGeneric.cpp

    platform/qt/CursorQt.cpp
    platform/qt/DataTransferItemListQt.cpp
    platform/qt/DataTransferItemQt.cpp
    platform/qt/DragDataQt.cpp
    platform/qt/DragImageQt.cpp
    platform/qt/EventLoopQt.cpp
    platform/qt/FileSystemQt.cpp
    platform/qt/KeyedDecoderQt.cpp
    platform/qt/KeyedEncoderQt.cpp
    platform/qt/LanguageQt.cpp
    platform/qt/LocalizedStringsQt.cpp
    platform/qt/LoggingQt.cpp
    platform/qt/MainThreadSharedTimerQt.cpp
    platform/qt/MIMETypeRegistryQt.cpp
    platform/qt/PasteboardQt.cpp
    platform/qt/PlatformKeyboardEventQt.cpp
    platform/qt/PlatformScreenQt.cpp
    platform/qt/RenderThemeQStyle.cpp
    platform/qt/RenderThemeQt.cpp
    platform/qt/RenderThemeQtMobile.cpp
    platform/qt/ScrollViewQt.cpp
    platform/qt/ScrollbarThemeQStyle.cpp
    platform/qt/ScrollbarThemeQt.cpp
    platform/qt/SharedBufferQt.cpp
    platform/qt/SoundQt.cpp
    platform/qt/TemporaryLinkStubsQt.cpp
    platform/qt/URLQt.cpp
    platform/qt/UserAgentQt.cpp
    platform/qt/WidgetQt.cpp

    platform/soup/PublicSuffixSoup.cpp
    platform/soup/SharedBufferSoup.cpp
    platform/soup/URLSoup.cpp

    platform/text/Hyphenation.cpp
    platform/text/LocaleICU.cpp

    platform/text/hyphen/HyphenationLibHyphen.cpp
)

QTWEBKIT_GENERATE_MOC_FILES_CPP(WebCore
    platform/qt/MainThreadSharedTimerQt.cpp
)

# Note: Qt5Gui_INCLUDE_DIRS includes Qt5Core_INCLUDE_DIRS
list(APPEND WebCore_SYSTEM_INCLUDE_DIRECTORIES
    ${CAIRO_INCLUDE_DIRS}
    ${FREETYPE2_INCLUDE_DIRS}
    ${GIO_UNIX_INCLUDE_DIRS}
    ${GLIB_INCLUDE_DIRS}
    ${HARFBUZZ_INCLUDE_DIRS}
    ${HYPHEN_INCLUDE_DIR}
    ${LIBSOUP_INCLUDE_DIRS}
    ${LIBXML2_INCLUDE_DIR}
    ${LIBXSLT_INCLUDE_DIR}
    ${Qt5Gui_INCLUDE_DIRS}
    ${Qt5Gui_PRIVATE_INCLUDE_DIRS}
    ${SQLITE_INCLUDE_DIR}
    ${ZLIB_INCLUDE_DIRS}
)

list(APPEND WebCore_LIBRARIES
    ${CAIRO_LIBRARIES}
    ${FONTCONFIG_LIBRARIES}
    ${FREETYPE2_LIBRARIES}
    ${GLIB_GIO_LIBRARIES}
    ${GLIB_GOBJECT_LIBRARIES}
    ${GLIB_LIBRARIES}
    ${HARFBUZZ_LIBRARIES}
    ${HYPHEN_LIBRARIES}
    ${LIBSOUP_LIBRARIES}
    ${LIBXML2_LIBRARIES}
    ${LIBXSLT_LIBRARIES}
    ${Qt5Core_LIBRARIES}
    ${Qt5Gui_LIBRARIES}
    ${SQLITE_LIBRARIES}
    ${X11_X11_LIB}
    ${ZLIB_LIBRARIES}
)

list(APPEND WebCore_USER_AGENT_STYLE_SHEETS
#    ${WEBCORE_DIR}/css/mediaControlsGtk.css
#    ${WEBCORE_DIR}/css/mediaControlsQt.css
#    ${WEBCORE_DIR}/css/mediaControlsQtFullscreen.css
    ${WEBCORE_DIR}/css/mobileThemeQt.css
    ${WEBCORE_DIR}/css/themeQtNoListboxes.css
)

if (USE_GSTREAMER)
    include(platform/GStreamer.cmake)
endif ()

if (ENABLE_VIDEO)
    list(APPEND WebCore_USER_AGENT_STYLE_SHEETS
        ${WEBCORE_DIR}/Modules/mediacontrols/mediaControlsBase.css
    )
    set(WebCore_USER_AGENT_SCRIPTS
        ${WEBCORE_DIR}/English.lproj/mediaControlsLocalizedStrings.js
        ${WEBCORE_DIR}/Modules/mediacontrols/mediaControlsBase.js
    )
    set(WebCore_USER_AGENT_SCRIPTS_DEPENDENCIES ${WEBCORE_DIR}/platform/qt/RenderThemeQt.cpp)
endif ()

# Build the include path with duplicates removed
list(REMOVE_DUPLICATES WebCore_SYSTEM_INCLUDE_DIRECTORIES)

# TODO: Think how to unify fwd headers handling throughout WebKit
set(WebCore_FORWARDING_HEADERS_DIRECTORIES
    bridge
    dom
    history
    html
    loader
    page
    platform
    rendering
    storage

    Modules/indexeddb/legacy
    Modules/indexeddb/shared

    bindings/js

    bridge/c
    bridge/jsc

    platform/graphics
    platform/network
    platform/sql
    platform/text

    platform/network/soup
)

WEBKIT_CREATE_FORWARDING_HEADERS(WebCore DIRECTORIES ${WebCore_FORWARDING_HEADERS_DIRECTORIES} FILES ${WebCore_FORWARDING_HEADERS_FILES})

list(APPEND WebCoreTestSupport_LIBRARIES
    WebCore
)

if (HAVE_FONTCONFIG)
    list(APPEND WebCoreTestSupport_LIBRARIES
        ${FONTCONFIG_LIBRARIES}
    )
endif ()

# From PlatformEfl.cmake
add_custom_command(
    OUTPUT ${DERIVED_SOURCES_WEBCORE_DIR}/WebKitVersion.h
    MAIN_DEPENDENCY ${WEBKIT_DIR}/scripts/generate-webkitversion.pl
    DEPENDS ${WEBKIT_DIR}/mac/Configurations/Version.xcconfig
    COMMAND ${PERL_EXECUTABLE} ${WEBKIT_DIR}/scripts/generate-webkitversion.pl --config ${WEBKIT_DIR}/mac/Configurations/Version.xcconfig --outputDir ${DERIVED_SOURCES_WEBCORE_DIR}
    VERBATIM)
list(APPEND WebCore_SOURCES ${DERIVED_SOURCES_WEBCORE_DIR}/WebKitVersion.h)
