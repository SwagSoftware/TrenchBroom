SET(APP_DIR ${CMAKE_SOURCE_DIR}/app)
SET(APP_SOURCE_DIR ${APP_DIR}/src)
FILE(GLOB_RECURSE APP_SOURCE
    "${APP_SOURCE_DIR}/*.h"
    "${APP_SOURCE_DIR}/*.cpp"
)

# OS X app bundle configuration, must happen before the executable is added
IF(APPLE)
	# Configure icons
    SET(MACOSX_ICON_FILES "${APP_DIR}/resources/graphics/icons/AppIcon.icns" "${APP_DIR}/resources/graphics/icons/DocIcon.icns")
    SET(APP_SOURCE ${APP_SOURCE} ${MACOSX_ICON_FILES})
    SET_SOURCE_FILES_PROPERTIES(${MACOSX_ICON_FILES} PROPERTIES MACOSX_PACKAGE_LOCATION Resources)

	# Configure button bitmaps etc.
	FILE(GLOB_RECURSE MACOSX_IMAGE_FILES
        "${APP_DIR}/resources/graphics/images/*.png"
	)
    SET(APP_SOURCE ${APP_SOURCE} ${MACOSX_IMAGE_FILES})
    SET_SOURCE_FILES_PROPERTIES(${MACOSX_IMAGE_FILES} PROPERTIES MACOSX_PACKAGE_LOCATION Resources/images)

	# Configure game resources
	# Collect all game resources
	FILE(GLOB_RECURSE MACOSX_QUAKE_FILES
        "${APP_DIR}/resources/games/Quake/*.*"
	)
	FILE(GLOB_RECURSE MACOSX_QUAKE2_FILES
        "${APP_DIR}/resources/games/Quake2/*.*"
	)
	FILE(GLOB_RECURSE MACOSX_HEXEN2_FILES
        "${APP_DIR}/resources/games/Hexen2/*.*"
	)
	FILE(GLOB_RECURSE MACOSX_GAME_CONFIG_FILES
        "${APP_DIR}/resources/games/*.cfg"
	)

    SET(APP_SOURCE ${APP_SOURCE} ${MACOSX_QUAKE_FILES} ${MACOSX_QUAKE2_FILES} ${MACOSX_HEXEN2_FILES} ${MACOSX_GAME_CONFIG_FILES})
	SET_SOURCE_FILES_PROPERTIES(${MACOSX_QUAKE_FILES} PROPERTIES  MACOSX_PACKAGE_LOCATION Resources/games/Quake)
	SET_SOURCE_FILES_PROPERTIES(${MACOSX_QUAKE2_FILES} PROPERTIES  MACOSX_PACKAGE_LOCATION Resources/games/Quake2)
	SET_SOURCE_FILES_PROPERTIES(${MACOSX_HEXEN2_FILES} PROPERTIES  MACOSX_PACKAGE_LOCATION Resources/games/Hexen2)
	SET_SOURCE_FILES_PROPERTIES(${MACOSX_GAME_CONFIG_FILES} PROPERTIES  MACOSX_PACKAGE_LOCATION Resources/games)

	# Configure shaders
	# Collect all shaders
	FILE(GLOB_RECURSE MACOSX_SHADER_FILES
        "${APP_DIR}/resources/shader/*.fragsh"
        "${APP_DIR}/resources/shader/*.vertsh"
	)

	SET_SOURCE_FILES_PROPERTIES(${MACOSX_SHADER_FILES} PROPERTIES  MACOSX_PACKAGE_LOCATION Resources/shader)
    SET(APP_SOURCE ${APP_SOURCE} ${MACOSX_SHADER_FILES})
ENDIF()

ADD_EXECUTABLE(TrenchBroom WIN32 MACOSX_BUNDLE ${APP_SOURCE})
TARGET_LINK_LIBRARIES(TrenchBroom glew common ${wxWidgets_LIBRARIES} ${FREETYPE_LIBRARIES} ${FREEIMAGE_LIBRARIES})
SET_TARGET_PROPERTIES(TrenchBroom PROPERTIES COMPILE_DEFINITIONS "GLEW_STATIC")

# Create the cmake script for version management
FIND_PACKAGE(Git)
CONFIGURE_FILE(${CMAKE_SOURCE_DIR}/cmake/Version.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/Version.cmake @ONLY)
ADD_TARGET_PROPERTY(TrenchBroom INCLUDE_DIRECTORIES ${CMAKE_CURRENT_BINARY_DIR})
ADD_CUSTOM_TARGET(version ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/Version.cmake)
ADD_DEPENDENCIES(TrenchBroom version)

