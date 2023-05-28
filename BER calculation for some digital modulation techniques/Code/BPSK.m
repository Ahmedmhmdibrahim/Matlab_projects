function [BER] = BPSK(bit_stream,stream_length,Eb)

Symbols_TX = bit_stream*2-1;
Mapped = sqrt(Eb)*Symbols_TX;

%channel
noise = sqrt(1/2)*randn([1,stream_length]);
Mapped_with_noise = Mapped + noise;

%demapper
demapped = Mapped_with_noise > 0;

BER = sum(demapped ~= bit_stream)/stream_length;

end
