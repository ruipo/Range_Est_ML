
%% set directory
prefix = '~/Desktop/swellex/ctds/';
directory = dir([prefix '*.prn']);

depth = 0:0.5:216.5;
%% plot a portion of the directory
SSP = NaN(length(depth),length(directory));

for i = 1:length(directory)
    i

    filename = [prefix directory(i).name];
    
    M = dlmread(filename, '',0,3);
    SSP(1:size(M,1),i) = M(:,1);
    
end



%%
ssp = nanmean(SSP,2);
ssp_dev = ssp;
ssp_dev(1:156,:) = SSP(1:156,end);
ssp_dev(157) = 1489.35;
ssp_dev(158) = 1489.33;
ssp_dev(159) = 1489.32;
ssp_dev(160) = 1489.31;
ssp_dev(161) = 1489.30;

figure
plot(ssp,depth)
hold on
plot(ssp_dev(1:8:end),depth(1:8:end))
set(gca,'Ydir','reverse')
grid on
xlim([1485 1525])
ylim([0 212.5])