#include "parse.hpp"
#include "stack.hpp"

#include <opencv2/opencv.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/gpu/gpu.hpp>
#include <boost/filesystem.hpp>
#include <boost/thread.hpp>
#include <boost/date_time.hpp>

using namespace cv;
using namespace std;
using namespace boost::filesystem;

const unsigned maxNumThreads = 8;
unsigned chunkSize = 10;
boost::mutex imstackMutex;

void workerFunc( vector<myslice>* imstack, params* profile, int* i );

int main( int argc, char** argv )
{
	params* profile = parseInputs( argc, argv );
	
	vector<myslice> imstack = createStack( *profile );
	
	//for(int i = 0; i < maxNumThreads; i++)
	//{}
	cout << "Processing " << imstack.size() << " slices..." << endl;
	int zero = 0;
	int* mark = &zero;
	
	boost::thread workerThread( workerFunc, &imstack, profile, mark ); 
	workerThread.join();
	
	//namedWindow("before", CV_WINDOW_NORMAL);
	//namedWindow("after", CV_WINDOW_NORMAL);
	//imshow("before", slice32);
	//imshow("after", slice8);
	//waitKey(0);
	
	delete profile;
	cout << "SUCCESS." << endl;
}

void workerFunc( vector<myslice>* imstack, params* profile, int* i )
//Picks up a stack of myslices to process then goes back for more.
{
	cout << "Starting thread " << *i << " ..." << endl;
	bool done = false;
	vector<myslice> thisstack;
	
	while (!done)
	{
	imstackMutex.lock();
		if( *i > imstack->size() - 1 )
		{
			done = true;
			//cout << "done = true" << endl;
		}
		else 
		{
			//printf("Chunk starts at %i out of %li \n", *i, imstack->size());
			if( *i + chunkSize > imstack->size())
				chunkSize = imstack->size() - *i;
			thisstack = vector<myslice> ( imstack->begin() + *i, imstack->begin() + *i + chunkSize );
			*i += chunkSize;
			//printf("Chunk has %li elements.\n", thisstack.size());
		}
	imstackMutex.unlock();
	
		for(int i = 0; i < thisstack.size(); i++)
		{
			path thisname = thisstack[i].source;
			//cout << thisname << endl;
			Mat temp32 = imread( thisname.native(), CV_LOAD_IMAGE_GRAYSCALE );
			Mat temp8 = sampleRotCrop( temp32, profile );
		
			thisname = profile->out / thisname.filename().replace_extension(".bmp");
			//cout << thisname << endl;
			imwrite( thisname.native(), temp8 );
		}
	}
	cout << "THREAD " << *i << " DONE." << endl;
	return;	
}
