
numint = 4400;
prefix = '/Users/Rui/Desktop/ML/mfp/Bartlett_test2_bdr_files/';
directory = dir([prefix '*.bdr']);

dist = linspace(3,50,4400);
act_distance = zeros(1000,1);
pred_distance = zeros(1000,1);
mfp = zeros(3,4400,1000);
results_mat = [];

for i = 1:length(directory)
    i
    
    temp = [];
    filename = [prefix directory(i).name];
    fileID = fopen(filename);
    C = textscan(fileID,'%s%s%s%s%s%s','HeaderLines',5);
    
    temp(:,1) = str2double(C{1,1});
    temp(:,2) = str2double(C{1,2});
    temp(:,3) = str2double(C{1,3});
    temp(:,4) = str2double(C{1,4});
    temp(:,5) = str2double(C{1,5});
    temp(:,6) = str2double(C{1,6});
    temp = temp.';
    temp = temp(~isnan(temp));
    
    mfp(1,:,i) = temp(1:4400);
    mfp(2,:,i) = temp(4401:8800);
    mfp(3,:,i) = temp(8801:end);
    
    flat_mfp = mean(mfp(:,:,i),1);
    [~,loc] = max(flat_mfp);
    
    results_mat = [results_mat; flat_mfp];
    
    act_distance(i) = str2double(directory(i).name(1:end-7));
    pred_distance(i) = dist(loc);
    
    fclose(fileID);
    
    
end

%%
[sorted_act_distance,I] = sort(act_distance);
sorted_pred_distance = pred_distance(I);
figure
plot(sorted_act_distance)
hold on
plot(sorted_pred_distance,'o')
xlabel('Test Data Number')
ylabel('Distance')
ylim([3 50])
title('MFP Result with INF SNR')
grid on
set(gca,'fontsize',30)

mape = (100/length(sorted_act_distance))*sum(abs((sorted_act_distance-sorted_pred_distance)./sorted_act_distance));

diff = abs(sorted_act_distance-sorted_pred_distance);
percentwithin1km = 100*length(diff(diff<=1))/length(diff);

disp(mape)
disp(percentwithin1km)

%%
figure
for j = 1:1000
    plot(dist,mean(mfp(:,:,j),1))
    title(['act_dis = ', num2str(act_distance(j)), '; pred_dist = ', num2str(pred_distance(j))])
    pause
end


%%
[sorted_act_distance,I] = sort(act_distance);
sorted_results = results_mat(I,:);
%sorted_results = squeeze(mfp(2,:,I)).';

for i = 1:size(sorted_results,1)
    sorted_results(i,:) = sorted_results(i,:)./sum(sorted_results(i,:));
end

[sorted_act_distance,I] = sort(act_distance);
sorted_pred_distance = pred_distance(I);

figure
h = pcolor(sorted_act_distance,dist,100*(sorted_results.'));
set(h, 'EdgeColor', 'none');
xlabel('Actual Source Distance (km)')
ylabel('Predicted Source Distance (km)')
xlim([3 50])
ylim([3 50])
title('MLM MFP (0.5% SSP Deviation)') 

hold on
plot(sorted_act_distance,sorted_act_distance,'-.k','LineWidth',3)
plot(sorted_act_distance,sorted_pred_distance,'ro','MarkerSize',4)
set(gca,'fontsize',25)
set(gca, 'YDir','normal')

colorbar
caxis([0.0225 0.025]);
