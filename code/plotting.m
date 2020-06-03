
%Data
cat = {'SVM' '1 Layer FNN' '5 Layer FNN' '5 Layer CNN'};
x = [1,2,3,4];

class_tr = [100 99.96 38.18 100];
class_test = [97.9 98.5 30.4 99];

reg_tr_mape = [2.48 4.21 3.75 2.05];
reg_test_mape = [10.24 6.69 4.67 4.33];
reg_tr_1km = [77.19 69.5 80.77 91.28];
reg_test_1km = [45.9 53.6 77 70.6];

% svm_class_test = [97.9 60.9 3.7 1.7];
% svm_class_tr = [100 82 45.91 99.98];
% fnn1l_class_tr = [99.96 96.6 54.56 99.94];
% fnn1l_class_test = [98.5 82.2 3 1.8];
% fnn5l_class_tr = [38.18 1.06 1.06 1.06];
% fnn5l_class_test = [30.4 1.2 1.3 0.8];
% 
% cnn_class_tr = [100];
% cnn_class_test = [99];
% 
% svm_r_tr_mape = [2.48 43.22 29.83 3.9];
% svm_r_test_mape = [10.24 44.08 50.72 71.5];
% svm_r_tr_1km = [87.7 58.39 55.33 85];
% svm_r_test_1km = [76 58.5 53.8 56.9];
% 
% fnn1l_r_tr_mape = [4.21 32.26 16.6 3.77];
% fnn1l_r_test_mape = [6.69 34.31 31.76 46.32];
% fnn1l_r_tr_1km = [86.41 50.76 60.67 88.98];
% fnn1l_r_test_1km = [80 50.9 70.4 61.2];
% 
% fnn5l_r_tr_mape = [3.75 86.8 86.67 85.59];
% fnn5l_r_test_mape = [4.67 87.17 87.04 85.95];
% fnn5l_r_tr_1km = [91.62 52.33 52.41 53.12];
% fnn5l_r_test_1km = [91.3 52.4 52.4 53.2];
% 
% cnn_r_tr_mape = [3.01];
% cnn_r_test_mape = [5.66];
% cnn_r_tr_1km = [99.19];
% cnn_r_test_1km = [90.2];


snr = {'-10' '-5' '0' '5' '10' 'INF'};
x1 = [1,2,3,4,5,6];

%svm_class_tr_snr = [100 100 100 100 100 100];
%svm_class_test_snr = [30 64 86.8 94.8 97 97.9];
cnn_class_tr_snr = [100 99.98 100 100 100 100];
cnn_class_test_snr = [36.1 76 93.5 98.1 98.5 99];

fnn5l_r_tr_mape_snr = [4.41 3.58 3.98 4.03 3.61 3.75];
fnn5l_r_test_mape_snr = [16.38 11.27 8.06 5.83 4.73 4.67];
fnn5l_r_tr_1km_snr = [70.88 78.92 75.39 76.88 82.11 80.77];
fnn5l_r_test_1km_snr = [24.2 35.5 47.9 60.1 70.9 77];

%cnn_r_tr_mape_snr = [3.77 4 2.33 2.88 1.88 2.05];
%cnn_r_test_mape_snr = [13.49 9.54 6.22 4.95 4.03 4.33];
%cnn_r_tr_1km_snr = [96.34 96.06 96.28 98.43 99.3 99.81];
%cnn_r_test_1km_snr = [68.8 75.7 75.9 90.2 90.3 90.6];

%% Classification methods

figure

%subplot(1,2,1)
plot(x,class_tr,':x','MarkerSize',10,'LineWidth',2)
hold on
plot(x,class_test,':o','MarkerSize',10,'LineWidth',2)
%plot(x,fnn5l_class_tr,':x','MarkerSize',10,'LineWidth',2)
%plot(x(1),cnn_class_tr,'d','MarkerSize',16,'LineWidth',2)

