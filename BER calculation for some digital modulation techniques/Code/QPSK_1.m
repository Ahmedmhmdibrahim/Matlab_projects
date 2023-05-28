function [BER] = QPSK_1(bit_stream,stream_length,Eb)
%QPSK
E_s = Eb*2;
M = 4;
QPSK_TX_bits = {'10','00','01','11'};
QPSK_TX_Sym = [1 2 3 4];
Dict = containers.Map(QPSK_TX_bits,QPSK_TX_Sym);


Symbols_TX = zeros(1,stream_length/2);
for i = 1:2:stream_length
    %First_bit = string(bit_stream(i));
    %Second_bit = string(bit_stream(i+1));
    %symbol = First_bit + Second_bit;
    
    symbol = char([bit_stream(i)+48,bit_stream(i+1)+48]);
    Symbols_TX((i+1)/2) = Dict(symbol);
end

%mapper QPSK
Mapped = sqrt(E_s)*cos((pi/M)*(2*Symbols_TX-1))-1j*sqrt(E_s)*sin((pi/M)*(2*Symbols_TX-1));

%channel
    noise = sqrt(1/2)*(randn([1,stream_length/2]) + 1j*randn([1,stream_length/2]));
    Mapped_with_noise = Mapped + noise;
    
%demapper QPSK 
demapped = zeros(1,stream_length);
for i = 1:stream_length/2
    demapped(i*2 - 1)     = real(Mapped_with_noise(i)) > 0; % the real value controls the first  bit
    demapped(i*2)         = imag(Mapped_with_noise(i)) > 0; % the imag value controls the second bit
end

BER = sum(demapped ~= bit_stream)/stream_length;

end
