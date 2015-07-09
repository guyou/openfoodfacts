include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
)

set(
    OpenFoodFactsbackend_SRCS
    modules/OpenFoodFacts/backend.cpp
    modules/OpenFoodFacts/mytype.cpp
)

# Make the unit test files visible on qtcreator
add_custom_target(OpenFoodFactsbackend_UNITTEST_QML_FILES ALL SOURCES "tests/unit/tst_mytype.qml")

add_library(OpenFoodFactsbackend MODULE
    ${OpenFoodFactsbackend_SRCS}
)

set_target_properties(OpenFoodFactsbackend PROPERTIES
         LIBRARY_OUTPUT_DIRECTORY OpenFoodFacts)

qt5_use_modules(OpenFoodFactsbackend Gui Qml Quick)

# Copy qmldir file to build dir for running in QtCreator
add_custom_target(OpenFoodFactsbackend-qmldir ALL
    COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/modules/OpenFoodFacts/qmldir ${CMAKE_CURRENT_BINARY_DIR}/OpenFoodFacts
    DEPENDS ${QMLFILES}
)

# Install plugin file
install(TARGETS OpenFoodFactsbackend DESTINATION ${QT_IMPORTS_DIR}/OpenFoodFacts/)
install(FILES   modules/OpenFoodFacts/qmldir DESTINATION ${QT_IMPORTS_DIR}/OpenFoodFacts/)