set(gca,'xtick',1:4,'xticklabel',cat)
set(gca,'fontsize',25)
title('Classification Results (SNR = INF)','FontSize',25)
grid on

xlabel('Method')
ylabel('Accuracy (%)')
ylim([0 103])
legend('Training', 'Testing')


%% Regression methods

fig = figure;
left_color = [0 0.3 0.7];
right_color = [0.8 0.1 0];
set(fig,'defaultAxesColorOrder',[left_color; right_color]);


%subplot(1,2,1)

yyaxis left
plot(x,reg_tr_mape,'k:x','MarkerSize',10,'LineWidth',2)
hold on
plot(x,reg_test_mape,'k:o','MarkerSize',10,'LineWidth',2)
%plot(x,fnn5l_r_tr_mape,'k:x','MarkerSize',10,'LineWidth',2)
%plot(x(1),cnn_r_tr_mape,'kd','MarkerSize',16,'LineWidth',2)
ylabel('Training MAPE (%)')
ylim([0 103])


plot(x,reg_tr_mape,':x','MarkerSize',10,'LineWidth',2)
hold on
plot(x,reg_test_mape,':o','MarkerSize',10,'LineWidth',2)
%plot(x,fnn5l_r_tr_mape,':x','MarkerSize',10,'LineWidth',2)
%plot(x(1),cnn_r_tr_mape,'d','MarkerSize',16,'LineWidth',2)
ylabel('MAPE (%)')
ylim([0 103])

yyaxis right
plot(x,reg_tr_1km,':+','MarkerSize',10,'LineWidth',2)
hold on
plot(x,reg_test_1km,':o','MarkerSize',10,'LineWidth',2)
%plot(x,fnn5l_r_tr_1km,':x','MarkerSize',10,'LineWidth',2)
%plot(x(1),cnn_r_tr_1km,'d','MarkerSize',16,'LineWidth',2)
ylabel('% within 1km of Actual')
ylim([0 103])

set(gca,'xtick',1:4,'xticklabel',cat)
set(gca,'fontsize',25)
grid on

xlabel('Method')
title('Regression Results (SNR = INF)','FontSize',25)

legend('Training','Testing')



%% classification SNR

figure
title('Classification Results with SNR','FontSize',25)

plot(x1,cnn_class_tr_snr,':x','MarkerSize',10,'LineWidth',2)
hold on
plot(x1,cnn_class_test_snr,':o','MarkerSize',10,'LineWidth',2)

set(gca,'xtick',1:6,'xticklabel',snr)
set(gca,'fontsize',25)
grid on

xlabel('SNR (dB)')
ylabel('Accuracy (%)')
ylim([0 103])
legend('Training','Testing')

title('CNN Classification with SNR','FontSize',25)

%% Regression SNR
fig = figure;
left_color = [0 0.3 0.7];
right_color = [0.8 0.1 0];
set(fig,'defaultAxesColorOrder',[left_color; right_color]);


yyaxis left
plot(x1,fnn5l_r_tr_mape_snr,'k:x','MarkerSize',10,'LineWidth',2)
hold on
plot(x1,fnn5l_r_test_mape_snr,'k:o','MarkerSize',10,'LineWidth',2)
ylabel('MAPE (%)')
ylim([0 103])

plot(x1,fnn5l_r_tr_mape_snr,':x','MarkerSize',10,'LineWidth',2)
hold on
plot(x1,fnn5l_r_test_mape_snr,':o','MarkerSize',10,'LineWidth',2)
ylabel('MAPE (%)')
ylim([0 103])

yyaxis right
plot(x1,fnn5l_r_tr_1km_snr,':x','MarkerSize',10,'LineWidth',2)
hold on
plot(x1,fnn5l_r_test_1km_snr,':o','MarkerSize',10,'LineWidth',2)
ylabel('% within 1km of Actual')
ylim([0 103])

set(gca,'xtick',1:6,'xticklabel',snr)
set(gca,'fontsize',25)
grid on

