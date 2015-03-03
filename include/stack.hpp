#ifndef __STACK_HPP_INCLUDED__
#define __STACK_HPP_INLCUDED__

#include "parse.hpp"

#include <opencv2/opencv.hpp>
#include <boost/filesystem.hpp>

using namespace cv;
namespace bfs = boost::filesystem;

struct myslice{
	Mat* data = NULL;
	int i;
	bfs::path source;
};

void swap( vector<myslice>* A, int a, int b )
{
	myslice temp = A->at(a);
	A->at(a) = A->at(b);
	A->at(b) = temp;
	return;
}
	
int partition( vector<myslice>* A, int lo, int hi)
// lo is the index of the leftmost element of the subarray
// hi is the index of the rightmost element of the subarray inclusive
{
	 int pivotIndex = (hi+lo)/2;
     float pivotValue = A->at(pivotIndex).i;
     // put the chosen pivot at A[hi]
     swap( A, pivotIndex, hi );
     
     int storeIndex = lo;
     // Compare remaining array elements against pivotValue = A[hi]
     for( int i = lo; i < hi; i++ )
     {
         if( A->at(i).i < pivotValue)
         {
             swap( A, i, storeIndex );
             storeIndex++;
         }
     }
     swap( A, storeIndex, hi );  // Move pivot to its final place
     return storeIndex;
}

void quicksort(vector<myslice>* A, int lo, int hi)
//sorts the range lo - hi (inclusive) of A. Adapted from Wikipedia article
{
	if( lo < hi )
	{
    	int p = partition(A, lo, hi);
    	quicksort(A, lo, p - 1);
    	quicksort(A, p + 1, hi);
	}
	return;
}

vector<myslice> findtiff( bfs::path p )
//Locates and loads all .tiff files inside path p.
{
	bfs::directory_iterator end;
	int count = 0;
	vector<myslice> imstack;
	
	for( bfs::directory_iterator iter( p ); iter != end; iter++)
	{
		if( bfs::is_directory( iter->path() ))
		{
			//do nothing
		}
		else if(bfs::is_regular_file( iter->path() ))
		{
			if( iter->path().filename().extension().compare(".tif") == 0
				|| iter->path().filename().extension().compare(".tiff") == 0)
			{
				myslice temp = myslice();
				temp.source = iter->path();
				temp.i = parseName( iter->path() );
	
				imstack.push_back( temp );
				//cout << iter->path().filename() << endl;
				count++;
			}
		}
	}	
	assert( imstack.size() == count );
	
	cout << "Found " << count << " files." << endl;
	
	return imstack;
}

Mat sampleRotCrop( Mat in32, const params* profile )
//downsamples a greyscale image to 32bit rotates and crops it accoring to params
{
	CV_Assert( profile != NULL && profile->w > 0 && profile->h > 0
							   && in32.size().width > profile->w
							   && in32.size().height > profile->h );
	
	//rotate the image
	Point center = Point( in32.cols/2, in32.rows/2 );
	Mat rot_mat = getRotationMatrix2D( center, profile->rotation, 1.0 );	
	warpAffine( in32, in32, rot_mat, in32.size(), INTER_CUBIC );

	Mat slice8;
	convertScaleAbs( in32, slice8, 1.0, -79); //converts to 8bit

	//crop the image
	slice8 = Mat( slice8, Rect( profile->x, profile->y, profile->w, profile->h ));
	
	return slice8;
}

vector<myslice> createStack( const params profile )
//creates a stack of the images as described by the profile
{
	//load the filenames and indecies of all the images
	vector<myslice> imstack = findtiff( profile.in );
	quicksort( &imstack, 0, imstack.size() - 1 );
	
	//cut the stack down to the appropriate depth specifie in params
	int low = imstack[0].i;
	//cout << "lowest value " << low << endl;
	imstack.resize( profile.notch - low + 1);
	//printf("stack back %i %i \n", imstack.back().i, profile.notch);
	assert( imstack.back().i == profile.notch );

	imstack.erase( imstack.begin(), imstack.end() - profile.d );
	assert( imstack.size() == profile.d );
	
	return imstack;	
}

#endif
