% sloped_btm.m
% ram PE sloped bottom example
%

%compile the c programs 
mex -O matrc.c
mex -O solvetri.c

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% *** set up Munk SSP ***

% GET zw and cw from SSPs.xlsx
c0=mean(cw(:));

%range independent SSP
cw=cw';
rp=0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% source depth
zsrc=9;

%source frequency
fc=109;


%% rcvr range/ SSP
deltar=100;
deltaz=0.25;

%0-3km
% rg=0:deltar:3000.0;
% rb = rg;
% zslope = -0.0138;
% b = 216.5;
% zb = zslope*rb+b;
% zb = fliplr(zb);
% 
% np=4;
% ns=1;
% rs=100.0;

%3-10km
rg=0:deltar:10000.0;
rb = rg;
zslope = 0.0168;
b = 115.7;
zb = zslope*rb+b;
zb(1:61) = 216.5;
zb = fliplr(zb);

np=4;
ns=1;
rs=100.0;

%% bottom params

% %0-3km
% zs=[216.5 240 1040];
% cs=[1580 3000 5000];

% %3-10km
zs=[283.7 307.2 1107.2];
cs=[1580 3000 5000];

% %0-3km
% zr=[0 216.5 240 1040];
% rho=[1 1.76 2.06 2.66];

% %3-10km
zr=[0 283.7 307.2 1107.2];
rho=[1 1.76 2.06 2.66];

% %0-3km
% za=[216.5 240 1040];
% attn=[0.3 0.085 0.0283];

% %3-10km
za=[283.7 307.2 1107.2];
attn=[0.3 0.085 0.0283];

%% output depth decimation
zmax = max(zb);
dzm=1;
dim=2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

frqq=fc;

[psi, zg, rout]=ram(frqq,zsrc,dim,rg,deltar,zmax,deltaz,dzm,...
       c0,np,ns,rs,rb,zb,rp,zw,cw,zs,cs,zr,rho,za,attn);

nzo=length(zg);
nro = length(rout);
psif=complex(zeros(nzo,nro, 1));

omega=2*pi*frqq; k0=omega/c0;
if dim==2 %2-D
scale=j*exp(j*omega/c0*rout)/sqrt(8*pi*k0);
else %3-D
scale=exp(j*(omega/c0*rout + pi/4))/4/pi;
end
psif(:,:,1)=scale.*psi;

%% Plot Amplitude
figure
imagesc(rout,zg,20*log10(abs(psif)))
hold on
plot(rb,zb,'k')
