%% EXAMPLE
% set the subset dimensions and the sample name
tomodata = tomography(1500, 1500, 2000, 'EXAMPLE');

% set the rotation angle before cropping
tomodata.rotationCW = [19, 19, 19, 19, 19];

% set the min corner of the subset
tomodata.x0 = [530, 556, 561, 539, 558];
tomodata.y0 = [465, 492, 499, 493, 525];
tomodata.z0 = [50, 50, 50, 50, 50];

% set the directory of the folders containing reconstructions
tomodata.recon_dir = '/media/OCT14M/OCT14M/Reconstructions';
% set the folder names of the reconstructions
tomodata = tomodata.setprojname('recon_proj_', [2,3,4,5,6]);

% set the directory to put the cropped subsets
tomodata.subset_dir = '/media/OCT14M/OCT14M/Subsets/Daniel';
% set the directory to put the segmented subsets
tomodata.segmented_dir = '/media/OCT14M/OCT14M/Segmentations/Daniel';

% crop, segment, and calculate morphological metrics
tomodata = tomodata.setnumdists();
tomodata = tomodata.gatherSubsets();
tomodata = tomodata.fitDists();
tomodata = tomodata.segmentSubsets('color');
tomodata.penetrationStats('bondline.csv');