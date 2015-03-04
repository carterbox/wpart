#ifndef __PARSE_HPP_INCLUDED__
#define __PARSE_HPP_INCLUDED__

#include <boost/filesystem.hpp>

using namespace std;
namespace bfs = boost::filesystem;

struct params {
	bfs::path in;
	bfs::path out;
	int notch = 0;
	double rotation = 0.0;
	int x = 0, y = 0;
	int h = 0,w = 0,d = 0;
};

params* parseInputs( int argc, char** argv )
//Parses the input arguements and returns various error messages based on input
{
	params *thisparams = NULL;
	if( (argc == 7) || (argc == 10) )
	{	
		thisparams = new params; 
		thisparams->in = bfs::path(argv[1]);
		thisparams->out = bfs::path(argv[2]);
		thisparams->rotation = std::strtof(argv[3], nullptr);
		thisparams->notch = std::stoi(argv[4], nullptr, 10);
		thisparams->x = std::stoi(argv[5], nullptr, 10);
		thisparams->y = std::stoi(argv[6], nullptr, 10);
		if( argc == 10 )
		{
			thisparams->h = std::stoi(argv[7], nullptr, 10);
			thisparams->w = std::stoi(argv[8], nullptr, 10);
			thisparams->d = std::stoi(argv[9], nullptr, 10);
		}
		else
		{
			thisparams->h = 256;
			thisparams->w = 1024;
			thisparams->d = 1600;
		}
	}
	else
	{
		cout << "Usage: wpart INPUT_PATH OUTPUT_PATH ROTATION_DEGREES_CCW" <<
		" NOTCH_LOCATION X Y HEIGHT WIDTH DEPTH" << endl <<
		"   or: wpart INPUT_PATH OUTPUT_PATH ROTATION_DEGREES_CCW NOTCH_LOCATION X Y"
		<< endl;
		exit(EXIT_FAILURE);
	}
	assert( thisparams != NULL );
	
	if( !exists(thisparams->in) || !is_directory(thisparams->in) )
	{
		perror("INPUT_PATH does not exists or is not a directory\n");
		exit(EXIT_FAILURE);
	}
	if( !exists(thisparams->out) )
		create_directory(thisparams->out);
	else if ( is_regular_file(thisparams->out) )
	{
		perror("OUTPUT_PATH already exists and is a regular file.\n");
		exit(EXIT_FAILURE);
	}
	
	cout
	<< "INPUT: " << thisparams->in << endl
	<< "OUTPUT: " << thisparams->out << endl
	<< "ROTATION: " << thisparams->rotation << endl
	<< "NOTCH: Slice " << thisparams->notch << endl
	<< "ROI UPPER LEFT: ("<< thisparams->x << "," << thisparams->y << ")" << endl;
	printf("SUBSET DIMENSIONS: (%u, %u, %u)\n", thisparams->h, thisparams->w, thisparams->d);
	
	return thisparams;
}

int parseName( bfs::path filepath)
//Parses filepaths and returns the slice number from files that end in 5 digit
//numbers. e.g. /???12345.jpg
{
	string parseme = filepath.filename().replace_extension().native();
	parseme = parseme.substr( parseme.length() - 5 , 6 );
	return std::stoi(parseme.c_str(), nullptr, 10);
}

#endif
