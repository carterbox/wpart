% 
% t = tomography(512,512,800,'LLPHDFB');
% 
% t.rotationCW = repmat(-44.5,[1,5]); 
% t.x0 = repmat(1179,[1,5]); 
% t.y0 = repmat(762,[1,5]);
% t.bottom = repmat(1600,[1,5]);
% 
% t = t.setprojname('recon_proj_', 46:46+4);
% t.recon_dir = '/media/OCT14B/OCT14B/Reconstructions'; % The directory of the reconstructions
% t.subset_dir = '/media/OCT14B/OCT14B/Segmentations/Chad'; % The directory to put the subsets
% t.segmented_dir = '/media/OCT14M/Segmentations/lookbook'; % The directory to put the segmented subsets
% 
% t = t.gatherSubsets();
% t = t.segmentSubsets();

%Troublesome

t = tomography(512,512,800,'SPPHEL01');

NUMSCANS = 5;

t.rotationCW = repmat(29,[1,NUMSCANS]); 
t.x0 = repmat(1119,[1,NUMSCANS]); 
t.y0 = repmat(1149,[1,NUMSCANS]);
t.bottom = repmat(1600,[1,NUMSCANS]);

t = t.setprojname('recon_proj_', 84:84+NUMSCANS-1);
t.recon_dir = '/media/OCT14M/Reconstructions'; % The directory of the reconstructions
t.subset_dir = '/media/OCT14M/Segmentations/Chad'; % The directory to put the subsets
t.segmented_dir = '/media/OCT14M/Segmentations/lookbook'; % The directory to put the segmented subsets

%t = t.gatherSubsets();
t = t.setnumdists(3,2);
t = t.segmentSubsets();

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
