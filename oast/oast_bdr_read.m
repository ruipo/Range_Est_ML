%% Read in data
prefix = '/Users/Rui/Desktop/ML/research/oast/';
directory = dir([prefix '*.bdr']);

oast = zeros(300,153,length(directory));

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
    
    for j = 1:300
        oast(j,:,i) = temp((j*153)-153+1:j*153);
    end
        
    fclose(fileID);
     
end

%% Get Differences

for k = 1:15
    diff_oast(:,:,k) = (-oast(:,:,k+1)) - (-oast(:,:,1));
end


%% Plotting oast
x = linspace(0,50,153);
y = linspace(1,3000,300);

figure
h = pcolor(x,y,-oast(:,:,1));
set(h, 'EdgeColor', 'none');
xlabel('Distance (km)')
ylabel('Depth (m)')
xlim([0 50])
ylim([0 3000])
title('test2 oast') 

set(gca,'fontsize',25)
set(gca, 'YDir','reverse')

colorbar
caxis([-125 -70]);
colormap jet
shading interp

%% Plotting diff_oast

x = linspace(0,50,153);
y = linspace(1,3000,300);

figure
h = pcolor(x,y,diff_oast(:,:,4));
set(h, 'EdgeColor', 'none');
xlabel('Distance (km)')
ylabel('Depth (m)')
xlim([0 50])
ylim([0 3000])
title('Difference between test c and test 2') 

set(gca,'fontsize',25)
set(gca, 'YDir','reverse')

colorbar
caxis([-20 20]);
colormap jet
shading interp

%% plotting slice

figure
plot(x(10:end),abs(mean(diff_oast(6:8,10:end,6),1)))
xlabel('Distance (km)')
xlim([3 50])
ylabel('Difference (dB)')
set(gca,'fontsize',25)
grid on

