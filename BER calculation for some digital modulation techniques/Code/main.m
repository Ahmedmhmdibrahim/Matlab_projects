%%
clc
clear
%% BIT generation
stream_length = 300000;
bit_stream = randi([0 1],1,stream_length);

SNR = -2:0.5:10;
Eb = 10.^(SNR/10);
num_of_iterations = size(Eb,2);
%%
BPSK_BER   = zeros(1,num_of_iterations);
QPSK_1_BER = zeros(1,num_of_iterations);
QPSK_2_BER = zeros(1,num_of_iterations);
PSK8_BER = zeros(1,num_of_iterations);
QAM16_BER = zeros(1,num_of_iterations);

for  i = 1:num_of_iterations

    BPSK_BER(i)   = BPSK(bit_stream,stream_length,Eb(i));    
    QPSK_1_BER(i) = QPSK_1(bit_stream,stream_length,Eb(i));
    QPSK_2_BER(i) = QPSK_2(bit_stream,stream_length,Eb(i));
    PSK8_BER(i)   = PSK8(bit_stream,stream_length,Eb(i));
    QAM16_BER(i)  = QAM16(bit_stream,stream_length,Eb(i));
    fprintf(' %d Finished \n',i);
    
end
    QPSK_T=0.5*erfc(sqrt(Eb));
    PSK8_T=erfc(sqrt(3*Eb)*sin(pi/8))/3;
    PSK8_T_upper_limit=3.5*erfc(sqrt(3*Eb)*sin(pi/8))/3;
    QAM_T =1.5*erfc(sqrt(Eb/2.5))/4;
%%

semilogy(SNR,BPSK_BER,'b-')
hold on
semilogy(SNR,QPSK_1_BER,'m-')
hold on
semilogy(SNR,QPSK_T,'r--')
hold on

semilogy(SNR,PSK8_BER,'c-')
hold on
semilogy(SNR,PSK8_T,'c--')
hold on
semilogy(SNR,PSK8_T_upper_limit,'c--')
hold on

semilogy(SNR,QAM16_BER,'k-')
hold on
semilogy(SNR,QAM_T,'k--')
hold on


title('BER vs SNR');
xlabel('SNR(dB)');
ylabel('BER');
legend('BPSK','QPSK 1','T BPSK QPSK','8PSK','T 8PSK','8PSK T upper limit','16 QAM','T 16 QAM','Location','southwest');
%%
figure;
semilogy(SNR,QPSK_1_BER,'m-')
hold on
semilogy(SNR,QPSK_2_BER,'g-')
hold on
semilogy(SNR,QPSK_T,'r--')
hold on

title('BER vs SNR');
xlabel('SNR(dB)');
ylabel('BER');
legend('QPSK Gray','QPSK','T QPSK','Location','southwest');
