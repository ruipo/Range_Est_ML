%% Classification methods
cat = {'FNN' 'CNN' 'MFP'};
x = [1,2,3];

class_norm = [97.1 97.4 97.4];
class_nonorm = [97.7 97.1 NaN];

figure
plot(x,class_norm,':x','MarkerSize',10,'LineWidth',2)
hold on
plot(x,class_nonorm,':o','MarkerSize',10,'LineWidth',2)

set(gca,'xtick',1:3,'xticklabel',cat)
set(gca,'fontsize',25)
title('Classification Results (SNR = INF)','FontSize',25)
grid on

xlabel('Method')
ylabel('Accuracy (%)')
ylim([0 100])
legend('With Normalization', 'No Normalization')

%% Regression Methods

reg_norm_mape = [5.61 6.36 2.83];
reg_norm_1km = [69.6 70 98];
reg_nonorm_mape = [3.82 2.52 NaN];
reg_nonorm_1km = [80.5 89.8 NaN];

fig = figure;
left_color = [0 0.3 0.7];
right_color = [0.8 0.1 0];
set(fig,'defaultAxesColorOrder',[left_color; right_color]);

yyaxis left
plot(x,reg_norm_mape,'k:x','MarkerSize',10,'LineWidth',2)
hold on
plot(x,reg_nonorm_mape,'k:o','MarkerSize',10,'LineWidth',2)
ylabel('MAPE (%)')
ylim([0 100])


plot(x,reg_norm_mape,':x','MarkerSize',10,'LineWidth',2)
hold on
plot(x,reg_nonorm_mape,':o','MarkerSize',10,'LineWidth',2)
ylabel('MAPE (%)')
ylim([0 100])

yyaxis right
plot(x,reg_norm_1km,':x','MarkerSize',10,'LineWidth',2)
hold on
plot(x,reg_nonorm_1km,':o','MarkerSize',10,'LineWidth',2)
ylabel('% within 1km of Actual')
ylim([0 100])

set(gca,'xtick',1:4,'xticklabel',cat)
set(gca,'fontsize',25)
grid on

xlabel('Method')
title('Regression Results (SNR = INF)','FontSize',25)

legend('With Normalization','No Normalization')

%% CNN classification SNR

cnn_class_snr_norm = [1.7 15.3 86.9 97 97.2 97.2];
bartlett_mfp = [40.8 94.1 95.8 97.2 97.2 97.4];

snr = {'-10' '-5' '0' '5' '10' 'INF'};
x1 = [1,2,3,4,5,6];

figure

plot(x1,cnn_class_snr_norm,'b:x','MarkerSize',10,'LineWidth',2)
hold on
plot(x1,bartlett_mfp,'r:x','MarkerSize',10,'LineWidth',2)

set(gca,'xtick',1:6,'xticklabel',snr)
set(gca,'fontsize',25)
grid on

xlabel('SNR (dB)')
ylabel('Accuracy (%)')
ylim([0 100])
legend('CNN','MFP')

title('Classification Results with SNR','FontSize',25)

%% CNN reg SNR

cnn_mape_snr_norm = [81.96 83.9 59.67 8.67 3.87 3.86];
mfp_mape = [64.97 7.1 4.59 3.13 3.05 2.83];

cnn_1km_snr_norm = [4.3 6.5 25.3 68.8 81.2 81.3];
mfp_1km = [43.9 94.7 96.5 97.9 97.8 98];

fig = figure;
left_color = [0 0.3 0.7];
right_color = [0.8 0.1 0];
set(fig,'defaultAxesColorOrder',[left_color; right_color]);

yyaxis left
plot(x1,cnn_mape_snr_norm,'k:x','MarkerSize',10,'LineWidth',2)
hold on
plot(x1,mfp_mape,'k:o','MarkerSize',10,'LineWidth',2)
ylabel('MAPE (%)')
ylim([0 100])

plot(x1,cnn_mape_snr_norm,':x','MarkerSize',10,'LineWidth',2)
hold on
plot(x1,mfp_mape,':o','MarkerSize',10,'LineWidth',2)
ylabel('MAPE (%)')
ylim([0 100])

yyaxis right
plot(x1,cnn_1km_snr_norm,':x','MarkerSize',10,'LineWidth',2)
hold on
plot(x1,mfp_1km,':o','MarkerSize',10,'LineWidth',2)
ylabel('% within 1km of Actual')
ylim([0 100])

