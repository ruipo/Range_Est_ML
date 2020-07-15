function [rhob,alpw,alpb,ksqw,ksqb]=profl(r,zg,c0,omega,...
                        rp,zw,cw,zb,cb,zr,rho,za,attn)

  ci=complex( 0, 1);
  eta=1/(40*pi*log10(exp(1)));

  [ig, ir]=min(abs(rp-r));

% Set up the profiles.
  cwg=gorp(zw,cw(ir,:),zg);
  cbg=gorp(zb,cb(ir,:),zg);
  rhob=gorp(zr,rho(ir,:),zg);
  attng=gorp(za,attn(ir,:),zg);

  ksqw=(omega./cwg).^2-(omega/c0)^2;
  ksqb=((omega./cbg).*(1+ci*eta*attng)).^2-(omega/c0)^2;
  alpw=sqrt(cwg/c0);
  alpb=sqrt(rhob.*cbg/c0);

return

function v = gorp(x,y,u)

  if length(y)==1
    v=y*ones(size(u));
    return;
  end

  v=interp1(x,y,u,'linear', y(1));
  ind=find( u>max(x)); 
  v(ind)=y(end);

return

