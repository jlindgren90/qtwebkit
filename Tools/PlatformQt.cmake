remove_definitions(-DQT_ASCII_CAST_WARNINGS)

add_subdirectory(QtTestBrowser)

if (ENABLE_TEST_SUPPORT)
    add_subdirectory(DumpRenderTree)
    add_subdirectory(ImageDiff)
endif ()