xlabel('SNR (dB)')
title('5-Layer FNN Regression with SNR','FontSize',25)

legend('Training','Testing')


%% SSP data

SSP_var = [0 0.1 0.25 0.5];
svm_class_ssp = [97.9 25.6 9.3 7];
cnn_class_ssp = [99 23.3 8.2 3.4];

bmfp_mape = [2.86 49.44 66.31 89.41];
bmfp_1km = [98 32.3 16.5 10.2];

mlmmfp_mape = [4.15 50.64 67.49 89.98];
mlmmfp_1km = [97.5 34.7 17.2 9.9];

mcmmfp_mape = [22.34 72.83 96.17 123.45];
mcmmfp_1km = [88.6 37.8 18.9 8.8];

fnn5l_reg_mape = [4.67 6.73 8.5 13.09];
fnn5l_reg_1km = [77 55.2 45.2 35.8];

cnn_reg_mape = [5.66 12.28 28.28 52.58];
cnn_reg_1km = [70.6 38.9 24.9 20.5];


%% Class SSP

figure
plot(SSP_var,svm_class_ssp,':+','MarkerSize',10,'LineWidth',2)
hold on
plot(SSP_var,cnn_class_ssp,':d','MarkerSize',10,'LineWidth',2)
title('Classification Results with SSP Deviation (SNR = INF)','FontSize',25)
set(gca,'fontsize',25)
grid on

xlabel('Maximum SSP Deviation Percentage (%)')
ylabel('Testing Accuracy (%)')
ylim([0 103])
legend('SVM','5-Layer CNN')

%% Reg SSP

fig = figure;
left_color = [0 0.3 0.7];
right_color = [0.8 0.1 0];
set(fig,'defaultAxesColorOrder',[left_color; right_color]);

yyaxis left
plot(SSP_var, bmfp_mape, 'k:o','MarkerSize',10,'LineWidth',2)
hold on
plot(SSP_var, mlmmfp_mape, 'k:s','MarkerSize',10,'LineWidth',2)
plot(SSP_var, mcmmfp_mape, 'k:+','MarkerSize',10,'LineWidth',2)
plot(SSP_var, fnn5l_reg_mape, 'k:x','MarkerSize',10,'LineWidth',2)
plot(SSP_var, cnn_reg_mape,'k:d','MarkerSize',10,'LineWidth',2)
ylabel('Testing MAPE (%)')
ylim([0 130])

plot(SSP_var, bmfp_mape, ':o','MarkerSize',10,'LineWidth',2)
hold on
plot(SSP_var, mlmmfp_mape, ':s','MarkerSize',10,'LineWidth',2)
plot(SSP_var, mcmmfp_mape, ':+','MarkerSize',10,'LineWidth',2)
plot(SSP_var, fnn5l_reg_mape, ':x','MarkerSize',10,'LineWidth',2)
plot(SSP_var, cnn_reg_mape,':d','MarkerSize',10,'LineWidth',2)
ylabel('Testing MAPE (%)')
ylim([0 130])

yyaxis right
plot(SSP_var, bmfp_1km, ':o','MarkerSize',10,'LineWidth',2)
hold on
plot(SSP_var, mlmmfp_1km, ':s','MarkerSize',10,'LineWidth',2)
plot(SSP_var, mcmmfp_1km, ':+','MarkerSize',10,'LineWidth',2)
plot(SSP_var, fnn5l_reg_1km, ':x','MarkerSize',10,'LineWidth',2)
plot(SSP_var, cnn_reg_1km,':d','MarkerSize',10,'LineWidth',2)
ylabel('Testing % within 1km of Actual')
ylim([0 130])

title('Regression Results with SSP Deviation (SNR = INF)','FontSize',25)
set(gca,'fontsize',25)
grid on

xlabel('Maximum SSP Deviation Percentage (%)')

legend('Bartlett MFP','MLM MFP','MCM MFP','5-Layer FNN','5-Layer CNN')
