function [fld,zg,rout]=ram(frq,zsrc,dim,rg,dr,zmax,dz,dzm,c0,np,ns,rs,...
                        rb,zb,rp,zw,cw,zs,cs,zr,rho,za,attn)

% frq		source frequency
% zsrc		source depth
% dim		2-d starter (dim=2) or 3-d starter (dim=3)
% rg		vector of output (recvr) ranges
% dr    	range step (need to be small enough for PE to converge)
% zmax  	max depth (max bottom depth)
% dz    	depth grid increment (need to be smaller for higher freq, for 75hz, use ~0.5)
% dzm           decimate output depth grid (dzm=1, no decimation)
% c0    	"mean" sound speed
% np    	# of pade coefficients (n=4 is usually good)
% ns    	# of stability terms
% rs    	stability range
% rb		bathymetry range 
% zb		bathymetry
% rp 		profile ranges(nr)
% zw    	sound speed grid depth(nzw)
% cw    	sound speed(nr,nzw)
% zs    	sediment speed grid depth(nzs)
% cs    	sediment speed(nr,nzs)
% zr		density depth grid(nzr)
% rho		density(nr,nzr)
% za		attenuation depth grid(nza)
% attn		attenuation(nr,nza)
%

  omega=2*pi*frq;
  k0=omega/c0;
  ci=complex(0,1);

  nz=fix(zmax/dz-0.5);
  zg=linspace( 0, zmax, nz+2);
  zgd=zg(1:dzm:end);

  rend=rg(end);
  rnow=0.0;
  if length(rg)>1
    rnow=rg(1);
  end
    
  dr=abs(dr);
  if (rend-rnow)<0 dr=-dr; end

  rsc=abs(rend-rnow)-rs;
  if rs<abs(dr) rsc=0; end

  % The initial profiles.
  [rhob,alpw,alpb,ksqw,ksqb]=...
    profl(rnow+dr/2,zg,c0,omega,rp,zw,cw,zs,cs,zr,rho,za,attn);
  [ig, ir]=min(abs(rp-(rnow+dr/2))); irl=ir;

  % The initial depth.
  rb=[rb(:); 2*rb(end)+dr]; zb=[zb(:); zb(end);];
  rint=rnow+dr/2;
  zbc=interp1(rb,zb,rint,'linear', zb(1));
  if (rint>max(rb)) zbc=zb(end); end
  izb=fix(1+zbc/dz); izb=max([2,izb]); izb=min([nz,izb]);

  % Self starter
  if length(zsrc)==1
    uu=zeros(nz+2,1);
    % Conditions for the delta function.
    zsc=1+zsrc/dz;
    izs=fix(zsc);
    delzs=zsc-izs;
    uu(izs)=(1-delzs)*sqrt(2*pi/k0)/(dz*alpw(izs));
    uu(izs+1)=delzs*sqrt(2*pi/k0)/(dz*alpw(izs));
    clear izs zsc delzs

    % Divide the delta function by (1-X)**2 to get a smooth rhs.
    pdu=complex(0); pdl=complex(-1);
    [r1,r2,r3,s1,s2,s3,f3]=matrc(k0,dz,izb,rhob,alpw,alpb,ksqw,ksqb,pdu,pdl);
    uu=complex(uu);
    uu=solvetri( izb,uu,r1,r2,r3,s1,s2,s3);
    uu=solvetri( izb,uu,r1,r2,r3,s1,s2,s3);

    if dim==2
      %(2-D)
      %Apply the operator (1-X)**2*(1+X)**(-1/2)*exp(ci*k0*dr*sqrt(1+X)).
      [pdu, pdl]=epade( np, ns, 2, k0, c0, abs(dr));
    else
      %(3-D)
      %Apply the operator (1-X)**2*(1+X)**(-1/4)*exp(ci*k0*dr*sqrt(1+X)).
      [pdu, pdl]=epade( np, ns, 0, k0, c0, abs(dr));
    end
    [r1,r2,r3,s1,s2,s3,f3]=matrc(k0,dz,izb,rhob,alpw,alpb,ksqw,ksqb,pdu,pdl);
    uu=solvetri( izb,uu,r1,r2,r3,s1,s2,s3);
    rnow=rnow+dr;

    % reverse propagation backwards to rnow
    [pdu, pdl]=epade( np, ns, 1, k0, c0, -abs(dr));
    [r1,r2,r3,s1,s2,s3,f3]=matrc(k0,dz,izb,rhob,alpw,alpb,ksqw,ksqb,pdu,pdl);
    uu=solvetri( izb,uu,r1,r2,r3,s1,s2,s3);
    rnow=rnow-dr;

    %% lossy propagation backwards to rnow
    %[pdu, pdl]=epade( np, ns, 1, k0, c0, abs(dr));
    %[r1,r2,r3,s1,s2,s3,f3]=matrc(k0,dz,izb,rhob,alpw,alpb,ksqw,ksqb,pdu,pdl);
    %uu=conj(uu);
    %uu=conj(solvetri( izb,uu,r1,r2,r3,s1,s2,s3));
    %rnow=rnow-dr;
  end

  % The propagation matrices.
  [pdu, pdl]=epade( np, ns, 1, k0, c0, abs(dr));
  [r1,r2,r3,s1,s2,s3,f3]=matrc(k0,dz,izb,rhob,alpw,alpb,ksqw,ksqb,pdu,pdl);

  %specified starting field
  if length(zsrc)==length(zg)
    uu=zsrc./f3;
  end

  fld=zeros(length(zgd), length(rg));

% March the acoustic field out in range.
  for irr=1:length(rg)
    rend=rg(irr);
  
    while 1
      if rnow==rend break; end
      upd=0;

      if abs(rend-rnow)<abs(dr)
        dr=rend-rnow;
        [pdu, pdl]=epade( np, ns, 1, k0, c0, abs(dr));
        upd=1;
      end

      % Varying bathymetry.
      rint=rnow+dr/2;
      zbc=interp1(rb,zb,rint,'linear', zb(1));
      if (rint>max(rb)) zbc=zb(end); end
      izl=izb; izb=fix(1+zbc/dz); izb=max([2,izb]); izb=min([nz,izb]);
      if izb~=izl upd=1; end

      % Varying profiles.
      [ig, ir]=min(abs(rp-(rnow+dr/2)));
      if ir~=irl
        irl=ir; upd=1;
        [rhob,alpw,alpb,ksqw,ksqb]=...
          profl(rnow+dr/2,zg,c0,omega,rp,zw,cw,zs,cs,zr,rho,za,attn);
      end 

      % Turn off the stability constraints.
      if abs(rend-rnow)<rsc
        ns=0; %ns=1;
        rsc=0; upd=1;
        [pdu, pdl]=epade( np, ns, 1, k0, c0, abs(dr));
      end

      if upd
        [r1,r2,r3,s1,s2,s3,f3]=...
          matrc(k0,dz,izb,rhob,alpw,alpb,ksqw,ksqb,pdu,pdl);
      end

      uu=solvetri( izb,uu,r1,r2,r3,s1,s2,s3);

      rnow=rnow+dr;
    end

    fldi=uu.*f3;
    fld(:,irr)=fldi(1:dzm:end);
    rout(irr)=rnow;
  end
  zg=zgd;
return

