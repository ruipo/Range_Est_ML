function[mfp_output] = mfp_dr(cov_mat,rep_mat,dr)

n = size(cov_mat,1);
dr_num = round(n*dr);

num_t = size(cov_mat,3);
num_r = size(rep_mat,2);
num_d = size(rep_mat,3);
num_i = dr_num/4;

mfp_output = zeros(num_d,num_r,num_t);

for t = 1:num_t
    t
    
    mfp_output_temp = zeros(num_d,num_r,num_i);
    
    for i = 1:num_i
        % create dropout weight vector
        rep_w = ones(n,1);
        [~,arg] = datasample(rep_w,dr_num,'Replace',false);
        rep_w(arg) = 0;
        
        cov = cov_mat(:,:,t)+0.0000000001;
        cov_w = rep_w*rep_w.';
        cov = cov(logical(cov_w));
        
        cov = cov(cov ~= 0);
        cov = reshape(cov,n-dr_num,n-dr_num);

        for d = 1:num_d

            rep_vec = rep_mat(:,:,d)./vecnorm(rep_mat(:,:,d),2) + 0.0000000001;

            rep_vec = rep_vec.*repmat(rep_w,1,num_r);

            rep_vec = rep_vec(rep_vec ~= 0);
            rep_vec = reshape(rep_vec,n-dr_num,num_r);

            %mfp  
            mfp_output_temp(d,:,i) = real(dot(rep_vec,(cov*rep_vec)));

        end
    end
    
    mfp_output(:,:,t) = mean(mfp_output_temp,3);
end
