function [labels,probabilities] = checklabels(labels,probabilities,~,~)
% Checks the range [lo,hi] for ranges not in order. The labels must be an
% increasing function. Assumes the highest and lowest grays are already
% labeled correctly and that the gaussians were sorted correctly.

[~,voidmean] = max(probabilities(:,1));
[~,adhesivemean] = max(probabilities(:,4));
labels(1:voidmean) = 1;
labels(adhesivemean:end) = 4;

left = length(labels);
lo = 0; hi = labels(left); 
numdistscheck = numel(unique(labels));

% while left > lo
%     
%     % Something is out of order.
%     if labels(left) > hi            
%         while labels(left) > hi
%             % Set the current max to -1. Reassign to second most probable.
%             probabilities(left,labels(left)) = -1; 
%             [~,labels(left)] = max(probabilities(left,:),[],2);
%         end
%     % The function has reached a step. 
%     elseif labels(left) < hi
%         
%         % Each step should go down exactly one.
%         if hi - labels(left) == 1
%             hi = labels(left);
%         else
%             probabilities(left,labels(left)) = -1; 
%             [~,labels(left)] = max(probabilities(left,:),[],2);
%         end
%     
%     end
%         
%     left = left - 1;
%     %reshape(labels,32,8)
% end

if(numel(unique(labels)) ~= numdistscheck)
   warning('Lost some dists.') 
end
end