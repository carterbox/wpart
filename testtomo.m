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
% 
% %%
% t = tomography(1430,1730,2000,'LLPHDFB');
% 
% t.rotationCW = repmat(39,[1,5]); 
% t.x0 = repmat(397,[1,5]); 
% t.y0 = repmat(595,[1,5]);
% t.bottom = repmat(2044,[1,5]);
% 
% t = t.setprojname('recon_proj_', 46:50);
% t.recon_dir = '/media/OCT14M/OCT14M/Reconstructions'; % The directory of the reconstructions
% t.subset_dir = '/media/OCT14B/OCT14B/Subsets/Daniel'; % The directory to put the subsets
% t.segmented_dir = '/media/OCT14B/OCT14B/Segmentations/Daniel'; % The directory to put the segmented subsets
% 
% %t = t.gatherSubsets(1);
% %t = t.fitDists();
% t = t.segmentSubsets();
% 
% %%
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

t = t.gatherSubsets();
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

t = t.gatherSubsets(1);
%t = t.fitDists();
%t = t.segmentSubsets();
%%
%Troublesome
% 
% t = tomography(512,512,800,'SPPHEL01');
% 
% NUMSCANS = 5;
% 
% t.rotationCW = repmat(29,[1,NUMSCANS]); 
% t.x0 = repmat(1119,[1,NUMSCANS]); 
% t.y0 = repmat(1149,[1,NUMSCANS]);
% t.bottom = repmat(1600,1);
% 
% t = t.setprojname('recon_proj_', 84:84+NUMSCANS-1);
% t.recon_dir = '/media/OCT14M/Reconstructions'; % The directory of the reconstructions
% t.subset_dir = '/media/OCT14M/Segmentations/Chad'; % The directory to put the subsets
% t.segmented_dir = '/media/OCT14M/Segmentations/lookbook'; % The directory to put the segmented subsets
% 
% %t = t.gatherSubsets();
% %t = t.setnumdists(4);
% t = t.fitDists();
% t = t.segmentSubsets();

% %%
% 
% t = tomography(512,512,800,'SPPHEL03');
% 
% NUMSCANS = 4;
% 
% t.rotationCW = repmat(20,[1,NUMSCANS]); 
% t.x0 = repmat(930,[1,NUMSCANS]); 
% t.y0 = repmat(1341,[1,NUMSCANS]);
% t.bottom = repmat(1600,[1,NUMSCANS]);
% 
% t = t.setprojname('recon_proj_', 93:93+NUMSCANS-1);
% t.recon_dir = '/media/OCT14B/OCT14B/Reconstructions'; % The directory of the reconstructions
% t.subset_dir = '/media/OCT14M/Segmentations/Chad'; % The directory to put the subsets
% t.segmented_dir = '/media/OCT14M/Segmentations/lookbook'; % The directory to put the segmented subsets
% 
% %t = t.gatherSubsets();
% t = t.setnumdists(4,2);
% t = t.segmentSubsets();

% %%
% t = tomography(512,512,800,'HPPHEL01');
% 
% NUMSCANS = 4;
% 
% t.rotationCW = repmat(-6.5,[1,NUMSCANS]); 
% t.x0 = repmat(1245,[1,NUMSCANS]); 
% t.y0 = repmat(1026,[1,NUMSCANS]);
% t.bottom = repmat(1600,[1,NUMSCANS]);
% 
% t = t.setprojname('recon_proj_', 80:80+NUMSCANS-1);
% t.recon_dir = '/media/OCT14M/Reconstructions'; % The directory of the reconstructions
% t.subset_dir = '/media/OCT14M/Segmentations/Chad'; % The directory to put the subsets
% t.segmented_dir = '/media/OCT14M/Segmentations/lookbook'; % The directory to put the segmented subsets
% 
% %t = t.gatherSubsets();
% t = t.setnumdists(3,2);
% t = t.segmentSubsets();
% %%
% t = tomography(512,512,800,'HPPHEL04');
% 
% NUMSCANS = 4;
% 
% t.rotationCW = repmat(14,[1,NUMSCANS]); 
% t.x0 = repmat(1042,[1,NUMSCANS]); 
% t.y0 = repmat(971,[1,NUMSCANS]);
% t.bottom = repmat(1600,[1,NUMSCANS]);
% 
% t = t.setprojname('recon_proj_', 89:89+NUMSCANS-1);
% t.recon_dir = '/media/OCT14M/Reconstructions'; % The directory of the reconstructions
% t.subset_dir = '/media/OCT14M/Segmentations/Chad'; % The directory to put the subsets
% t.segmented_dir = '/media/OCT14M/Segmentations/lookbook'; % The directory to put the segmented subsets
% 
% %t = t.gatherSubsets();
% t = t.setnumdists();
% t = t.segmentSubsets();
% 
% %%
% 
% t = tomography(512,512,800,'SPPHEL04');
% 
% NUMSCANS = 5;
% 
% t.rotationCW = repmat(-27,[1,NUMSCANS]); 
% t.x0 = repmat(1024,[1,NUMSCANS]); 
% t.y0 = repmat(1024,[1,NUMSCANS]);
% t.bottom = repmat(1600,[1,NUMSCANS]);
% 
% t = t.setprojname('recon_proj_', 97:97+NUMSCANS-1);
% t.recon_dir = '/media/OCT14M/Reconstructions'; % The directory of the reconstructions
% t.subset_dir = '/media/OCT14M/Segmentations/Chad'; % The directory to put the subsets
% t.segmented_dir = '/media/OCT14M/Segmentations/lookbook'; % The directory to put the segmented subsets
% 
% %t = t.gatherSubsets();
% t = t.setnumdists();
% t = t.segmentSubsets();
