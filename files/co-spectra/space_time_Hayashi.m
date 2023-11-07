% Space-Time Spectral Analysis
%
% Computing the space-time spectrum for the covariance of two time series
% Format: [East,West] = space_time(u,v)
%
% Dimensions of the input (u,v)
% 2d: longitude-time
% 3d: longitude-time-latitude
%
% Dimensions of the output (East, West)
% 2d: wavenumber-frequency
% 3d: wavenumber-frequency-latitude
%
% East (West) denotes the eastward (westward) propagating waves.
%
% See details in
% Hayashi, Y. (1971). A Generalized Method of Resolving Disturbances into Progressive and Retrogressive Waves by Space Fourier and Time Cross-Spectral Analyses. Journal of the Meteorological Society of Japan. Ser. II, 49(2), 125–128. https://doi.org/10.2151/jmsj1965.49.2_125

% Note: The time spectrum of a real time series is symmetric about the nyquist frequency, 
% so we only take the first half of the spectrum in the end.

function [East,West] = space_time(u,v)
warning off MATLAB:divideByZero

if(ndims(u) == 2)
   [East,West] = space_time_2d(u,v);
elseif(ndims(u) == 3)
   [East,West] = space_time_3d(u,v);
end

return

%=================================================================================
function [East,West] = space_time_2d(u_xt,v_xt)

num_lon=size(u_xt,1);
num_time=size(u_xt,2);

%-----
u_kt = fft(u_xt,[],1)/num_lon;
C_u_kt = real(u_kt);
S_u_kt = -imag(u_kt);

C_u_kw = fft(C_u_kt,[],2)/num_time;
A_u = real(C_u_kw);
B_u = -imag(C_u_kw);

S_u_kw = fft(S_u_kt,[],2)/num_time;
a_u = real(S_u_kw);
b_u = -imag(S_u_kw);

K_u_kw = (A_u-b_u).^2+(-B_u-a_u).^2; % k,w
K_u_k_w= (A_u+b_u).^2+(B_u-a_u).^2; % k,-w
phi_u_kw = atan((-B_u-a_u)./(A_u-b_u));
phi_u_k_w= atan((+B_u-a_u)./(A_u+b_u));

%------
v_kt = fft(v_xt,[],1)/num_lon;
C_v_kt = real(v_kt);
S_v_kt = -imag(v_kt);

C_v_kw = fft(C_v_kt,[],2)/num_time;
A_v = real(C_v_kw);
B_v = -imag(C_v_kw);

S_v_kw = fft(S_v_kt,[],2)/num_time;
a_v = real(S_v_kw);
b_v = -imag(S_v_kw);

K_v_kw = (A_v-b_v).^2+(-B_v-a_v).^2; % k,w
K_v_k_w= (A_v+b_v).^2+(B_v-a_v).^2; % k,-w
phi_v_kw = atan((-B_v-a_v)./(A_v-b_v));
phi_v_k_w= atan((+B_v-a_v)./(A_v+b_v));

%------
W = (((A_u-b_u).*(A_v-b_v)+(-B_u-a_u).*(-B_v-a_v)))*2;
E = (((A_u+b_u).*(A_v+b_v)+(+B_u-a_u).*(+B_v-a_v)))*2;
West(1:(num_lon/2+1),1:(num_time/2+1))=W(1:(num_lon/2+1),1:(num_time/2+1));
East(1:(num_lon/2+1),1:(num_time/2+1))=E(1:(num_lon/2+1),1:(num_time/2+1));

return

%=================================================================================
function [East,West] = space_time_3d(u_xty,v_xty)

for j=1:size(u_xty,3)
    [East(:,:,j),West(:,:,j)] = space_time_2d(u_xt(:,:,j),v_xt(:,:,j));
end

return

