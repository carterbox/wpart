#include <opencv2/opencv.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <boost/filesystem.hpp>
#include <stdio.h>

using namespace cv;
using namespace std;
using namespace boost::filesystem;

struct params {
	path in;
	path out;
	int notch;
	float rotation;
	int x, y;
	int h,w,d;
};

params* parseInputs( int argc, char** argv );

int main( int argc, char** argv )
{
	params* maple = parseInputs( argc, argv ); 
	
}

params* parseInputs( int argc, char** argv )
// pin pout rotation x y h w d
{
	params* thisparams;
	if( argc != 10 )
	{
		perror("Usage: wpart /from/path /to/path rotation notch x y h w d");
	}
	else
	{	
		thisparams = new params; 
		thisparams->in = path(argv[1]);
		thisparams->out = path(argv[2]);
		thisparams->rotation = std::strtof(argv[3], nullptr);
		thisparams->notch = std::stoi(argv[4], nullptr, 10);
		thisparams->x = std::stoi(argv[5], nullptr, 10);
		thisparams->y = std::stoi(argv[6], nullptr, 10);
		thisparams->h = std::stoi(argv[7], nullptr, 10);
		thisparams->w = std::stoi(argv[8], nullptr, 10);
		thisparams->d = std::stoi(argv[9], nullptr, 10);
	}
	CV_Assert( thisparams != NULL );
	return thisparams;
}
