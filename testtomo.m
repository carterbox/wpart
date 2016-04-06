%% EEPHDFA
t = tomography(1500,1500,2000,'EEPHDFA');
t.rotationCW = [19,19,19,19,19]; 
t.x0 = [530,556,561,539,558]; 
t.y0 = [465,492,499,493,525];
t.z0 = [50,50,50,50,50];

t = t.setprojname('recon_proj_', 2:6);
t.recon_dir = '/media/OCT14M/OCT14M/Reconstructions'; % The directory of the reconstructions
t.subset_dir = '/media/OCT14M/OCT14M/Subsets/Daniel'; % The directory to put the subsets
t.segmented_dir = '/media/OCT14M/OCT14M/Segmentations/Daniel'; % The directory to put the segmented subsets

%t = t.gatherSubsets(1);
%t = t.fitDists();
%t = t.segmentSubsets();

%% ELPHDF2
t = tomography(1600,1500,2000,'ELPHDF2');
t.rotationCW = [-30,-30,-30,-30,-30]; 
t.x0 = [529,555,567,593,854]; 
t.y0 = [465,406,408,399,313];
t.z0 = [50,50,50,50,50];

t = t.setprojname('recon_proj_', [12,14:17]);
t.recon_dir = '/media/OCT14M/OCT14M/Reconstructions'; % The directory of the reconstructions
t.subset_dir = '/media/OCT14M/OCT14M/Subsets/Daniel'; % The directory to put the subsets
t.segmented_dir = '/media/OCT14M/OCT14M/Segmentations/Daniel'; % The directory to put the segmented subsets

% t = t.gatherSubsets(1);
% t = t.fitDists();
% t = t.segmentSubsets();

%% EEPHDF2
t = tomography(1300,1700,2000,'EEPHDF2');
t.rotationCW = [79,79,79]; 
t.x0 = [568,579,627]; 
t.y0 = [488,474,375];
t.z0 = [16,16,16];

t = t.setprojname('recon_proj_', 18:20);
t.recon_dir = '/media/OCT14M/OCT14M/Reconstructions'; % The directory of the reconstructions
t.subset_dir = '/media/OCT14M/OCT14M/Subsets/Daniel'; % The directory to put the subsets
t.segmented_dir = '/media/OCT14M/OCT14M/Segmentations/Daniel'; % The directory to put the segmented subsets

t = t.gatherSubsets(1);
%t = t.fitDists();
%t = t.segmentSubsets();

%% LLPHDF2
t = tomography(1500,1700,2000,'LLPHDF2');
t.rotationCW = [19,19,19,19,24]; 
t.x0 = [537,561,531,564,542]; 
t.y0 = [162,162,147,186,177];
t.z0 = [16,16,16,16,16];

t = t.setprojname('recon_proj_', 21:25);
t.recon_dir = '/media/OCT14M/OCT14M/Reconstructions'; % The directory of the reconstructions
t.subset_dir = '/media/OCT14M/OCT14M/Subsets/Daniel'; % The directory to put the subsets
t.segmented_dir = '/media/OCT14M/OCT14M/Segmentations/Daniel'; % The directory to put the segmented subsets

t = t.gatherSubsets(1);
%t = t.fitDists();
%t = t.segmentSubsets();

%% ELPHDF6
t = tomography(1050,1700,2000,'ELPHDF6');
t.rotationCW = [-104,-104,-104,-104,-104,-104]; 
t.x0 = [787,793,810,807,825,846]; 
t.y0 = [405,426,420,399,375,435];
t.z0 = [16,16,16,16,16,16];

t = t.setprojname('recon_proj_', 26:31);
t.recon_dir = '/media/OCT14B/OCT14B/Reconstructions'; % The directory of the reconstructions
t.subset_dir = '/media/OCT14M/OCT14M/Subsets/Daniel'; % The directory to put the subsets
t.segmented_dir = '/media/OCT14M/OCT14M/Segmentations/Daniel'; % The directory to put the segmented subsets

t = t.gatherSubsets(1);
%t = t.fitDists();
%t = t.segmentSubsets();

