% See details in the reference
% Chen, G., J. Lu, D. A. Burrows, and L. R. Leung, 2015: 
% Local finite-amplitude wave activity as an objective diagnostic of midlatitude extreme weather. 
% Geophys. Res. Lett., 42, 10,952-10,960, doi:10.1002/2015GL066959
%
function [qz, Qe, Ae, dQedY, AeL, AeLp, AeLm]=tracer_eq_1var_2d_local3(lon, lat, lonb, latb, q_tracer, sort_ascend)
%--------------------------------------------------------------------------------------------------------
%
% Hybrid Modified Lagrangian-Mean (MLM) and Eulerian diagnostics
% both Eulerian and Lagrangian variables are output at the input latitudinal grids
%
% input variables: lon, lat   : grid box centers (degrees)
%                  lonb, latb : grid box boundaries (degrees) 
%                  q_tracer   : 2d tracer, stored in the format of q_tracer(lon,lat)
%                  sort_ascend: the direction of sorting q_tracer, default='ascend'
%                  note： the direction of lat and latb is assumed to increase with the lat/latb index
%
% output variables: qz: Eulerian-mean q
%                   Qe: Lagrangian-mean Q
%                   Ae: wave activity
%                   dQedY: Lagrangian gradient of Q (per radian)
%                   AeL: local wave activity as a function of longitude and latitude
%
%--------------------------------------------------------------------------------------------------------

%constants;
RADIUS=6.371e6;

if(nargin==5)
  sort_ascend ='ascend';
end

  if size(lon,1)==1
    lon=lon';
  end
  
  if size(lonb,1)==1 
    lonb=lonb';
  end
  
  if size(lat,1)==1 
    lat=lat';
  end
  
  if size(latb,1)==1 
    latb=latb';
  end

  ni=length(lon);
  nj=length(lat);
  num_point=ni*nj;
  
  sin_latb=sin(latb*pi/180);
  cos_lat=cos(lat*pi/180);
  sin_lat=sin(lat*pi/180);

%%% calculate the mass for each grid box
  dX=abs(lonb(2:(ni+1))-lonb(1:ni))*pi/180;
  dY=abs(sin_latb(2:(nj+1))-sin_latb(1:nj));
  
  dM2=dX*dY';
  qdM2=squeeze(q_tracer).*dM2;
  qz=sum(qdM2,1)./sum(dM2,1);
  
%%% indices for longitude and latitude
  id=[1:ni]'*ones(1,nj);
  jd=ones(ni,1)*[1:nj];
  
%%% Eulerian integrals between lat(j-1) and lat(j) for j=1,...,nj+1
  dMb(nj+1)  = sum(dM2(:,nj),1)*0.5;
  qdMb(nj+1) = sum(qdM2(:,nj),1)*0.5;
  dMb(1)     = sum(dM2(:,1),1)*0.5;
  qdMb(1)    = sum(qdM2(:,1),1)*0.5;
  dMb(2:nj)   = sum(dM2(:,1:(nj-1)),1)*0.5 + sum(dM2(:,2:nj),1)*0.5;
  qdMb(2:nj)  = sum(qdM2(:,1:(nj-1)),1)*0.5 + sum(qdM2(:,2:nj),1)*0.5;

% Lagrangian integrals between the two Q contours corresponding to the equivalent latitudes of lat(j-1) and lat(j)
% sort the tracer field first and then the Lagrangian integral reduces to summation
% by default, reshape the columns (constant latitude) first
  q1=reshape(squeeze(q_tracer),num_point,1);
  dM1=reshape(dM2,num_point,1);
  id1=reshape(id,num_point,1);
  jd1=reshape(jd,num_point,1);
  
  [q_sort, q_pos]=sort(q1,strtrim(sort_ascend));
  dM1_sort=dM1(q_pos);
  id1_sort=id1(q_pos);
  jd1_sort=jd1(q_pos);

  n = num_point;
  dMe(1:(nj+1))  = 0.;
  qdMe(1:(nj+1)) = 0.;
  dMLp(1:ni,1:nj)= 0.;
  AeLp(1:ni,1:nj)= 0.;
  dMLm(1:ni,1:nj)= 0.;
  AeLm(1:ni,1:nj)= 0.;
  for j=(nj+1):-1:2
     while((dMe(j)<dMb(j)) && (n>=1))
      dMe(j)  = dMe(j)  + dM1_sort(n);
      qdMe(j) = qdMe(j) + q_sort(n)*dM1_sort(n);
      
      i=id1_sort(n);
      jQ=jd1_sort(n);
