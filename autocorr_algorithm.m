function [ f_pitch ] = autocorr_algorithm( x,fs )

autocorr=xcorr(x);
autocorr=autocorr(ceil(length(autocorr)/2):end);

                           %% Pitch estimation
% Finding the maximum
[peaks,places]=findpeaks(autocorr);
[max_peak,max_peak_place]=max(peaks);
max_pos=places(max_peak_place); 

T_pitch=max_pos/fs;
f_pitch=1/T_pitch;
end