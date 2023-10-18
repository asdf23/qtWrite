cmake_minimum_required(VERSION 3.16)

project(Writeboard VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.2 REQUIRED COMPONENTS Quick )
# find_package(Qt6 6.2 REQUIRED COMPONENTS QuickControls2 )

# qt_standard_project_setup()
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

qt_add_executable(writeboard
    main.cpp
    fileOperations.cpp
)

qt_add_qml_module(writeboard
    URI Writeboard
    VERSION 1.0
    QML_FILES Main.qml
    RESOURCES "fonts/icons.woff2"
              "scripts/script.js"
              "scripts/simplifyScript.js"
              "scripts/glypabet.js"
              "scripts/sentenceToUseDefs.js"
              "scripts/reversePath.js"
)

set_target_properties(writeboard PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER my.example.com
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(writeboard
    PRIVATE Qt6::Quick
)
# target_link_libraries(writeboard PRIVATE Qt6::Gui Qt6::Quick)
# target_link_libraries(writeboard PRIVATE Qt6::Quick Qt6::QuickControls2)

install(TARGETS writeboard
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})
