
k1 = oasn_cov_teste;
k2 = oasn_cov_teste;
t2 = 1446.85541;
t1 = 1445.41;
dr = 0.1;

R = zeros(min(size(k1,3),size(k2,3))-1,1);

for n = 1:min(size(k1,3),size(k2,3))-1
    dkdr = (k2(:,:,n+1)-k1(:,:,n))./(dr);
    dkdt = (k2(:,:,n+1)-k1(:,:,n))./(dr);
    Kinv = inv(k1(:,:,n));
    J = -trace(Kinv*dkdr*Kinv*dkdt);
    R(n) = inv(J);
end

Range = 3:0.01:49.98;

figure
plot(Range, 10*log10(abs(R)));

%%
ssim_list_real = zeros(min(size(k1,3),size(k2,3)),1);
ssim_list_imag = zeros(min(size(k1,3),size(k2,3)),1);

for n = 1:min(size(k1,3),size(k2,3))
    n
    ssim_list_real(n) = ssim(real(k1(:,:,n)),real(k2(:,:,n)));
    ssim_list_imag(n) = ssim(imag(k1(:,:,n)),imag(k2(:,:,n)));
end

Range = 3:0.01:49.99;
figure
plot(Range, ssim_list_real)
hold on
plot(Range, ssim_list_imag)

%% cosine similarity

oasn_cov_total = zeros(32,32,4700,7);
oasn_cov_total(:,:,:,1) = oasn_cov_norm_testf;
oasn_cov_total(:,:,:,2) = oasn_cov_norm_testg;
oasn_cov_total(:,:,:,3) = oasn_cov_norm_testh;
oasn_cov_total(:,:,:,4) = oasn_cov_norm_test2;
oasn_cov_total(:,:,:,5) = oasn_cov_norm_testc;
oasn_cov_total(:,:,:,6) = oasn_cov_norm_testd;
oasn_cov_total(:,:,:,7) = oasn_cov_norm_teste;

csim_mat = zeros(7,7);
csim_var = zeros(7,7);
for ssp1 = 1:7
    ssp1
    for ssp2 = 1:7
        k1 = oasn_cov_total(:,:,:,ssp1);
        k2 = oasn_cov_total(:,:,:,ssp2);
        templist = zeros(4700,1);
        for n = 1:4700
            top = sum(dot(abs(k1(:,:,n)),abs(k2(:,:,n))));
            bot = sqrt(sum(dot(abs(k1(:,:,n)),abs(k1(:,:,n)))))*sqrt(sum(dot(abs(k2(:,:,n)),abs(k2(:,:,n)))));
            templist(n) = top/bot;
        end
        csim_mat(ssp1,ssp2) = mean(templist);
        csim_var(ssp1,ssp2) = var(templist);
    end
end 
Range = 3:0.01:49.99;
bl = [-0.5 -0.25 -0.1 0 0.1 0.25 0.5];

figure
plot(bl,csim_mat(4,:),'kx','linewidth',2)
hold on
plot(bl,csim_mat(4,:)+csim_var(4,:),'bo','linewidth',2)
plot(bl,csim_mat(4,:)-csim_var(4,:),'ro','linewidth',2)
plot(bl,csim_mat(4,:),':k','linewidth',1.5)
plot(bl,csim_mat(4,:)+csim_var(4,:),':b','linewidth',1.5)
plot(bl,csim_mat(4,:)-csim_var(4,:),':r','linewidth',1.5)
grid on
ylim([0.5,1]);
xlim([-0.5 0.5])
set(gca,'fontsize',25)
title('Similarity Measurement between NCMs at different BL Strengths') 
ylabel('Average Cosine Similarity')
xlabel('Change to BL Strength (%)')

figure
x = reshape(blgrid1,49,1);
y = reshape(blgrid1.',49,1);
z = reshape(csim_mat,49,1);

pointsize = 200;
scatter(x,y,pointsize,z,'filled','MarkerEdgeColor','k');
set(gca,'fontsize',25)
colormap jet
caxis([0.5 1])
grid on
xlabel('Change to BL Strength (%)')
ylabel('Change to BL Strength (%)')
title('Similarity Measurement between NCMs at different BL Strengths') 
%%

k1 = oasn_cov_total(:,:,:,2);
k2 = oasn_cov_total(:,:,:,1);
templist = zeros(4700,1);
for n = 1:4700
    top = sum(dot(abs(k1(:,:,2703)),abs(k2(:,:,n))));
    bot = sqrt(sum(dot(abs(k1(:,:,2703)),abs(k1(:,:,2703)))))*sqrt(sum(dot(abs(k2(:,:,n)),abs(k2(:,:,n)))));
    templist(n) = top/bot;
end
figure
plot(Range,templist)