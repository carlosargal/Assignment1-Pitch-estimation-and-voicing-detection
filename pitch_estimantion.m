                           %% ST
                        
% Assignment 1: Pitch Estimation and Voicing Detection.

% Carlos Arenas Gallego

%% This script is aiming to acquire different voice signals from a database
% and estimate their pitch with 4 different algorithms automatically.
clear all; close all; clc;

                %% Loading files and setting parameters

% It is necessary to run this script inside the previous database folder

% PDA-UE (Test database)
%
files_wav=dir('.\pda_ue\*.wav');
files_ref=dir('.\pda_ue\*.f0ref');
database=1;
fs=20000;
w_shift=15;
%}

% PTDB-TUB (Train database)
%{
cd('ptdb_tub/');

directory=pwd();
folder=list_folder;

i=1; 
count=0;
enter=length(folder); 
register=zeros(1,100);
register(i)=enter;     

while register(1) ~= 2
        
    if enter>=3
        cd(folder(enter).name);
        directory=pwd();
        folder=list_folder;
        file_wav=dir(fullfile(directory,'*.wav'));
        file_ref=dir(fullfile(directory,'*.f0ref'));
        i=i+1;
        enter=length(folder);
        register(i)=enter;
   
        if length(file_wav)==0
        else
            for j=1:length(file_wav)                
                files_wav(count+j)=file_wav(j);
                files_ref(count+j)=file_ref(j);
            end
            count=count+j;
        end   
    else
        cd ..;
        directory=pwd();
        folder=list_folder;
        i=i-1;
        register(i)=register(i)-1;
        enter=register(i);
    end
end

database=2;
fs=48000;
w_shift=10;
%}

window_time=32; % frame duration in ms
window_samples=(window_time/1000)*fs; % number of samples on each frame 
w_shift_samples=(w_shift/1000)*fs;    % number of samples on each shift

                %% Pitch estimation of each file
                
% Obtaining audio signals
if database==1
    location='.\pda_ue\';
else
    location='.\ptdb_tub\';
end

%i=1;
for i=1:length(files_wav)
    [audio,fs]=audioread([location,files_wav(i).name]);
    
    % Audio should be expanded twice the shift movement (at the 
    % beginning and end of the file) to be fully analyzed
    expanded=zeros(length(audio)+2*w_shift_samples,1);
    expanded(1+w_shift_samples:end-w_shift_samples,1)=audio;
    audio=expanded;
    
    t=0:1/fs:(length(audio)-1)/fs; % timing vector
    fileID=fopen([location,files_ref(i).name]);
    audio_ref=fscanf(fileID,'%f')>1;
        
    % Pitch estimation of each frame with 4 different algorithms
    n_frames=floor((length(audio)-window_samples)/w_shift_samples)+1;
    
        % Fix variable size to avoid problems
        pitch_autocorr=zeros(n_frames,1);
        pitch_autocorr_error=zeros(n_frames,1);
        pitch_AMDF=zeros(n_frames,1);
        pitch_cepstrum=zeros(n_frames,1);
        
    for j=1:n_frames
        if j~=n_frames
            % All frames except the last one
            frame=audio(1+(j-1)*w_shift_samples:window_samples+(j-1)*w_shift_samples,1);
        else
            % final frame
            frame=audio(1+(j-1)*w_shift_samples:end,1);
        end
        
        rx_w=xcorr(frame);
        if mean(abs(rx_w))>0.015 % If the frame is voiced
            
        %%%% Autocorrelation algorithm
            pitch_autocorr(j,1)=autocorr_algorithm(frame,fs);
        
        %%%% Autocorrelation error algorithm
            pitch_autocorr_error(j,1)=autocorr_error_algorithm(frame,fs);
            
        %%%% AMDF algorithm
            pitch_AMDF(j,1)=amdf_algorithm(frame,fs);
                    
        %%%% Cepstrum algorithm
            pitch_cepstrum(j,1)=cepstrum_algorithm(frame,fs);
        
        else % If the frame is unvoiced
            pitch_autocorr(j,1)=0;
            pitch_autocorr_error(j,1)=0;
            pitch_AMDF(j,1)=0;
            pitch_cepstrum(j,1)=0;
        end
    end

    % Graphical display of pitch behavior in the audio before filrering
    %{
    figure(1)
    subplot(2,1,1)
    plot(t,audio)
    xlabel('time(s)'); ylabel('audio(nT)')
    title('Audio signal in time domain')
    grid on
    
    subplot(2,1,2)
    plot(pitch_autocorr,'b')
    hold on
    plot(pitch_autocorr_error,'r')
    hold on
    plot(pitch_AMDF,'k')
    hold on
    plot(pitch_cepstrum,'g')
    legend('Autocorrelation','Autocorrelation error','AMDF','Cepstrum')
    title('Pitch evolution in the audio')
    ylabel('Pitch frequency(Hz)')
    xlabel('Frame Index')
    %}
    
    
                %% Filtering non-logical pitch values

    % Human voice range:
    % Male: 85 to 180 Hz
    % Female: 165 to 255 Hz
    
    max_range=350;
    
    % Eliminate peaks that are higher than max_range and 
    % substitute them by the mean of the remaining values
    aux1=pitch_autocorr(find(pitch_autocorr~=0));
    aux2=aux1(find(aux1<max_range));
    k=find(pitch_autocorr>max_range);
    pitch_autocorr(k)=mean(aux2);
    
    aux1=pitch_autocorr_error(find(pitch_autocorr_error~=0));
    aux2=aux1(find(aux1<max_range));
    k=find(pitch_autocorr_error>max_range);
    pitch_autocorr_error(k)=mean(aux2);

    aux1=pitch_AMDF(find(pitch_AMDF~=0));
    aux2=aux1(find(aux1<max_range));
    k=find(pitch_AMDF>max_range);
    pitch_AMDF(k)=mean(aux2);

    aux1=pitch_cepstrum(find(pitch_cepstrum~=0));
    aux2=aux1(find(aux1<max_range));
    k=find(pitch_cepstrum>max_range);
    pitch_cepstrum(k)=mean(aux2);
                    
    % Smooth results using a median filter
    pitch_autocorr=medfilt1(pitch_autocorr);
    pitch_autocorr_error=medfilt1(pitch_autocorr_error);
    pitch_AMDF=medfilt1(pitch_AMDF);
    pitch_cepstrum=medfilt1(pitch_cepstrum);
    
    % Graphical display of pitch behavior in the audio after filrering
    %{
    figure(2)
    subplot(2,1,1)
    plot(t,audio)
    xlabel('time(s)'); ylabel('audio(nT)')
    title('Audio signal in time domain')
    grid on
    
    subplot(2,1,2)
    plot(pitch_autocorr,'b')
    hold on
    plot(pitch_autocorr_error,'r')
    hold on
    plot(pitch_AMDF,'k')
    hold on
    plot(pitch_cepstrum,'g')
    legend('Autocorrelation','Autocorrelation error','AMDF','Cepstrum')
    title('Pitch evolution in the audio after filtering')
    ylabel('Pitch frequency(Hz)')
    xlabel('Frame Index')
    %}
 
                          %% Saving .f0 files
%                         
    audio_name=strsplit(files_wav(i).name,'.');
    fileID = fopen(strcat(location,audio_name{1},'.f0'),'w');
    fprintf(fileID, '%g\n', pitch_AMDF);
    fclose(fileID);
%}
                          
end
                