set(gca,'xtick',1:6,'xticklabel',snr)
set(gca,'fontsize',25)
grid on

xlabel('SNR (dB)')
title('Regression Results with SNR','FontSize',25)

legend('CNN','MFP')

%% Class SSP Deviation

SSP_var = [0 0.1 0.25 0.5];
cnn_class_ssp_norm = [97.4 29.8 11.8 4.3];
cnn_class_ssp_nonorm = [97.1 32.6 12.1 5.4];
fnn_class_ssp_norm = [97.1 28 7.1 4.4];
fnn_class_ssp_nonorm = [97.7 33 8.9 3.8];
mfp_class_ssp = [97.4 13.9 5.7 1.5];

figure
plot(SSP_var,fnn_class_ssp_norm,':rx','MarkerSize',10,'LineWidth',2)
hold on
plot(SSP_var,fnn_class_ssp_nonorm,':ro','MarkerSize',10,'LineWidth',2)
plot(SSP_var,cnn_class_ssp_norm,':bx','MarkerSize',10,'LineWidth',2)
plot(SSP_var,cnn_class_ssp_nonorm,':bo','MarkerSize',10,'LineWidth',2)
plot(SSP_var,mfp_class_ssp,':kx','MarkerSize',10,'LineWidth',2)
title('Classification Results with Random SSP Deviation (SNR = INF)','FontSize',25)
set(gca,'fontsize',25)
grid on

xlabel('Maximum SSP Deviation Percentage (%)')
ylabel('Accuracy (%)')
ylim([0 100])
legend('FNN (With Normalization)','FNN (No Normalization)','CNN (With Normalization)','CNN (No Normalization)','MFP (With Normalization)')

%% Reg SSP Deviation

SSP_var = [0 0.1 0.25 0.5];
cnn_mape_ssp_norm = [6.36 11.35 21.14 66.59];
cnn_mape_ssp_nonorm = [2.52 5.25 7.48 9.69];
fnn_mape_ssp_norm = [7.02 12.8 31.99 58.75];
fnn_mape_ssp_nonorm = [3.22 6.53 9.47 14.84];
mfp_mape_ssp = [2.83 50.39 71.76 90.58];

figure
plot(SSP_var,fnn_mape_ssp_norm,':rx','MarkerSize',10,'LineWidth',2)
hold on
plot(SSP_var,fnn_mape_ssp_nonorm,':ro','MarkerSize',10,'LineWidth',2)
plot(SSP_var,cnn_mape_ssp_norm,':bx','MarkerSize',10,'LineWidth',2)
plot(SSP_var,cnn_mape_ssp_nonorm,':bo','MarkerSize',10,'LineWidth',2)
plot(SSP_var,mfp_mape_ssp,':kx','MarkerSize',10,'LineWidth',2)
title('Regression MAPE with Random SSP Deviation (SNR = INF)','FontSize',25)
set(gca,'fontsize',25)
grid on

xlabel('Maximum SSP Deviation Percentage (%)')
ylabel('MAPE(%)')
ylim([0 100])
legend('FNN (With Normalization)','FNN (No Normalization)','CNN (With Normalization)','CNN (No Normalization)','MFP (With Normalization)')

SSP_var = [0 0.1 0.25 0.5];
cnn_1km_ssp_norm = [70 49.2 33.9 24.3];
cnn_1km_ssp_nonorm = [89.8 73.8 52 39.3];
fnn_1km_ssp_norm = [69.6 46.9 26.2 21.5];
fnn_1km_ssp_nonorm = [80.5 57.4 40.1 31.8];
mfp_1km_ssp = [98 33.5 16.8 9.4];

figure
plot(SSP_var,fnn_1km_ssp_norm,':rx','MarkerSize',10,'LineWidth',2)
hold on
plot(SSP_var,fnn_1km_ssp_nonorm,':ro','MarkerSize',10,'LineWidth',2)
plot(SSP_var,cnn_1km_ssp_norm,':bx','MarkerSize',10,'LineWidth',2)
plot(SSP_var,cnn_1km_ssp_nonorm,':bo','MarkerSize',10,'LineWidth',2)
plot(SSP_var,mfp_1km_ssp,':kx','MarkerSize',10,'LineWidth',2)
title('Regression Accuracy with Random SSP Deviation (SNR = INF)','FontSize',25)
set(gca,'fontsize',25)
grid on

xlabel('Maximum SSP Deviation Percentage (%)')
ylabel('% within 1km of Actual')
ylim([0 100])
legend('FNN (With Normalization)','FNN (No Normalization)','CNN (With Normalization)','CNN (No Normalization)','MFP (With Normalization)')

