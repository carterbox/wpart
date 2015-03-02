#include <opencv2/opencv.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <boost/filesystem.hpp>
#include <stdio.h>
#include "parse.hpp"

using namespace cv;
using namespace std;
using namespace boost::filesystem;

int main( int argc, char** argv )
{
	params* maple = parseInputs( argc, argv );
	
	
}
