clc
clear
%%
%some constants
bit_length = 7;
A=4;
num_of_WFs = 1500;
len_of_WF = 1000;

%generate 500 waveform as colums each row consist of 100 bit 
waveforms = randi([0 1], num_of_WFs,len_of_WF);
%repeat every bit with it's length
waveforms_after_rep = repelem(waveforms,1,bit_length);

%%
Ensemble = waveforms_after_rep;
n = 1;
Ensemble_len = 0;
switch n
    case 1
        %the line code ( Unipolar Signaling)
        Ensemble = Ensemble * A;
        Ensemble_len = len_of_WF * bit_length;
    case 2       
        %the line code ( Polar Non Return to Zero Signaling)
        Ensemble = ((Ensemble * 2)-1)*A;
        Ensemble_len = len_of_WF * bit_length;
    case 3
        %we need 3 matrices
        %the main waveforms_after_rep EX:[111  1  111, 0 0 0  0  000 , 111  1  111]
        
        %ones mask                       [000 0.5 111, 0 0 0  0  000 , 000 0.5 111]
        %subtract the one mask 
        %zero mask                       [000  0  000,-1-1-1 -.5 000 , 000  0  000]
        %add the zero mask
        %result                          [111 0.5 000,-1-1-1 -.5 000 , 111 0.5 000]
        Ensemble_len = len_of_WF * bit_length;
        one_mask = repmat([0 0 0 0.5 1 1 1],[num_of_WFs len_of_WF]) .* Ensemble;
        zero_mask = repmat([-1 -1 -1 -0.5 0 0 0],[num_of_WFs len_of_WF]) .* (Ensemble == 0);
        Ensemble = Ensemble - one_mask + zero_mask;
        Ensemble = Ensemble * 4;
        
end

%%

for i = 1: num_of_WFs
    delay_duration = randi([0 bit_length-1]); % Generate a random size between 1 and bit_length
    switch n
        case 1
            delay_value = randi([0 1])*A; % Generate a random value for the delay
        case 2
            delay_value = randi([-1 1])*A;
        case 3
            delay_value = randi([0 1])*A;
    end
            delay_row = ones(1,delay_duration)*delay_value;
    %shift every WF with its delay
    Ensemble(i,:) =[delay_row Ensemble(i,1:end-delay_duration)];
    
end
%%
%mean
%calculate the statistical mean
mean_stat = sum(Ensemble,1)/num_of_WFs;
%prove that the statistical mean is constant with the time
mean_stat_mean = sum(mean_stat)/Ensemble_len;
V_stat_mean = var(mean_stat);

%calculate the time mean
realization = Ensemble(1,:);
mean_time = sum(realization,2)/Ensemble_len;
%% ploting

plot(mean_stat)
title("statistical mean")
xlabel("Time")
ylabel("mean")
axis([7 7000 -2 2])
%% autocorrelation
maximum_tu = 511; %the maximum tu
 
%% stat autocorrelation
R_tu_stat =   zeros(1,maximum_tu);
start = 10;
for tu = 0:maximum_tu
   R_tu_stat(tu + 1)= sum((Ensemble(:,start) .* Ensemble(:,tu + start)),1)/num_of_WFs;
end
R_tu_stat = [flip(R_tu_stat(2:end)) R_tu_stat];


%% time autocorrelation 

R_tu_time = zeros(1,maximum_tu);
realization = Ensemble(1,:);

for tu = 0:maximum_tu
    %shift the ensumble with tu
    realization_shifted_by_tu = circshift(realization,tu,2);
    %and multiplay with the original one
    x = realization .* realization_shifted_by_tu;
    
    R_tu_time(tu+1) = sum(x)/Ensemble_len;
end
R_tu_time = [flip(R_tu_time(2:end)) R_tu_time];


%% ploting
X = R_tu_time;
Fs = 100;         % Sampling frequency
T = 1/Fs;           % Sampling period
t = -maximum_tu*T:T:maximum_tu*T;     % Time vector
L = length(t);      % Signal length

plot(t,X)
title("Time Autocorrelation")
%title("Statistical Autocorrelation")
xlabel("Time difference (tu)")
ylabel("Ru(tu)")
%axis([-0.15 0.15 -1 20])
%% Ergodic section

plot(t,R_tu_stat)
hold
plot(t,R_tu_time)
legend("statistical auto correlation","Time auto correlation")
title("statistical & Time Autocorrelation")
xlabel("Time difference (tu)")
ylabel("Ru(tu)")

%% PSD
n = 2^nextpow2(L);
Y = fft(X,n);
Y = fftshift(Y);
f = Fs*(-n/2:n/2-1)/n;
P = abs(Y/n).^2;

plot(f,P) 
title("PSD")
xlabel("f (Hz)")
ylabel("|P(f)|^2")
