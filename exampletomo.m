%% EXAMPLE
tomodata = tomography(1500,1500,2000,'EXAMPLE'); % sets the dimensions of the subset and the sample name
tomodata.rotationCW = [19,19,19,19,19]; % tells how to rotate before cropping
tomodata.x0 = [530,556,561,539,558]; % sets the min corner of the subset
tomodata.y0 = [465,492,499,493,525];
tomodata.z0 = [50,50,50,50,50];

tomodata = tomodata.setprojname('recon_proj_', [2,3,4,5,6]); % tells the folder names of the reconstructions
tomodata.recon_dir = '/media/OCT14M/OCT14M/Reconstructions'; % The directory of the reconstructions
tomodata.subset_dir = '/media/OCT14M/OCT14M/Subsets/Daniel'; % The directory to put the subsets
tomodata.segmented_dir = '/media/OCT14M/OCT14M/Segmentations/Daniel'; % The directory to put the segmented subsets

tomodata = tomodata.gatherSubsets();
tomodata = tomodata.fitDists();
tomodata = tomodata.segmentSubsets();