# Copy some Windows-specific resources
IF(WIN32)
	# Copy Windows icons to target dir
	ADD_CUSTOM_COMMAND(TARGET TrenchBroom PRE_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy "${APP_DIR}/resources/graphics/icons/TrenchBroom.ico" $CMAKE_CURRENT_BINARY_DIR
        COMMAND ${CMAKE_COMMAND} -E copy "${APP_DIR}/resources/graphics/icons/TrenchBroomDoc.ico" $CMAKE_CURRENT_BINARY_DIR
	)
	
    # Copy DLLs to app directory
	ADD_CUSTOM_COMMAND(TARGET TrenchBroom POST_BUILD
		COMMAND ${CMAKE_COMMAND} -E copy_directory "${LIB_BIN_DIR}/win32" $<TARGET_FILE_DIR:TrenchBroom>
	)
	ADD_CUSTOM_COMMAND(TARGET TrenchBroom-Test POST_BUILD
		COMMAND ${CMAKE_COMMAND} -E copy_directory "${LIB_BIN_DIR}/win32" $<TARGET_FILE_DIR:TrenchBroom-Test>
	)

    # Set up resource compilation for Windows
    IF(MSVC)
        SET(SOURCE ${SOURCE} "${APP_SOURCE_DIR}/TrenchBroom.rc")
    ELSEIF(MINGW)
        SET(CMAKE_RC_COMPILER_INIT windres)
        ENABLE_LANGUAGE(RC)
        SET(CMAKE_RC_COMPILE_OBJECT "<CMAKE_RC_COMPILER> <FLAGS> <DEFINES> -i <SOURCE> -o <OBJECT>")
    ENDIF()
ENDIF()

# Properly link to OpenGL libraries on Linux
IF(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
    FIND_PACKAGE(OpenGL)
    TARGET_LINK_LIBRARIES(TrenchBroom ${OPENGL_LIBRARIES})
ENDIF()

# Set up the resources and DLLs for the executable
IF(WIN32 OR ${CMAKE_SYSTEM_NAME} MATCHES "Linux")
	# Copy button images to resources directory
	ADD_CUSTOM_COMMAND(TARGET TrenchBroom POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory "${APP_DIR}/resources/graphics/images" $<TARGET_FILE_DIR:TrenchBroom>/Resources/images
	)

	# Copy game files to resources directory
	ADD_CUSTOM_COMMAND(TARGET TrenchBroom POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory "${APP_DIR}/resources/games/" $<TARGET_FILE_DIR:TrenchBroom>/Resources/games
	)

	# Copy shader files to resources directory
	ADD_CUSTOM_COMMAND(TARGET TrenchBroom POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory "${APP_DIR}/resources/shader" $<TARGET_FILE_DIR:TrenchBroom>/Resources/shader
	)
ENDIF()

IF(APPLE)
    # Configure plist file
    SET_TARGET_PROPERTIES(TrenchBroom PROPERTIES MACOSX_BUNDLE_INFO_PLIST "${APP_DIR}/resources/mac/TrenchBroom-Info.plist")

    # Configure the XCode generator project
    SET_XCODE_ATTRIBUTES(TrenchBroom)
ENDIF()

# CPack configuration
IF(WIN32)

ELSEIF(APPLE)
    INSTALL(TARGETS TrenchBroom BUNDLE DESTINATION . COMPONENT TrenchBroom)

    GET_APP_VERSION(${APP_DIR} CPACK_PACKAGE_VERSION_MAJOR CPACK_PACKAGE_VERSION_MINOR CPACK_PACKAGE_VERSION_PATCH)
    GET_BUILD_ID("${GIT_EXECUTABLE}" "${CMAKE_SOURCE_DIR}" APP_VERSION_BUILD_ID)
    SET(CPACK_PACKAGE_VERSION "${CPACK_PACKAGE_VERSION_MAJOR}.${CPACK_PACKAGE_VERSION_MINOR}.${CPACK_PACKAGE_VERSION_PATCH}")
    SET(CPACK_PACKAGE_FILE_NAME "TrenchBroom-${CPACK_PACKAGE_VERSION_MAJOR}.${CPACK_PACKAGE_VERSION_MINOR}.${CPACK_PACKAGE_VERSION_PATCH}-${APP_VERSION_BUILD_ID}")

    SET(CPACK_PACKAGE_DESCRIPTION_SUMMARY "TrenchBroom Level Editor")
    SET(CPACK_PACKAGE_VENDOR "Kristian Duske")

    SET(CPACK_GENERATOR "DragNDrop")
ENDIF()
INCLUDE(CPack)
