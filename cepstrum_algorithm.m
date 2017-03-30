function [ f_pitch ] = cepstrum_algorithm( x,fs )

signalfft=fft(x);
cepstrum_signal=(ifft(log10(abs(signalfft))));

    
                           %% Pitch estimation
% Finding the maximum
[maximum,max_pos]=max(cepstrum_signal(20:(end/2),1));
max_pos=max_pos+20; % quefrency

f_pitch=fs/max_pos;

end