%% Class BL Deviation

SSP_var = [-10 -5 0 5 10];
cnnr = [7.7 3.58 1.81 0.91 0.62];
%fnn_class_ssp_nonorm = [26.7 20.9 28.3 97.7 17.1 11 4.2];
cnnc = [6.83 2.59 0.86 0.27 0.18];
%cnn_class_ssp_nonorm = [30.1 30.3 31.8 97.4 22.3 12.6 4];
mfp = [5.74 2.15 1.49 1.52 1.52];

figure
plot(SSP_var,cnnc,':rx','MarkerSize',10,'LineWidth',2)
hold on
%plot(SSP_var,fnn_class_ssp_nonorm,':ro','MarkerSize',10,'LineWidth',2)
plot(SSP_var,cnnr,':bx','MarkerSize',10,'LineWidth',2)
%plot(SSP_var,cnn_class_ssp_nonorm,':bo','MarkerSize',10,'LineWidth',2)
plot(SSP_var,mfp,':kx','MarkerSize',10,'LineWidth',2)
title('Prediction Errors with SNR','FontSize',25)
set(gca,'fontsize',25)
grid on

xlabel('SNR (dB)')
ylabel('Mean Absolute Error (km)')
ylim([0 8])
xlim([-10 10])
legend('CNN-C','CNN-R','MFP')

%% Reg BL Deviation

SSP_var = [-0.5 -0.25 -0.1 0 0.1 0.25 0.5];
cnn_mape_ssp_norm = [22.11 13.28 10.8 6.36 11.24 32.04 37.87];
cnn_mape_ssp_nonorm = [9.77 7.34 4.76 2.52 5.44 10.4 13.14];
fnn_mape_ssp_norm = [28.67 23 17.45 5.61 18.69 49.36 55.74];
fnn_mape_ssp_nonorm = [8.76 7.61 6.21 3.82 7.72 14.88 15.62];
mfp_mape_ssp = [75.13 66.19 58.34 2.83 61.48 89.51 77.8];

figure
plot(SSP_var,fnn_mape_ssp_norm,':rx','MarkerSize',10,'LineWidth',2)
hold on
plot(SSP_var,fnn_mape_ssp_nonorm,':ro','MarkerSize',10,'LineWidth',2)
plot(SSP_var,cnn_mape_ssp_norm,':bx','MarkerSize',10,'LineWidth',2)
plot(SSP_var,cnn_mape_ssp_nonorm,':bo','MarkerSize',10,'LineWidth',2)
plot(SSP_var,mfp_mape_ssp,':kx','MarkerSize',10,'LineWidth',2)
title('Regression MAPE with BL Strength (SNR = INF)','FontSize',25)
set(gca,'fontsize',25)
grid on

xlabel('Change to BL Strength (%)')
ylabel('MAPE(%)')
ylim([0 100])
legend('FNN (With Normalization)','FNN (No Normalization)','CNN (With Normalization)','CNN (No Normalization)','MFP (With Normalization)')

SSP_var = [-0.5 -0.25 -0.1 0 0.1 0.25 0.5];
cnn_1km_ssp_norm = [55 58.8 59.4 70 51.6 35.5 16.5];
cnn_1km_ssp_nonorm = [66.5 74.5 80.3 89.8 71.9 46.1 26];
fnn_1km_ssp_norm = [40.4 41 43.2 69.6 38.9 20.5 18.2];
fnn_1km_ssp_nonorm = [54.1 58.9 65.4 80.5 53 29.7 21.4];
mfp_1km_ssp = [29.7 33.5 36 98 27.7 21.1 10];

figure
plot(SSP_var,fnn_1km_ssp_norm,':rx','MarkerSize',10,'LineWidth',2)
hold on
plot(SSP_var,fnn_1km_ssp_nonorm,':ro','MarkerSize',10,'LineWidth',2)
plot(SSP_var,cnn_1km_ssp_norm,':bx','MarkerSize',10,'LineWidth',2)
plot(SSP_var,cnn_1km_ssp_nonorm,':bo','MarkerSize',10,'LineWidth',2)
plot(SSP_var,mfp_1km_ssp,':kx','MarkerSize',10,'LineWidth',2)
title('Regression Accuracy with BL Strengthn (SNR = INF)','FontSize',25)
set(gca,'fontsize',25)
grid on