% %% LLPHDFA
% t = tomography(1548,1842,2000,'LLPHDFA');
% 
% t.rotationCW = repmat(-34,[1,5]); 
% t.x0 = repmat(357,[1,5]); 
% t.y0 = repmat(534,[1,5]);
% t.bottom = repmat(2130,[1,5]);
% 
% t = t.setprojname('recon_proj_', 41:45);
% t.recon_dir = '/media/OCT14M/OCT14M/Reconstructions'; % The directory of the reconstructions
% t.subset_dir = '/media/OCT14B/OCT14B/Subsets/Daniel'; % The directory to put the subsets
% t.segmented_dir = '/media/OCT14B/OCT14B/Segmentations/Daniel'; % The directory to put the segmented subsets
% 
% %t = t.gatherSubsets(1);
% %t = t.fitDists();
% t = t.segmentSubsets();

%% LLPHDFB
t = tomography(1430,1730,2000,'LLPHDFB');

t.rotationCW = repmat(39,[1,5]); 
t.x0 = repmat(397,[1,5]); 
t.y0 = repmat(595,[1,5]);
t.bottom = repmat(2044,[1,5]);

t = t.setprojname('recon_proj_', 46:50);
t.recon_dir = '/media/OCT14M/OCT14M/Reconstructions'; % The directory of the reconstructions
t.subset_dir = '/media/OCT14B/OCT14B/Subsets/Daniel'; % The directory to put the subsets
t.segmented_dir = '/media/OCT14B/OCT14B/Segmentations/Daniel'; % The directory to put the segmented subsets

%t = t.gatherSubsets(1);
%t = t.fitDists();
%t = t.segmentSubsets();

%%% LLPHDFC

% t = tomography(1885,1902,2000,'LLPHDFC');
% 
% t.rotationCW = repmat(31,[1,6]); 
% t.x0 = repmat(448,[1,6]); 
% t.y0 = repmat(248,[1,6]);
% t.bottom = repmat(2130,[1,6]);
% 
% t = t.setprojname('recon_proj_', 60:65);
% t.recon_dir = '/media/OCT14M/OCT14M/Reconstructions'; % The directory of the reconstructions
% t.subset_dir = '/media/OCT14B/OCT14B/Subsets/Daniel'; % The directory to put the subsets
% t.segmented_dir = '/media/OCT14B/OCT14B/Segmentations/Daniel'; % The directory to put the segmented subsets
% 
% %t = t.gatherSubsets(1);
% %t = t.fitDists();
% t = t.segmentSubsets();

% %% HPPHEL00
% t = tomography(,,,'');
% t.rotationCW = []; 
% t.x0 = []; 
% t.y0 = [];
% t.z0 = [];
% 
% t = t.setprojname('recon_proj_', );
% t.recon_dir = '/media/OCT14M/OCT14M/Reconstructions'; % The directory of the reconstructions
% t.subset_dir = '/media/OCT14M/OCT14M/Subsets/Daniel'; % The directory to put the subsets
% t.segmented_dir = '/media/OCT14M/OCT14M/Segmentations/Daniel'; % The directory to put the segmented subsets
% 
% t = t.gatherSubsets(1);
% t = t.fitDists();
% t = t.segmentSubsets();

%% HPPHEL04
t = tomography(1500,1600,2000,'HPPHEL04');
t.rotationCW = [13,13,13,13]; 
t.x0 = [510,513,546,507]; 
t.y0 = [420,438,471,387];
t.z0 = [16,16,16,16];

t = t.setprojname('recon_proj_', 89:92);
t.recon_dir = '/media/OCT14C/OCT14C/Reconstructions'; % The directory of the reconstructions
t.subset_dir = '/media/OCT14M/OCT14M/Subsets/Daniel'; % The directory to put the subsets
t.segmented_dir = '/media/OCT14M/OCT14M/Segmentations/Daniel'; % The directory to put the segmented subsets

t = t.gatherSubsets(1);
%t = t.fitDists();
%t = t.segmentSubsets();