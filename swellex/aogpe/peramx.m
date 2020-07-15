% peramx.m
% ram PE example
%

%% compile the c programs 
mex -O matrc.c
mex -O solvetri.c

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% *** set up Munk SSP ***

zw=0:1:5000;
zw=zw(:);

cw=cssprofile(zw);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% source depth
zsrc=1000;

%source frequency
fc=75;
Q=4;
%time window 
T=3;

%src-rcvr range
rmax=100000.0;
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%range independent
cw=cw';
rp=0;
nrp=length(rp);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%range dependent
%rp=xax;
%nrp=length(rp);
%cw=cw';
%cw=repmat(cw, nrp, 1);
%
%% clear xax delc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

c0=mean(cw(:));

rb=0;
zb=5000;
zb=max(zw)-400;

zs=0;
cs=1500*ones(nrp,1);
zs=zw;
cs=cw;

zr=0;
rho=1.0*ones(nrp,1);

zbm=max( zb);
za=[zbm+100 zbm+300];
attn=[0.5 5];
attn=ones(nrp,1)*attn;
clear zbm

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

bw=fc/Q;
fs=4*fc;
dt=1/fs;
N=fs*T;
df=fs/N;

frq=[df:df:bw];
frq=[-fliplr(frq) 0 frq]+fc;
nf=length(frq)
nyqst=ceil((nf+1)/2);

wind=sinc( (frq-fc)/bw);
fcm=trapz( frq, frq.*wind.^2)/trapz(frq,wind.^2)
bwrms=sqrt(trapz( frq, (frq-fc).^2.*wind.^2)/trapz(frq,wind.^2))
pwrms=1/2/pi/bwrms

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

zmax=max(zw);
deltaz=0.5;
deltar=250;

np=4;
ns=1;
rs=10000.0;

%% output depth decimation
dzm=50;
zg=[0:deltaz:zmax];
nzo=length(zg(1:dzm:end));
clear zg

psif=complex(zeros( nzo, nf));

dim=2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ecputime=clock;
cput=cputime;

for iff=1:nf
  frqq=frq(iff)

  [psi, zg, rout]=ram( frqq,zsrc,dim,rmax,deltar,zmax,deltaz,dzm,...
           c0,np,ns,rs,rb,zb,rp,zw,cw,zs,cs,zr,rho,za,attn);

  omega=2*pi*frqq; k0=omega/c0;
  if dim==2 %2-D
    scale=j*exp(j*omega/c0*rout)/sqrt(8*pi*k0);
  else %3-D
    scale=exp(j*(omega/c0*rout + pi/4))/4/pi;
  end
  psif(:,iff)=scale*psi;
end

ecputime=etime( clock, ecputime)
cput=cputime-cput
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tdelay=rout/c0;
nro=length(rout);
nzo=length(zg);

zmin=min(zg); zmax=max(zg);

taxis=tdelay(nro)+[0:N-1]/fs;
tmin=min(taxis); tmax=max(taxis);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ptz=zeros(nzo,N);
for iz=1:nzo
  data=wind.*conj(psif(iz,:)).*exp(i*2*pi*frq*tdelay(nro));
  data=[ data(nyqst:nf), zeros(1,N-nf), data(1:nyqst-1)];
  ptz(iz,:)=ifft( data);
end
clear iz data

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
threshold=-36;

figure(1);
cti=6; nsbi=6;
ncol=-nsbi*threshold/cti;
ntv=-threshold/ncol;
scale=[threshold+cti:(0-threshold)/(ncol):0]-ntv/2;
cmap=clrscl('wcbmry',ncol);
colormap(cmap);
clear nsbi ntv ncol

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pkdm=max(abs(ptz(:)));
data=20*log10( abs(ptz)/pkdm);
ind=find(data==-inf);
data(ind)=threshold;
clear ind pkdm

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clf
imagesc( scale, [0 1]', [scale' scale']', [threshold 0.0])
set( gca, 'position',  [0.1 0.1 0.2 0.02])
hold on
contour( scale, [0 1]', [scale' scale']', [threshold:cti:0], 'k')
hold off
set( gca, 'xtick', [threshold+cti 0]);
set( gca, 'ytick', []);
axis([ threshold+cti 0 0 1])
xlabel('Power (dB)');

axes;
set( gca, 'position',  [0.1 0.2 0.8 0.65])
imagesc( taxis, zg, data, [threshold 0.0]);
xlabel('travel time (s)');
ylabel('z (m)');
stt=sprintf('Split Step Pade PE intensity, rg=%8.0f', rout(nro));
title( stt)
grid on; zoom on
set( gca, 'xlim', [tmin tmax]);
set( gca, 'ylim', [zmin zmax]);
drawnow;



