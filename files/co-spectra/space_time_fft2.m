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
% Use matlab's fft2 to deal with complex numbers

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

num_lon =size(u_xt,1);
num_time=size(u_xt,2);

u_kw = fft2(squeeze(u_xt))/(num_lon*num_time);
v_kw = fft2(squeeze(v_xt))/(num_lon*num_time);

% see explanations for the fft frequency here
% https://stackoverflow.com/questions/10758315/understanding-matlab-fft-example

West = 2*real(conj(v_kw(1:(num_lon/2+1), 1:(num_time/2+1))).*u_kw(1:(num_lon/2+1), 1:(num_time/2+1)));
East = 2*real(conj(v_kw(1:(num_lon/2+1), [1, end:-1:(num_time/2+1)])).*u_kw(1:(num_lon/2+1), [1, end:-1:(num_time/2+1)]));

return

%=================================================================================
function [East,West] = space_time_3d(u_xty,v_xty)

for j=1:size(u_xty,3)
    [East(:,:,j),West(:,:,j)] = space_time_2d(u_xt(:,:,j),v_xt(:,:,j));
end

return