xlabel('Change to BL Strength (%)')
ylabel('% within 1km of Actual')
ylim([0 100])
legend('FNN (With Normalization)','FNN (No Normalization)','CNN (With Normalization)','CNN (No Normalization)','MFP (With Normalization)')


%% Class Bottom SSP Deviation

SSP_var = [-0.25 -0.175 -0.1 0 0.1 0.175 0.25];
fnn_class_ssp_norm = [71.3 77.5 84.8 97.1 76.1 76.2 69.3];
fnn_class_ssp_nonorm = [72.9 77.9 86.6 97.7 83.1 78 68.2];
cnn_class_ssp_norm = [73.8 78.3 86 97.4 82 73.8 70.6];
cnn_class_ssp_nonorm = [73.3 79.3 85.2 97.1 83.5 76.3 68.6];
mfp_class_ssp = [80 84 90.1 97.4 85.7 83.5 79.2];

figure
plot(SSP_var,fnn_class_ssp_norm,':rx','MarkerSize',10,'LineWidth',2)
hold on
plot(SSP_var,fnn_class_ssp_nonorm,':ro','MarkerSize',10,'LineWidth',2)
plot(SSP_var,cnn_class_ssp_norm,':bx','MarkerSize',10,'LineWidth',2)
plot(SSP_var,cnn_class_ssp_nonorm,':bo','MarkerSize',10,'LineWidth',2)
plot(SSP_var,mfp_class_ssp,':kx','MarkerSize',10,'LineWidth',2)
title('Classification Results with Change to Bottom SSP (SNR = INF)','FontSize',25)
set(gca,'fontsize',25)
grid on

xlabel('Change to Bottom SSP (%)')
ylabel('Accuracy (%)')
ylim([60 100])
legend('FNN (With Normalization)','FNN (No Normalization)','CNN (With Normalization)','CNN (No Normalization)','MFP (With Normalization)')

%% Reg Bottom SSP Deviation

SSP_var = [-0.25 -0.175 -0.1 0 0.1 0.175 0.25];
cnn_mape_ssp_norm = [9.15 8.35 9.32 6.36 8 8.2 10.95];
cnn_mape_ssp_nonorm = [3.57 3.48 3.13 2.52 3.33 3.68 4.81];
fnn_mape_ssp_norm = [10.35 9.98 9.88 5.61 13.16 9.64 10.33];
fnn_mape_ssp_nonorm = [4.7 5.63 3.85 3.82 4.24 4.45 5.9];
mfp_mape_ssp = [7.32 6.24 4.49 2.83 6.49 5.8 8.03];

figure
plot(SSP_var,fnn_mape_ssp_norm,':rx','MarkerSize',10,'LineWidth',2)
hold on
plot(SSP_var,fnn_mape_ssp_nonorm,':ro','MarkerSize',10,'LineWidth',2)
plot(SSP_var,cnn_mape_ssp_norm,':bx','MarkerSize',10,'LineWidth',2)
plot(SSP_var,cnn_mape_ssp_nonorm,':bo','MarkerSize',10,'LineWidth',2)
plot(SSP_var,mfp_mape_ssp,':kx','MarkerSize',10,'LineWidth',2)
title('Regression MAPE with Change to Bottom SSP (SNR = INF)','FontSize',25)
set(gca,'fontsize',25)
grid on

xlabel('Change to Bottom SSP (%)')
ylabel('MAPE (%)')
ylim([0 20])
legend('FNN (With Normalization)','FNN (No Normalization)','CNN (With Normalization)','CNN (No Normalization)','MFP (With Normalization)')

SSP_var = [-0.25 -0.175 -0.1 0 0.1 0.175 0.25];
cnn_1km_ssp_norm = [52.7 55.1 59.7 70 53.5 48.7 39.2];
cnn_1km_ssp_nonorm = [71.9 76.2 83.6 89.8 76.8 69.8 58.7];
fnn_1km_ssp_norm = [46.4 49.2 54 69.6 35 39.4 38];
fnn_1km_ssp_nonorm = [64.3 66.5 70.1 80.5 66.8 63.9 56.1];
mfp_1km_ssp = [82.3 85.6 92.8 98 88.6 86 82];

