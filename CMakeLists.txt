project(openfoodfacts C CXX)
cmake_minimum_required(VERSION 2.8.9)

find_program(INTLTOOL_MERGE intltool-merge)
if(NOT INTLTOOL_MERGE)
    message(FATAL_ERROR "Could not find intltool-merge, please install the intltool package")
endif()
find_program(INTLTOOL_EXTRACT intltool-extract)
if(NOT INTLTOOL_EXTRACT)
    message(FATAL_ERROR "Could not find intltool-extract, please install the intltool package")
endif()

# Do not remove this line, its required for the correct functionality of the Ubuntu-SDK
set(UBUNTU_MANIFEST_PATH "manifest.json.in" CACHE INTERNAL "Tells QtCreator location and name of the manifest file")
set (CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

find_package(Qt5Core)
find_package(Qt5Qml)
find_package(Qt5Quick)
# find_package(ubuntu-sdk-libs)

# Automatically create moc files
set(CMAKE_AUTOMOC ON)

# Components PATH
execute_process(
    COMMAND dpkg-architecture -qDEB_HOST_MULTIARCH
    OUTPUT_VARIABLE ARCH_TRIPLET
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

set(QT_IMPORTS_DIR "lib/${ARCH_TRIPLET}")

option(INSTALL_TESTS "Install the tests on make install" on)

set(APP_NAME          openfoodfacts)
set(APP_ID            "openfoodfacts.ubuntouch")
set(OPENFOODFACTS_DIR "share/qml/openfoodfacts")
set(MAIN_QML          "Main.qml")
set(ICON              "graphics/openfoodfacts.png")

# Set install paths
set(CMAKE_INSTALL_PREFIX /)
set(DATA_DIR /)
set(DESKTOP_DIR ${DATA_DIR})
set(DESKTOP_FILE_NAME "OpenFoodFacts.desktop")

set(EXEC "qmlscene $@ ${OPENFOODFACTS_DIR}/${MAIN_QML}")

# This command figures out the target architecture for use in the manifest file
execute_process(
  COMMAND dpkg-architecture -qDEB_HOST_ARCH
  OUTPUT_VARIABLE CLICK_ARCH
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

execute_process(
  COMMAND cp
  /usr/lib/libzbar.so.0
  /usr/lib/arm-linux-gnueabihf/libqrencode.so
  /usr/lib/arm-linux-gnueabihf/libqrencode.so.3
  /usr/lib/arm-linux-gnueabihf/libqrencode.so.3.4.3
  ${CMAKE_BINARY_DIR}
)

configure_file(manifest.json.in ${CMAKE_CURRENT_BINARY_DIR}/manifest.json)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/manifest.json
        DESTINATION ${CMAKE_INSTALL_PREFIX})

install(DIRECTORY "app/graphics" DESTINATION ${DATA_DIR})
install(FILES "OpenFoodFacts.apparmor" DESTINATION ${DATA_DIR})

add_subdirectory(app)
add_subdirectory(backend)
add_subdirectory(po)

add_custom_target("autopilot" chmod +x ${CMAKE_SOURCE_DIR}/app/tests/autopilot/run
                    COMMAND ${CMAKE_SOURCE_DIR}/app/tests/autopilot/run
                    DEPENDS OpenFoodFactsbackend OpenFoodFactsbackend-qmldir
                    WORKING_DIRECTORY ./app)
                    
add_custom_target(${DESKTOP_FILE} ALL
    COMMENT "Merging translations into ${DESKTOP_FILE}"
    COMMAND LC_ALL=C ${INTLTOOL_MERGE} -d -u ${CMAKE_SOURCE_DIR}/po ${DESKTOP_FILE}.in ${DESKTOP_FILE} > /dev/null
)

install(FILES
  "${CMAKE_BINARY_DIR}/libzbar.so.0"
  "${CMAKE_BINARY_DIR}/libqrencode.so"
  "${CMAKE_BINARY_DIR}/libqrencode.so.3"
  "${CMAKE_BINARY_DIR}/libqrencode.so.3.4.3"
DESTINATION lib/${ARCH_TRIPLET})
add_custom_target("check"
                    COMMAND /usr/bin/qmltestrunner -input ${CMAKE_SOURCE_DIR}/backend/tests/unit -import ${CMAKE_BINARY_DIR}/backend
                    COMMAND /usr/bin/qmltestrunner -input ${CMAKE_SOURCE_DIR}/app/tests/unit -import ${CMAKE_BINARY_DIR}/backend
                    DEPENDS OpenFoodFactsbackend OpenFoodFactsbackend-qmldir
                    WORKING_DIRECTORY ./app)

add_custom_target("run" /usr/bin/qmlscene -I ${CMAKE_BINARY_DIR}/backend  ${CMAKE_SOURCE_DIR}/app/Main.qml
                    DEPENDS OpenFoodFactsbackend OpenFoodFactsbackend-qmldir
                    WORKING_DIRECTORY ./app)

# No op custom target for all not compiled files, so they show up in the QtCreator project tree
add_custom_target("openfoodfacts_ClickFiles" ALL SOURCES "OpenFoodFacts.apparmor" "manifest.json.in")

