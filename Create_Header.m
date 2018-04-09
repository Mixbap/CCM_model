function [ Header_TB ] = Create_Header( Header_length )

Header_TB = randi([0 1], 1, Header_length);

Header_TB(Header_length + 1: 128) = zeros();


end

