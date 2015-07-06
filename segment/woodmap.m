function [ image ] = woodmap( image, labels )
%WOODMAP takes an image and remaps it to 256 values according to labels

fprintf('Mapping...\n');
image = labels(image + 1);

%result = image(:);
%[x,y,z] = size(image);
% parfor i = 1:length(result)
%     result(i) = labels(result(i) + 1);
% end
end

%% - Creating color map and coloring pixels
% % % fprintf('Please sort the following peaks...\n 0 - Void\n 1 - Wood\n 2 - Mixture\n 3 - Adhesive\n');
% % % for i = 1:numGModes
% % %     R = -1;
% % %     while R < 0 || R > 3
% % %         Q = sprintf('The mean is: %f ', map(i));
% % %         R = input(Q);
% % %         if R < 0 || R > 3
% % %             disp('Invalid number!\n');
% % %         end
% % %     end
% % %     
% % %     if(R == 3), map(i) = 255;
% % %     elseif(R == 2), map(i) = 191;    
% % %     elseif(R == 1), map(i) = 128;
% % %     else map(i) = 0;
% % %     end
% % % end
