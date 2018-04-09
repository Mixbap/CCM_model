function [Intial_Vector] = Initialization_Initial_Vector( Header_length, Nonce )

%----Create Flag--------------------------------------
Flag_Initial_Vector(1:8) = 0;

%----Creare TBlen------------------------------------
TBlen_bin = dec2bin(Header_length, 20); %переход к двоичному числу

for i = 1:20
    TBlen(i) = str2num(TBlen_bin(i)); %получение массива TBlen
end 


Intial_Vector = [Flag_Initial_Vector Nonce TBlen];


end