%%    integral for q>=Qe(j-1) and jQ<=j-1
      jj=j-1;
      while(jQ<=jj)
        if(jQ==jj)
	  wgt = 0.5;
	else
	  wgt = 1.0;
	end
        dMLp(i,jj) = dMLp(i,jj) + dM1_sort(n)*wgt;
        AeLp(i,jj) = AeLp(i,jj) + q_sort(n)*dM1_sort(n)*wgt;
        jj=jj-1;
      end
%%    integral for q<=Qe(j) and jQ>=j
      jj=j;
      while(jQ>=jj)
        if(jQ==jj) 
	  wgt = 0.5;
	else
	  wgt = 1.0;
	end
        dMLm(i,jj) = dMLm(i,jj) + dM1_sort(n)*wgt;
        AeLm(i,jj) = AeLm(i,jj) + q_sort(n)*dM1_sort(n)*wgt;
        jj=jj+1;
      end      
      n = n-1;
     end
     
%% correction for the Q boundary
      Qe(j-1)  = q_sort(n+1);
      dMe(j-1) = dMe(j)-dMb(j);
      qdMe(j-1)= q_sort(n+1)*dMe(j-1);
      
      i=id1_sort(n+1);
      jQ=jd1_sort(n+1);
%%    integral for q>=Q(j-1) and jQ<=j-1
      jj=j-1;
      if(jQ<=jj)
        if(jQ==jj) 
	  wgt = 0.5;
	else
	  wgt = 1.0;
	end
	dMLp(i,jj) = dMLp(i,jj) - dMe(j-1)*wgt;
        AeLp(i,jj) = AeLp(i,jj) - qdMe(j-1)*wgt;
      end
%%    integral for q<=Qe(j-1) and jQ>=j-1
      jj=j-1;
      if(jQ>=jj)
        if(jQ==jj) 
	  wgt = 0.5;
	else
	  wgt = 1.0;
	end
	dMLm(i,jj) = dMLm(i,jj) + dMe(j-1)*wgt;
        AeLm(i,jj) = AeLm(i,jj) + qdMe(j-1)*wgt;
      end
      dMe(j)   = dMe(j)-dMe(j-1);
      qdMe(j)  = qdMe(j)-qdMe(j-1);
  end
  
  dMe(1) = dMe(1)+sum(dM1_sort(1:n));
  qdMe(1)= qdMe(1)+sum(q_sort(1:n).*dM1_sort(1:n));

  while(n>=1)
      i=id1_sort(n);
      jQ=jd1_sort(n);
      jj=1;
      while(jQ>=jj)
        if(jQ==jj)
	  wgt = 0.5;
	else
	  wgt = 1.0;
	end
	dMLm(i,jj) = dMLm(i,jj) + dM1_sort(n)*wgt;
        AeLm(i,jj) = AeLm(i,jj) + q_sort(n)*dM1_sort(n)*wgt;
	jj=jj+1;
      end
      n = n-1;
  end

  dQedY(1) = (-1.5*Qe(1) +2.*Qe(2) -0.5*Qe(3))/(-1.5*sin_lat(1) +2.*sin_lat(2) -0.5*sin_lat(3))*cos_lat(1);
  dQedY(nj)= (0.5*Qe(nj-2) -2.*Qe(nj-1) +1.5*Qe(nj))/(0.5*sin_lat(nj-2) -2.*sin_lat(nj-1) +1.5*sin_lat(nj))*cos_lat(nj);
  dQedY(2:(nj-1)) = (Qe(1:(nj-2))-Qe(3:nj))./(sin_lat(1:(nj-2))'-sin_lat(3:nj)').*cos_lat(2:(nj-1))';

% Wave activity
  Ae(nj) = qdMe(nj+1)-qdMb(nj+1);
  for j = (nj-1):-1:1
    Ae(j) = Ae(j+1)+(qdMe(j+1)-qdMb(j+1));
  end
  Ae = Ae*RADIUS/(2*pi)./cos_lat';

  AeLp = AeLp-(ones(ni,1)*Qe).*dMLp;
  AeLp = AeLp*RADIUS./(dX*cos_lat');
  
  AeLm = AeLm-(ones(ni,1)*Qe).*dMLm;
  AeLm = -AeLm*RADIUS./(dX*cos_lat');

  AeL = AeLp+AeLm;
