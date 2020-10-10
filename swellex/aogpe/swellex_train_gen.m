% sloped_btm.m
% ram PE sloped bottom example
%

%compile the c programs 
mex -O matrc.c
mex -O solvetri.c

%% load SSP, source range and bottom depth

load('swellex_src_range_depth_ssp.mat');
src_range_full([57 78 99 113 190 204 211 225 246 267 281 288 302 316 407 414 428 449 456 463 470 491 498 505 512 540 547 561 582 589 603 624 631 645 652 666 673 687 694 715 722 729 764 771 831 852 873 887 943 964]) = [];
src_bdepth_full([57 78 99 113 190 204 211 225 246 267 281 288 302 316 407 414 428 449 456 463 470 491 498 505 512 540 547 561 582 589 603 624 631 645 652 666 673 687 694 715 722 729 764 771 831 852 873 887 943 964]) = [];

%VLA locs
vla_depth = [94.125 99.755 105.38 111 116.62 122.25 127.88 139.12 144.74 150.38 155.99 161.62 167.26 172.88 178.49 184.12 189.76 195.38 200.99 206.62 212.25];
repmat = zeros(21,length(src_range_full));
%range independent SSP
ssp = ssp.'; % cw    	sound speed(nr,nzw)
ssp(56:end) = [];
zw = [0:1:216.5]; % zw    	sound speed grid depth(nzw)
depth(56:end) = [];
cw = interp1(depth,ssp,zw);

% get mean of SSP
c0=mean(cw);

rp=0;

% source depth and rcvr bottom depth
zsrc=9;
rcvr_bdepth = 216.5;

%source frequency
fc=109;

%% rcvr range

for ii = 1:length(src_range_full)
    ii
    %if ~ismember(ii,[57 78 99 113 190 204 211 225 246 267 281 288 302 316 407 414 428 449 456 463 470 491 498 505 512 540 547 561 582 589 603 624 631 645 652 666 673 687 694 715 722 729 764 771 831 852 873 887 943 964])
    rcvr_range = src_range_full(ii)*1000;
    src_bdepth = src_bdepth_full(ii);

    deltar=3.5; % dr    	range step (need to be small enough for PE to converge)
    deltaz=0.25; % dz    	depth grid increment (need to be smaller for higher freq, for 75hz, use ~0.5)

    rg=0:deltar:rcvr_range; % rg		vector of output (recvr) ranges
    rb = rg; % rb		bathymetry range 
    zslope = (rcvr_bdepth-src_bdepth)/(rcvr_range-0);
    b = src_bdepth;
    zb = zslope*rb+b; % zb		bathymetry

    np=4; % np    	# of pade coefficients (n=4 is usually good)
    ns=1; % ns    	# of stability terms
    rs=10.0; % rs    	stability range

    % bottom params

    zs=[max([src_bdepth rcvr_bdepth]) 307.2 1107.2]; % zs    	sediment speed grid depth(nzs)
    cs=[1580 3000 5000]; % cs    	sediment speed(nr,nzs)

    zr=[0 max([src_bdepth rcvr_bdepth]) 307.2 1107.2]; % zr		density depth grid(nzr)
    rho=[1 1.76 2.06 2.66]; % rho		density(nr,nzr)

    za=[max([src_bdepth rcvr_bdepth]) 307.2 1107.2]; % za		attenuation depth grid(nza)
    attn=[0.3 0.085 0.0283]; % attn		attenuation(nr,nza)

    zmax = max(zb); % zmax  	max depth (max bottom depth)
    dzm=1; % dzm           decimate output depth grid (dzm=1, no decimation)
    dim=2; % dim		2-d starter (dim=2) or 3-d starter (dim=3)

    % run RAM
    [psi, zg, rout]=ram(fc,zsrc,dim,rg,deltar,zmax,deltaz,dzm,...
           c0,np,ns,rs,rb,zb,rp,zw,cw,zs,cs,zr,rho,za,attn);

    nzo=length(zg);
    nro = length(rout);
    psif=complex(zeros(nzo,nro,1));

    omega=2*pi*fc; k0=omega/c0;
    if dim==2 %2-D
    scale=j*exp(j*omega/c0*rout)/sqrt(8*pi*k0);
    else %3-D
    scale=exp(j*(omega/c0*rout + pi/4))/4/pi;
    end
    psif(:,:,1)=scale.*psi;


    repf = psi(:,end);
    for zz = 1:length(vla_depth)
        [~,ind] = min(abs(zg-vla_depth(zz)));
        repmat(zz,ii) = repf(ind);
    %end
    end
end

%% Plot Amplitude
figure
imagesc(rout,zg,20*log10(abs(psif)))
hold on
plot(rb,zb,'k')


