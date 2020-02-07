function [plev, BA, BC, NB] = wb_detect(lon,lat,pfull,pv,cc)
% Usage:
% [plev, BA, BC, NB] = wb_detect+up_lenscale(lon,lat,pfull,pv,cc)
% rescale the counts of WB events to regular grid numbers %
% so that it can be interpreted as a equavelent length    %
%%%cc = [-2.8:.2:2.8]*1.e-4;
plev=pfull(2:11); % level 73 to 525mb
plng=length(plev);

% the following are 3dim indices, storing the indices of the wave breaking locations %
  BA=[]; %Anticyclonic breaking points
  BC=[]; %Cyclonic breaking points
  NB=[]; %no breaking points

for ll=2:11

pv5=squeeze(pv(ll,:,:));
figure(1);
[Cs,H] = contour(lon,lat,pv5,cc);

lCs=size(Cs,2);
yint=[];
for ii=1:lCs
 if Cs(2,ii)==fix(Cs(2,ii))
 yint=[yint;ii];
 end
end

lind0=length(yint); % each yint serves as an index for a contour!!

%find the first and last lat index to if it is confined interior 
%then eliminate it since it is not circumpolar %
% identify the index for yint for the subgroup of circumpolar pv contours %
% the lon index is ordered starting from west (0 lon), and lat index is ordered form south (lowest PV value) % 

%Note: BC and BA should be reversed in the SH 
%  So: recommend reverse the SH and use the same detection algorithm.
%Note: exlude all the detection <10deg lat.

pvcind=[];

for nn=1:lind0-1

  if Cs(1,yint(nn)+1)<=10 & Cs(1,yint(nn+1)-1)>=350 & abs(mean( Cs(2,yint(nn)+1:yint(nn+1)-1) ))>10
  %get the index
  pvcind = [pvcind; nn];
  %sample the (lon,lat) values on one counter
  [Cxy] = [Cs(1,yint(nn)+1:yint(nn+1)-1)'  Cs(2,yint(nn)+1:yint(nn+1)-1)'];
  Cx=Cxy(:,1); Cy=Cxy(:,2);
  %%%hold on; plot(Cx,Cy,'k--');
  kkl = length(Cx);
     for kk=2:kkl-1
       if Cx(kk-1) > Cx(kk) & Cx(kk) > Cx(kk+1)
         if Cy(kk-1) < Cy(kk) 
           if any(Cx(kk)==lon)
             BC=[BC;Cx(kk),Cy(kk),pfull(ll)];
           end
         elseif  Cy(kk-1) > Cy(kk) 
           if any(Cx(kk)==lon)
             BA=[BA;Cx(kk),Cy(kk),pfull(ll)];
           end
         else
           NB=[NB;Cx(kk),Cy(kk),pfull(ll)];        
         end
       end
     end %end of kk loop
  end %end of "if Cs"

end
%%hold on;plot(squeeze(BA(:,1,1)),squeeze(BA(:,2,1)),'k+','markersize',7)

%%
nn=lind0;
if Cs(1,yint(nn)+1)<=10 & Cs(1,end)>=350
  %get the index
  pvcind = [pvcind; nn];
  %sample the (lon,lat) values on one counter
  [Cxy] = [Cs(1,yint(nn)+1:end)'  Cs(2,yint(nn)+1:end)'];
  Cx=Cxy(:,1); Cy=Cxy(:,2);
  kkl = length(Cx);
     for kk=2:kkl-1
       if Cx(kk-1) > Cx(kk) & Cx(kk) > Cx(kk+1)
         if Cy(kk-1) < Cy(kk)
           if any(Cx(kk)==lon)
             BC=[BC;Cx(kk),Cy(kk),pfull(ll)];
           end
         elseif  Cy(kk-1) > Cy(kk)
           if any(Cx(kk)==lon)
             BA=[BA;Cx(kk),Cy(kk),pfull(ll)];
           end
         else
           NB=[NB;Cx(kk),Cy(kk),pfull(ll)];        
         end
       end
     end
  end %end of "if Cs"


%%%%%%%%%%%%%%%%%

%hold on;plot(BA(:,1),BA(:,2),'b+')
%hold on;plot(BC(:,1),BC(:,2),'ro')

%%%%%%%%%%%%%%%%%
%clf;
end; %end of levels
%%%%%%%%%%%
return


