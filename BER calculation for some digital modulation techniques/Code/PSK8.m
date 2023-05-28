function [BER] = PSK8(bit_stream,stream_length,Eb)

Es = Eb*3;
M = 8;
TX_bits = {'000','100','101','111','110','010','011','001'};
TX_Sym = [1 2 3 4 5 6 7 8];
Dict = containers.Map(TX_bits,TX_Sym);

Symbols_TX = zeros(1,stream_length/3);
for i = 1:3:stream_length
%     First_bit = string(bit_stream(i));
%     Second_bit = string(bit_stream(i+1));
%     Third_bit = string(bit_stream(i+2));
%     symbol = strcat(First_bit,Second_bit,Third_bit);
    
    symbol = char([bit_stream(i)+48,bit_stream(i+1)+48,bit_stream(i+2)+48]);
    Symbols_TX((i+2)/3) = Dict(symbol);
end

%mapper 8PSK
Mapped = sqrt(Es).*cos((2*pi/M).*(Symbols_TX-1)) - 1j*sqrt(Es).*sin((2*pi/M).*(Symbols_TX-1));

%channel
noise = sqrt(1/2)*(randn([1,stream_length/3]) + 1j*randn([1,stream_length/3]));
Mapped_with_noise = Mapped + noise;
%demapper 8PSK
% X dim ~ 2 X Stream of symbols
x_1 = real(Mapped_with_noise);
x_2 = imag(Mapped_with_noise);
X = [x_1;x_2];

% S dim ~ 2 X #of symbols
enumerate_sym = 1:8;
S = [sqrt(Es).*cos((2*pi/M).*(enumerate_sym-1));...
    -sqrt(Es).*sin((2*pi/M).*(enumerate_sym-1))];

% (X^T * S) dim ~ Stream of symbols X #of symbols
% select the largest value in #of symbols for every symbol
% all symbols have the same energy
Estimation_matrix = X'*S-Es/2;
[demapped_value ,demapped_symols] = max(Estimation_matrix,[],2);
% convert symbol to bits
A = [0 0 0; 1 0 0 ; 1 0 1 ; 1 1 1 ; 1 1 0 ; 0 1 0 ; 0 1 1 ; 0 0 1];
demapped_bits = zeros(1,stream_length);
for i = 1:3:stream_length
    demapped_bits(i) = A(demapped_symols((i+2)/3),1);
    demapped_bits(i + 1) = A(demapped_symols((i+2)/3),2);
    demapped_bits(i + 2) = A(demapped_symols((i+2)/3),3);
end

BER = sum(demapped_bits ~= bit_stream)/stream_length;
