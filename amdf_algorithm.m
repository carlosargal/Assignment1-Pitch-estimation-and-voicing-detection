function [ f_pitch ] = amdf_algorithm( x,fs )

n=length(x);
for k=1:n-1
    addition=0;
    for j=0:(n-k-1)
        addition=addition+abs(x(j+k+1)-x(j+1));
    end
    D(k)=addition/(n-k-1);
end

% Graphical display of AMDF
    %figure(1)
    %plot(D)
    %xlabel('k'); ylabel('D(k)')
    %title('AMDF')
    %grid on

                           %% Pitch estimation
% Finding the minimum
aux_inf=floor(length(D)*0.01);
aux_sup=floor(length(D)*0.4);

[minimum min_pos]=min(D(aux_inf:end-aux_sup));
min_pos=min_pos+aux_inf;

T_pitch=min_pos/fs;
f_pitch=1/T_pitch;

end