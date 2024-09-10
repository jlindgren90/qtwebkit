if (${JavaScriptCore_LIBRARY_TYPE} MATCHES STATIC)
    add_definitions(-DSTATICALLY_LINKED_WITH_WTF)
endif ()

list(APPEND JavaScriptCore_INCLUDE_DIRECTORIES
    ${WTF_DIR}
)

list(APPEND JavaScriptCore_SOURCES
    API/JSStringRefQt.cpp
)

list(APPEND JavaScriptCore_SYSTEM_INCLUDE_DIRECTORIES
    ${GLIB_INCLUDE_DIRS}
    ${Qt5Core_INCLUDE_DIRS}
)

list(APPEND JavaScriptCore_LIBRARIES
    ${GLIB_GOBJECT_LIBRARIES}
    ${GLIB_LIBRARIES}
    ${Qt5Core_LIBRARIES}
)
