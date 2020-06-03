
%% Perform xcorr
x = linspace(3,50,153);
y = linspace(1,3000,300);

x_amend = [nan nan x nan nan];

xcorr_mat = [];
maxcorr = [];
for i = 3:length(x)-2
    seg = -oast(5:9,i-2:i+2,1);
    replica = -oast(5:9,:,1);
    
    temp_mat = normxcorr2(seg,replica);
    
    [~,arg] = max(temp_mat(5,:));
    maxcorr = [maxcorr x_amend(arg)];

    xcorr_mat = [xcorr_mat; temp_mat(5,:)];
end
xcorr_mat = xcorr_mat.';

%% Plot

figure
%imagesc(x(3:end-2),x,xcorr_mat(3:end-2,:))
%xlim([3,50]);
%ylim([3,50]);

h = pcolor(x(3:end-2),x,xcorr_mat(3:end-2,:));
set(h, 'EdgeColor', 'none');
xlabel('Distance (km)')
ylabel('Distance (km)')
xlim([3,50]);
ylim([3,50]);

title('Correlation coefficient between test 2 and test 2 at array depth') 
set(gca,'fontsize',25)
caxis([0 1]);
colorbar

hold on
plot(x,x,'-.k','LineWidth',1.5)
plot(x(3:end-2),maxcorr,'ro','MarkerSize',5,'LineWidth',1.5)
%colormap jet
%shading interp

%%

seg = oast(5:9,15:19,4);
replica = oast(5:9,:,1);
    
test = normxcorr2(seg,replica);

figure
plot(x,test(5,3:end-2))