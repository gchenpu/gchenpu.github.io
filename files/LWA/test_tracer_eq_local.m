% ------------------------------------------------------------------------------------
% sample script to run the local wave activity code with idealized wave perturbations
% ------------------------------------------------------------------------------------
  close all; clear;
  constants;

  % longitude and latitude edges
  lonb = [0:2.5:360];
  latb = [-90:2.5:90];
  % longitude and latitude centers
  lon  = 0.5*(lonb(1:(end-1))+lonb(2:end));
  lat  = 0.5*(latb(1:(end-1))+latb(2:end));
  
  ni=length(lon);
  nj=length(lat);
  zeta_eddy=5e-5;  % magnitude of idealized perturbations
  
  cos_lat=cos(lat*pi/180.);
  sin_lat=sin(lat*pi/180.);
  
  for j = 1:nj
      yy              = (lat(j)- 45.)/15.;
      vor_eddy(1:ni,j)= zeta_eddy*cos_lat(j)*exp(-yy*yy)*cos(5*lon(1:ni)*pi/180.);
      vor_mean(1:ni,j)= 2*OMEGA*sin_lat(j);
  end
  
  vor = vor_mean+vor_eddy;
  
%  sigma = ones(size(vor));
 
%  [qz, Qe, Ae, dQedY, AeL]=tracer_eq_1var_2d_local(lon, lat, lonb, latb, vor);
  [qz, Qe, Ae, dQedY, AeL, AeLp, AeLm]=tracer_eq_1var_2d_local3(lon, lat, lonb, latb, vor);
  
  set_figure(1.6,1.6);
  colormap(jet);
  subplot(2,7,[1,3]);
  h1=contourf(lon,lat,detrend(vor)');
  set(gca,'fontsize',15,'ylim',[-90,90]);
  colorbar;
  title('q');
  
  subplot(2,7,[4]);
  h2(1)=plot(Ae,lat,'-k'); hold on;
  h2(2)=plot(mean(AeL,1),lat,'--r');
  set(gca,'fontsize',15,'ylim',[-90,90]);
  title('A');
  
  subplot(2,7,[5,7]);
  [c3,h3]=contourf(lon,lat,AeL');
  set(h3,'edgecolor','none');
  colorbar;
  set(gca,'fontsize',15,'ylim',[-90,90]);
  title('A');
  
  subplot(2,7,[8,10]);
  [c1,h1]=contourf(lon,lat,AeLp');
  set(h1,'edgecolor','none');
  colorbar;
  set(gca,'fontsize',15,'ylim',[-90,90]);
  title('A+');
  
  subplot(2,7,[11]);
  h2(1)=plot(mean(AeLp,1),lat,'-r'); hold on;
  h2(2)=plot(mean(AeLm,1),lat,'-b');
  set(gca,'fontsize',15,'ylim',[-90,90]);
  title('A');
  
  subplot(2,7,[12,14]);
  [c3,h3]=contourf(lon,lat,AeLm');
  set(h3,'edgecolor','none');
  colorbar;
  set(gca,'fontsize',15,'ylim',[-90,90]);
  title('A-');
