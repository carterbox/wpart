cmake_minimum_required(VERSION 2.8)
project( wpart )

# Version Number

set (epipole_VERSION_MAJOR 0)
set (epipole_VERSION_MINOR 0)
set (CMAKE_CXX_FLAGS "-std=c++11")

find_package( OpenCV 2.4.9 REQUIRED )
find_package( Boost 1.55.0 REQUIRED COMPONENTS filesystem system date_time)

if(Boost_FOUND)
  include_directories( ${Boost_INCLUDE_DIRS} )
  add_executable( wpart wpart.cpp )
  target_link_libraries( wpart ${OpenCV_LIBS} )
  target_link_libraries( wpart ${Boost_LIBRARIES} )
endif()

