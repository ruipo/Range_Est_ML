
ICEX_ssp = dlmread('ICEX_ssp.csv',',',[0 0 398 1]);
ICEX_ssp(1:3,:) = [];
ICEX_ssp(end,:) = [];

%%
xq1 = linspace(1,60,4);
xq1(end) = [];
xq2 = linspace(60,240,30);
xq2(end) = [];
xq3 = linspace(240,800,20);
s1 = spline(ICEX_ssp(:,1),ICEX_ssp(:,2),xq1);
s2 = spline(ICEX_ssp(:,1),ICEX_ssp(:,2),xq2);
s3 = spline(ICEX_ssp(:,1),ICEX_ssp(:,2),xq3);

s =  [s1 s2 s3 1.4987209e+03];
xq = [xq1 xq2 xq3 3000];

figure
plot(s,xq)
hold on
plot(ICEX_ssp(:,2),ICEX_ssp(:,1))
grid on

%%

col3 = -999.999*ones(length(xq),1);
col3(end) = -s(end);
col4 = zeros(length(xq),1);
col5 = zeros(length(xq),1);
col6 = ones(length(xq),1);
col7 = zeros(length(xq),1);

xq = [0 0 1 xq 3000];
s = [0 3600 3600 s 2200];
col3 = [0;1800;-3600;col3;1500];
col4 = [0;0.216;0.216;col4;0.5];
col5 = [0;0.648;0.648;col5;0.5];
col6 = [0;0.9;0.9;col6;2.9];
col7 = [0;0;-0.2;col7;0];

ICEX_ssp_new = [xq.' s.' col3 col4 col5 col6 col7];

%%

dlmwrite('ICEX_ssp_new',ICEX_ssp_new,'precision',6)