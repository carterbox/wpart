cmake_minimum_required(VERSION 2.8)
project( wpart )

# Version Number
set (epipole_VERSION_MAJOR 0)
set (epipole_VERSION_MINOR 0)
set (CMAKE_CXX_FLAGS "-std=c++11")


# Finding Packages
find_package( OpenCV 2.4.9 REQUIRED )
find_package( Boost 1.55.0 REQUIRED COMPONENTS filesystem system date_time thread)

if(Boost_FOUND)
  include_directories( ${Boost_INCLUDE_DIRS} )
  add_executable( wpart main.cpp )
  target_link_libraries( wpart ${OpenCV_LIBS} )
  target_link_libraries( wpart ${Boost_LIBRARIES} )
endif()

# Including Headers
include_directories("${CMAKE_SOURCE_DIR}/include")
