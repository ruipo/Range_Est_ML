%% Element Locations
N = 32;
% 0.75m spacing in the middle
N2 = 22;
z2 = zeros(N2,1);
d = 0.75;
for n = 0:N2-1
    z2(n+1) = -(n-(N2-1)/2)*d; 
end

% 1.5m spacing on top
N1 = 5;
z1 = zeros(N1,1);
d = 1.5;
z1(end) = z2(1) + d;

for n = 1:N1-1
    z1(end-n) = z1(end-(n-1)) + d;
end

% 1.5m spacing on bottom
N3 = 5;
z3 = zeros(N3,1);
d = 1.5;
z3(1) = z2(end) - d;

for n = 2:N3
    z3(n) = z3(n-1) - d;
end

z = [z1; z2; z3];
p = [zeros(1,N) ; zeros(1,N) ; z'];
p = p';


%%
elev = -90:1:90;
az = 0;
c = 1435;
f = 850;
weighting = 'icex_hanning';


[beamform_output] = beamform_covmat(oasn_cov(:,:,1:10),p,elev,az,c,f,weighting);
beamform_db = 10*log10(beamform_output);

%%

figure

for i = 1:size(beamform_output,2)
hold on
plot(beamform_db(:,i),elev,'linewidth',3)
set(gca,'Fontsize',30);
xlabel('Power (dB)')
ylabel('Elevation (Degrees)')
ylim([-90 90]);
grid on
pause
end
