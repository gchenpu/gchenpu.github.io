% function plot_spec_tk(freq, wavenum, K_e, K_w, step)
% (freq,wavenum) :: K_e, K_w
function plot_spec_tk(freq, wavenum, K_e, K_w, step)
nf=length(freq); 
max_k=10; kk = 2:max_k+1; max_f =max(freq); ff=1:1:nf;
K_e(1,:,:)=nan; K_w(1,:,:)=nan;
%figure;
[c1,h1]=contour(-freq(ff), wavenum(kk),...
 squeeze(K_w(ff,kk))',step:step:step*20,'-k'); hold on;
[c2,h2]=contour(freq(ff), wavenum(kk),...
 squeeze(K_e(ff,kk))',step:step:step*20,'-k');
[c3,h3]=contour(-freq(ff), wavenum(kk),...
 squeeze(K_w(ff,kk))',-step*20:step:-step,'--k');
[c4,h4]=contour(freq(ff), wavenum(kk),...
 squeeze(K_e(ff,kk))',-step*20:step:-step,'--k');
%axis([-max_f,max_f,1,max_k]);
%xlabel('westward               period(day)               eastward','fontsize',20);
axis([-1/10,max_f,1,max_k]);
xlabel('period (day)','fontsize',12);
ylabel('zonal wavenumber','fontsize',12);
set(gca,'XTick',[-1/2,-1/3,-1/5,-1/10,-1/30,1/30,1/10,1/5,1/3,1/2],...
        'XTickLabel',{'2','3','5','10','30','30','10','5','3','2'},...
        'Ytick',1:max_k,'fontsize',12);
line([0,0],[1,max_k],'linestyle','-.','color','k');
grid on;
