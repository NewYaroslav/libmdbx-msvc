cmake_minimum_required(VERSION 3.18)

option(BUILD_MDBX_DLL "Build libmdbx.dll using MinGW" OFF)
option(BUILD_TEST_PROGRAM "Build test program using MSVC and prebuilt mdbx.lib/dll" OFF)

if(BUILD_MDBX_DLL)
    project(mdbx_dll VERSION 1.0 LANGUAGES C)

    add_subdirectory(external/libmdbx)
    
    target_link_options(mdbx PRIVATE -static-libgcc -static-libstdc++)
    
    set_target_properties(mdbx PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
        LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
        ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
    )
    
    set(src "${CMAKE_SOURCE_DIR}/external/libmdbx/mdbx.h")
    set(dst "${CMAKE_BINARY_DIR}/include/mdbx.h")

    file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/include")
    file(COPY "${src}" DESTINATION "${CMAKE_BINARY_DIR}/include")
    message(STATUS "Installed mdbx.h to ${CMAKE_BINARY_DIR}/include")
endif()

if(BUILD_TEST_PROGRAM)
    project(mdbx_test VERSION 1.0 LANGUAGES C CXX)

    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

    include_directories(${CMAKE_BINARY_DIR}/include)
    link_directories(${CMAKE_BINARY_DIR}/lib)

    add_executable(mdbx_test test/mdbx_test.cpp)
    add_library(mdbx SHARED IMPORTED)
	set_target_properties(mdbx PROPERTIES
		IMPORTED_LOCATION "${CMAKE_BINARY_DIR}/bin/mdbx.dll"
		IMPORTED_IMPLIB "${CMAKE_BINARY_DIR}/lib/mdbx.lib"
	)

	target_link_libraries(mdbx_test mdbx)

    add_custom_command(TARGET mdbx_test POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${CMAKE_BINARY_DIR}/bin/libmdbx.dll"
        "$<TARGET_FILE_DIR:mdbx_test>"
    )
endif()