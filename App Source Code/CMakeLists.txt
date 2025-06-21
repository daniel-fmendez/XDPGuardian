cmake_minimum_required(VERSION 3.16)

set(CMAKE_C_COMPILER gcc)
set(CMAKE_CXX_COMPILER g++)
project(XDPGuardian VERSION 0.1 LANGUAGES C CXX)


set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
add_compile_options(-Wall -O0)
add_definitions(-DPACKED_STRUCTS)

find_package(Qt6 REQUIRED COMPONENTS Quick Gui Widgets Charts)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(XDPGuardian
    main.cpp
)

qt_add_qml_module(XDPGuardian
    URI NetFilterWin
    VERSION 1.0
    QML_FILES
        Main.qml
        QML_FILES Style/Style.qml
        RESOURCES Style/qmldir
        SOURCES tabipmodel.h tabipmodel.cpp
        SOURCES ipentry.h ipentry.cpp
        QML_FILES Tag.qml
        SOURCES logtablemodel.h logtablemodel.cpp
        SOURCES TagHelper.h
        QML_FILES Screens/RuleScreen.qml
        QML_FILES Screens/LogScreen.qml
        QML_FILES CustomComponents/CustomMenu.qml
        QML_FILES CustomComponents/CustomMenuItem.qml
        QML_FILES CustomComponents/CustomBox.qml
        QML_FILES Screens/AnalysisScreen.qml
        QML_FILES Screens/NetworkInterfacesList.qml
        QML_FILES Screens/RuleSetList.qml
        QML_FILES Screens/MetricsScreen.qml
        SOURCES networkinterfacesmodel.h networkinterfacesmodel.cpp
        SOURCES networkinterfacesmodel.h networkinterfacesmodel.cpp
        QML_FILES Screens/PopUps/NewRuleSetPopUp.qml
        SOURCES Network/rulemodel.h Network/rulemodel.cpp
        SOURCES Network/rulesetmodel.h Network/rulesetmodel.cpp
        SOURCES Network/interfacemodel.h Network/interfacemodel.cpp
        QML_FILES Screens/PopUps/NewRulePopUp.qml
        SOURCES Network/selectionmanager.h Network/selectionmanager.cpp
        QML_FILES Screens/PopUps/EditRuleSetPopup.qml
        QML_FILES Screens/PopUps/EditRulePopup.qml
        QML_FILES CustomComponents/PortTag.qml
        QML_FILES Screens/PopUps/AddPortPopup.qml
        SOURCES Network/protocolmodel.h Network/protocolmodel.cpp
        SOURCES Filter/filteringmanager.h Filter/filteringmanager.cpp
        SOURCES exportimporthelper.h exportimporthelper.cpp
        QML_FILES CustomComponents/AnalysisComponents/ProtChart.qml
        SOURCES Network/uniqueidprovider.h Network/uniqueidprovider.cpp
        QML_FILES CustomComponents/AnalysisComponents/TestComponent.qml
        QML_FILES CustomComponents/AnalysisComponents/PacketDistribution.qml
        QML_FILES CustomComponents/AnalysisComponents/TcpFlags.qml
        QML_FILES CustomComponents/AnalysisComponents/TopPortActivity.qml
        QML_FILES CustomComponents/AnalysisComponents/TopSourceIp.qml
        QML_FILES CustomComponents/AnalysisComponents/TopRules.qml
        SOURCES
        SOURCES
        SOURCES Filter/flagmodel.h Filter/flagmodel.cpp
        SOURCES Filter/dumpmetricsfunctions.h Filter/dumpmetricsfunctions.cpp
        SOURCES Filter/analysisfunctions.h Filter/analysisfunctions.cpp
        SOURCES Filter/protpiemodel.h Filter/protpiemodel.cpp
        SOURCES Filter/iphitsmodel.h Filter/iphitsmodel.cpp
        SOURCES Filter/porthitsmodel.h Filter/porthitsmodel.cpp
        SOURCES Filter/packetdistmodel.h Filter/packetdistmodel.cpp
        SOURCES Filter/rulehitmodel.h Filter/rulehitmodel.cpp
        SOURCES Filter/blockedfromfiltermodel.h Filter/blockedfromfiltermodel.cpp
        RESOURCES resources.qrc
)

qt_add_resources(XDPGuardian RESOURCES
    PREFIX
        "/"
    FILES
        icons/icon.png
        icons/icon.ico
)
target_sources(XDPGuardian PRIVATE ${RESOURCES})
# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(XDPGuardian PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appNetFilterBackup
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)




# Buscar las librerías de BPF
find_path(LIBBPF_INCLUDE_DIRS NAMES bpf/libbpf.h bpf/bpf.h)
find_library(LIBBPF_LIBRARIES NAMES bpf libbpf)

# Verificar si las librerías fueron encontradas
if(NOT LIBBPF_INCLUDE_DIRS OR NOT LIBBPF_LIBRARIES)
    message(FATAL_ERROR "No se encontraron las librerías de BPF")
endif()
# Añadir los directorios de inclusión a tu proyecto
include_directories(${LIBBPF_INCLUDE_DIRS})

target_link_libraries(XDPGuardian
    PRIVATE Qt6::Quick
    PRIVATE Qt6::Quick
    PRIVATE Qt6::Gui
    PRIVATE Qt6::Widgets
    PRIVATE Qt6::Charts
    PRIVATE ${LIBBPF_LIBRARIES}

)

include(GNUInstallDirs)
install(TARGETS XDPGuardian
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
