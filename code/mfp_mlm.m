%% MVDR MFP
% Takes in normalized convariance matrices (n X n x time) and unnormalized replica vectors (n X range X depth)
% n = number of array elements

function[mfp_output] = mfp_mlm(cov_mat,rep_mat)

mfp_output = zeros(size(rep_mat,3),size(rep_mat,2),size(cov_mat,3));

for t = 1:size(cov_mat,3)
    t
    
    cov = cov_mat(:,:,t);
    invcov = inv(cov);
    
    for d = 1:size(rep_mat,3)
        rep_vec = rep_mat(:,:,d)./vecnorm(rep_mat(:,:,d),2);
            
        mfp_output(d,:,t) = 1./real(dot(rep_vec,(invcov*rep_vec)));
  
    end
end

% 
% function[mfp_output] = mfp_mlm(cov_mat,rep_mat)
% 
% mfp_output = zeros(size(rep_mat,3),size(rep_mat,2),size(cov_mat,3));
% 
% for t = 1:size(cov_mat,3)
%     t
%     for r = 1: size(rep_mat,2)
%         for d = 1:size(rep_mat,3)
%             
%             cov = cov_mat(:,:,t);
%             rep_vec = rep_mat(:,r,d)./norm(rep_mat(:,r,d),2);
%             
%             mfp_output(d,r,t) = 1/(rep_vec'*inv(cov)*rep_vec);
%             
%         end
%     end
% end