figure
plot(SSP_var,fnn_1km_ssp_norm,':rx','MarkerSize',10,'LineWidth',2)
hold on
plot(SSP_var,fnn_1km_ssp_nonorm,':ro','MarkerSize',10,'LineWidth',2)
plot(SSP_var,cnn_1km_ssp_norm,':bx','MarkerSize',10,'LineWidth',2)
plot(SSP_var,cnn_1km_ssp_nonorm,':bo','MarkerSize',10,'LineWidth',2)
plot(SSP_var,mfp_1km_ssp,':kx','MarkerSize',10,'LineWidth',2)
title('Regression Accuracy with Change to Bottom SSP (SNR = INF)','FontSize',25)
set(gca,'fontsize',25)
grid on

xlabel('Change to Bottom SSP (%)')
ylabel('% within 1km of Actual')
ylim([0 100])
legend('FNN (With Normalization)','FNN (No Normalization)','CNN (With Normalization)','CNN (No Normalization)','MFP (With Normalization)')

%% BDepth

cnnc_1km = [93.6	97.2	98.4	99.2	91.4];
cnnr_1km = [79.8	93.4	95.4	95	73.2];
mfp_1km = [77.4	85.6	85.2	83.6	75];
cnnc_mae = [0.428	0.185	0.103	0.086	0.461];
cnnr_mae = [0.672	0.283	0.218	0.276	0.82];
mfp_mae = [1.26	0.854	0.884	0.961	1.428];
bdepth = [213.5	215.5	216.5	217.5	219.5];

% figure
% plot(bdepth,cnnc_1km,':rx','MarkerSize',10,'LineWidth',2)
% hold on
% plot(bdepth,cnnr_1km,':bx','MarkerSize',10,'LineWidth',2)
% plot(bdepth,mfp_1km,':kx','MarkerSize',10,'LineWidth',2)
% title('Prediction Errors with Bottom Depth','FontSize',25)
% set(gca,'fontsize',25)
% grid on
% 
% xlabel('Bottom Depth (m)')
% ylabel('% of Predictions within 1km of Actual Distance')
% ylim([0 100])
% xlim([213.5 219.5])
% legend('CNN-C','CNN-R','MFP')


figure
plot(bdepth,cnnc_mae,':rx','MarkerSize',10,'LineWidth',2)
hold on
plot(bdepth,cnnr_mae,':bx','MarkerSize',10,'LineWidth',2)
plot(bdepth,mfp_mae,':kx','MarkerSize',10,'LineWidth',2)
title('Prediction Errors with Bottom Depth','FontSize',25)
set(gca,'fontsize',25)
grid on

xlabel('Bottom Depth (m)')
ylabel('Mean Absolute Error (km)')
ylim([0 1.5])
xlim([213.5 219.5])
legend('CNN-C','CNN-R','MFP')

%% BL SSP

cnnc_1km = [61.6 63 65.3 98.9 59.9 39.4 16.2];
cnnr_1km = [59.3 60.9 64 85.9 60.2 41.5 23];
mfp_1km = [37.6 41 43.7 93.8 35.9 26.9 11.5];
cnnc_mae = [4.86 4.12 4.5 0.17 4.27 7.37 9.95];
cnnr_mae = [2.61 2.41 2.81 0.61 2.21 3.97 4.93];
mfp_mae = [10.2 10.22 10.25 1.56  10.89 11.58 12.84];
sspdev = [-0.5 -0.25 -0.1 0 0.1 0.25 0.5];

% figure
% plot(sspdev,cnnc_1km,':rx','MarkerSize',10,'LineWidth',2)
% hold on
% plot(sspdev,cnnr_1km,':bx','MarkerSize',10,'LineWidth',2)
% plot(sspdev,mfp_1km,':kx','MarkerSize',10,'LineWidth',2)
% title('Prediction Errors with BL Strength','FontSize',25)
% set(gca,'fontsize',25)
% grid on
% 
% xlabel('Bottom Depth (m)')
% ylabel('% of Predictions within 1km of Actual Distance')
% ylim([0 100])
% xlim([-0.5 0.5])
% legend('CNN-C','CNN-R','MFP')


figure
plot(sspdev,cnnc_mae,':rx','MarkerSize',10,'LineWidth',2)
hold on
plot(sspdev,cnnr_mae,':bx','MarkerSize',10,'LineWidth',2)
plot(sspdev,mfp_mae,':kx','MarkerSize',10,'LineWidth',2)
title('Prediction Errors with BL Strength','FontSize',25)
set(gca,'fontsize',25)
grid on

xlabel('Bottom Depth (m)')
ylabel('Mean Absolute Error (km)')
ylim([0 15])
xlim([-0.5 0.5])
legend('CNN-C','CNN-R','MFP')


