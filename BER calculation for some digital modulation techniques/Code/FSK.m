clc
clear
%%
SNR = -2:0.5:10;
Eb = 10.^(SNR/10);
num_of_iterations = size(Eb,2);
%%
BFSK_BER   = zeros(1,num_of_iterations);

for  i = 1:num_of_iterations

  
    stream_length = 300000;
    bit_stream = randi([0 1],1,stream_length);
    
    Symbols_TX = [bit_stream == 0 ; bit_stream];
    
    Mapped = sqrt(Eb(i))*Symbols_TX;
    
    %channel
    noise = sqrt(1/2)*randn([2,stream_length]);
    Mapped_with_noise = Mapped + noise;
    
    %demapper
    phi_1 = Mapped_with_noise(1,:);
    phi_2 = Mapped_with_noise(2,:);
    
    demapped = (phi_1 - phi_2) < 0;
    
    BFSK_BER(i) = sum(demapped ~= bit_stream)/stream_length;
    fprintf(' %d Finished \n',i);
end

BFSK_T=0.5*erfc(sqrt(Eb/2));

semilogy(SNR,BFSK_BER,'k-')
hold on
semilogy(SNR,BFSK_T,'k--')
hold on


title('BER vs SNR');
xlabel('SNR(dB)');
ylabel('BER');
legend('BFSK','BFSK T');


%%
clc
clear
%% PSD
f_delta = 10;
Tb = 1/f_delta;

Ts = Tb/100;           % Sampling period
Fs = 1/Ts;         % Sampling frequency

t = 0:Ts:(Tb-Ts);

bit_length = Fs/f_delta;
num_of_WFs = 10000;
len_of_WF = 100;

Eb = 1;
S_1BB = sqrt(2*Eb/Tb).*ones([1 bit_length]);
S_2BB = sqrt(2*Eb/Tb).*(cos(2*pi*f_delta*t)+1j*sin(2*pi*f_delta*t));

%generate num_of_WFs waveform as colums each row consist of len_of_WF bit
waveforms = randi([0 1], num_of_WFs,len_of_WF);
%repeat every bit with it's length
waveforms_after_rep = repelem(waveforms,1,bit_length);
Ensemble = waveforms_after_rep;
Ensemble_len = len_of_WF * bit_length;


%%
%we need 3 matrices
%the main waveforms_after_rep EX:[111  1  111, 0 0 0  0  000 , 111  1  111]

%ones mask                       [000 0.5 111, 0 0 0  0  000 , 000 0.5 111]
%subtract the one mask
%zero mask                       [000  0  000,-1-1-1 -.5 000 , 000  0  000]
%add the zero mask
%result                          [111 0.5 000,-1-1-1 -.5 000 , 111 0.5 000]
zero_mask = repmat(S_1BB,[num_of_WFs len_of_WF]) .* (Ensemble == 0);
one_mask = repmat(S_2BB,[num_of_WFs len_of_WF]) .* Ensemble;
Ensemble = one_mask + zero_mask;
%%
for i = 1: num_of_WFs
    delay_duration = randi([0 bit_length-1]); % Generate a random size between 1 and bit_length
    delay_value = randi([0 1]);
    delay_row = (delay_value == 1)*S_2BB + (delay_value == 0)*S_1BB;
    delay_row = delay_row(end-delay_duration + 1:end);

    %shift every WF with its delay
    Ensemble(i,:) =[delay_row Ensemble(i,1:end-delay_duration)];
    
end
%% stat autocorrelation
maximum_tu = 2047; %the maximum tu

R_tu_stat_p =   zeros(1,maximum_tu);
R_tu_stat_n =   zeros(1,maximum_tu);
start = 4000;
for tu = 0:maximum_tu
   col = conj(Ensemble(:,start));
   R_tu_stat_p(tu + 1)= sum((col .* Ensemble(:,tu + start)),1)/num_of_WFs;
   R_tu_stat_n(tu + 1)= sum((col .* Ensemble(:,-tu + start)),1)/num_of_WFs;
end
R_tu_stat = [flip(R_tu_stat_n(2:end)) R_tu_stat_p];
R_tu = abs(R_tu_stat);

%% ploting PSD
X = R_tu_stat;

t = -maximum_tu*Ts:Ts:maximum_tu*Ts;     % Time vector
L = length(t);      % Signal length

n = 2^nextpow2(L);
Y = fft(X,n);
Y = fftshift(Y);
f = Fs*(-n/2:n/2-1)/n;
P = (abs(Y/n).^2);

%axis([-100 100 -1 100])
plot(f,P) 
xlim([-30 30])
title("PSD")
xlabel("f (Hz)")
ylabel("|P(f)|^2")



