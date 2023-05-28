function [BER] = QAM16(bit_stream,stream_length,Eb)

% Eb = ((9E+E)*2)*4/2 = 2.5*E

E = 0.4*Eb;
TX_bits = {'0010','0110','1110','1010',...
    '0011','0111','1111','1011',...
    '0001','0101','1101','1001',...
    '0000','0100','1100','1000',...
    };
%the first two bits => first index
%the second two bits => second index
TX_Sym = {[1 4], [2 4], [3 4], [4 4],...
    [1 3], [2 3], [3 3], [4 3],...
    [1 2], [2 2], [3 2], [4 2],...
    [1 1], [2 1], [3 1], [4 1],...
    };
Dict = containers.Map(TX_bits,TX_Sym);

Symbols_TX = zeros(2,stream_length/4);
for i = 1:4:stream_length
%     First_bit = string(bit_stream(i));
%     Second_bit = string(bit_stream(i+1));
%     Third_bit = string(bit_stream(i+2));
%     forth_bit = string(bit_stream(i+3));
    symbol = char([bit_stream(i)+48,bit_stream(i+1)+48,bit_stream(i+2)+48,bit_stream(i+3)+48]);
    Symbols_TX(:,(i+3)/4) = Dict(symbol);
end

%mapper 8PSK
a = [-3 -1 1 3];
b = [-3 -1 1 3];
Mapped = sqrt(E)*a(Symbols_TX(1,:)) + 1j*sqrt(E)*b(Symbols_TX(2,:));

%channel
noise = sqrt(1/2)*(randn([1,stream_length/4]) + 1j*randn([1,stream_length/4]));
Mapped_with_noise = Mapped + noise;

%demapper 8PSK
% X dim ~ 2 X Stream of symbols
x_1 = real(Mapped_with_noise);
x_2 = imag(Mapped_with_noise);
X = [x_1;x_2];

% S dim ~ 2 X #of symbols
S = zeros(2,16);
for i = 1:4:16
    S(:,i:i+3) = [sqrt(E)*a(1:4);...
        sqrt(E)*b([(i+3)/4 (i+3)/4 (i+3)/4 (i+3)/4])];
end
E_k = S(1,:).^2 + S(2,:).^2;

% (X^T * S) dim ~ Stream of symbols X #of symbols
% select the largest value in #of symbols for every symbol
% all symbols have the same energy
Estimation_matrix = X'*S-E_k/2;
[demapped_value ,demapped_symols] = max(Estimation_matrix,[],2);
% convert symbol to bits
A = [0 0 0 0; 0 1 0 0 ; 1 1 0 0 ; 1 0 0 0 ;...
    0 0 0 1; 0 1 0 1 ; 1 1 0 1 ; 1 0 0 1 ;...
    0 0 1 1; 0 1 1 1 ; 1 1 1 1 ; 1 0 1 1 ;...
    0 0 1 0; 0 1 1 0 ; 1 1 1 0 ; 1 0 1 0];
demapped_bits = zeros(1,stream_length);
for i = 1:4:stream_length
    demapped_bits(i) = A(demapped_symols((i+3)/4),1);
    demapped_bits(i + 1) = A(demapped_symols((i+3)/4),2);
    demapped_bits(i + 2) = A(demapped_symols((i+3)/4),3);
    demapped_bits(i + 3) = A(demapped_symols((i+3)/4),4);
end

BER = sum(demapped_bits ~= bit_stream)/stream_length;

