function [ f_pitch,autocorr ]=autocorr_error_algorithm( x,fs )

p=10; % prediction order
[coef_x,g]=lpc(x,p);
x_error=filter(1-coef_x',1,x);

autocorr=xcorr(x_error);
autocorr=autocorr(ceil(length(autocorr)/2)+1:end);

                           %% Pitch estimation
% Finding the maximum
[peaks,places]=findpeaks(autocorr);
[max_peak,max_peak_place]=max(peaks);
max_pos=places(max_peak_place); 
                                           
T_pitch=max_pos/fs;
f_pitch=1/T_pitch;

end