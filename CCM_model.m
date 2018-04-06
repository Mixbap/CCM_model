script
clear

ERROR_bit = 0; %количество ошибочных бит
ERROR = 0; %количество ошибочных передач
Test_value = 1000; %количество тестовых пусков
Data_length = 400; %размер данных
Header_length = 60; %размер заголовка (<128)

for N = 1:Test_value

%---Input Parametrs----------------------------------
%Nonce(1:100) = 0;
%Nonce = [1 1 1 1  0 0 0 0  1 1 1 1  0 0 0 0  1 1 1 1  1 1 1 1  1 1 1 1  1 1 1 1  0 0 0 0  0 0 0 0  0 0 0 0  0 0 0 0 1 1 1 1  0 0 0 0  1 1 1 1  0 0 0 0  1 1 1 1  1 1 1 1  1 1 1 1  1 1 1 1  0 0 0 0  0 0 0 0  0 0 0 0  0 0 0 0  1 1 1 1];
for i = 1:100
if rand(1)>0.5
    Nonce(i) = 1;
else
    Nonce(i) = 0;
end
end

Flag_Initial_Vector(1:8) = 0;
Flag_Counter(1:8) = 0;

%----Create header-------------------------------------
%Header_TB(1:100) = 0;
%Header_TB(101:105) = 1;
for i = 1:Header_length
if rand(1)>0.5
    Header_TB(i) = 1;
else
    Header_TB(i) = 0;
end
end

%-----Create Data Payload----------------------
%Data_Payload(1:300) = 0;
%Data_Payload(1:40) = 0;
%Data_Payload(41:96) = 1;
%Data_Payload(97:300) = 0;
%Data_Payload(100) = 1;
for i = 1:Data_length
if rand(1)>0.5
    Data_Payload(i) = 1;
else
    Data_Payload(i) = 0;
end
end

%-----Create Key AES---------------------------
%Key_Vector(1:128) = 1;
%Key_Vector(1:30) = 0;
%Key_Vector(31:50) = 1;
%Key_Vector(51:128) = 0;
for i = 1:128
if rand(1)>0.5
    Key_Vector(i) = 1;
else
    Key_Vector(i) = 0;
end
end
    

%----Creare TBlen------------------------------------
TBlen_dec = length(Header_TB); %определение размера заголовка
TBlen_bin = dec2bin(TBlen_dec, 20); %переход к двоичному числу

for i = 1:20
    TBlen(i) = str2num(TBlen_bin(i)); %получение массива TBlen
end 

%----Creare Initional Vector--------------------------
Intional_Vector(1:8) = Flag_Initial_Vector;
Intional_Vector(9:108) = Nonce;
Intional_Vector(109:128) = TBlen;

%----Encryption header-----------------------------------
for i = 1:128
    AES_Initional_Vector(i) = xor(Intional_Vector(i), Key_Vector(i)); %AES для Initial Vector
end

Header_TB_128(length(Header_TB):128) = 0;%дополнение заголовка нулями

for i = 1:128
    AES_Header(i) = xor(AES_Initional_Vector(i), Header_TB_128(i)); %XOR с заголовком
end
%-----------------------------------------------------------

Frame_value = ceil(length(Data_Payload)/128);%определение количества фреймов

Data_Payload_128(1:length(Data_Payload)) = Data_Payload;
Data_Payload_128((length(Data_Payload) + 1):(128*Frame_value)) = 0; %дополнение последнего фрейма нулями 

%--------Create MIC------------------------------------------------------
AES_encrypt(i) = xor(AES_Header(i), Key_Vector(i)); %AES заголовка и AES Initional Vector

for k = 0:Frame_value - 1
for i = 1:128
    AES_Data_Payload(i) = xor(AES_encrypt(i), Data_Payload_128((128*k) + i));%xor с данными
    AES_Data_Payload_encrypt(i) = xor(AES_Data_Payload(i), Key_Vector(i));%AES
end
end

MIC = AES_Data_Payload_encrypt(1:64); %взятие старших 64 бит MIC 


%------Create Encryption Data------------------------------------------------------------------------
for k = 0:Frame_value - 1
    N_inc_bin = dec2bin(k + 1, 20); %переход к двоичному числу для счетчика
    
    for i = 1:20
        N_inc(i) = str2num(N_inc_bin(i)); %получение массива N_inc
    end 
    
    %формирование Counter
    Counter(1:8) = Flag_Counter;
    Counter(9:108) = Nonce;
    Counter(109:128) = N_inc;
    
    for n = 1:128
        AES_Counter(n) = xor(Counter(n), Key_Vector(n)); %AES Counter
        Encrypted_Data((128*k) + n) = xor(AES_Counter(n), Data_Payload_128((128*k) + n)); %xor данных с AES Counter
    end
end
%-------Create Encryption MIC-------------------------------------
%формирование Counter для MIC
Counter(1:8) = Flag_Counter;
Counter(9:108) = Nonce;
Counter(109:128) = 0;

MIC(65:128) = 0; %заполнение MIC нулями

for n = 1:128
    AES_Counter(n) = xor(Counter(n), Key_Vector(n)); %AES Counter MIC
    Encrypted_MIC(n) = xor(MIC(n), AES_Counter(n)); 
end

%-------Create Encrypted TB Data----------------------------------------------------------
Encrypted_TB_Data(1 : TBlen_dec) = Header_TB;

Encrypted_TB_Data((TBlen_dec + 1) : (TBlen_dec + (128 * Frame_value))) = Encrypted_Data;
len = TBlen_dec + (128 * Frame_value);

Encrypted_TB_Data((len + 1) : (len + 128)) = Encrypted_MIC;

%--------Decryption Data---------------------------------------------------
for k = 0:Frame_value - 1
    N_inc_bin = dec2bin(k + 1, 20); %переход к двоичному числу для счетчика
    
    for i = 1:20
        N_inc(i) = str2num(N_inc_bin(i)); %получение массива N_inc
    end 
    
    %формирование Counter
    Counter(1:8) = Flag_Counter;
    Counter(9:108) = Nonce;
    Counter(109:128) = N_inc;
    
    for n = 1:128
        AES_Counter(n) = xor(Counter(n), Key_Vector(n)); %AES Counter
        Decrypted_Data_Payload((128*k) + n) = xor(AES_Counter(n), Encrypted_Data((128*k) + n)); %xor данных с AES Counter
    end
end

%---Search error------------------------------------------------------
Result = xor(Decrypted_Data_Payload, Data_Payload_128);

for i = 1:length(Result)
if Result(i)
    ERROR_bit = ERROR_bit + 1;
end
end

ERROR_bit_test = ERROR_bit;

if ERROR_bit_test
    ERROR = ERROR + 1;
    ERROR_bit_test = 0;
end

end


%----Clear workspace---------------------------------------------------
clear n
clear i
clear k
clear N
clear N_inc_bin
clear AES_Counter
clear AES_Data_Payload
clear AES_Data_Payload_encrypt
clear AES_encrypt
clear AES_Header
clear AES_Initional_Vector
clear Counter
clear Encrypted_MIC
clear Flag_Counter
clear Flag_Initial_Vector
clear Frame_value
clear Header_TB
clear Header_TB_128
clear Intional_Vector
clear Key_Vector
clear len
clear MIC
clear N_inc
clear Nonce
clear Result
clear TBlen
clear TBlen_dec
clear TBlen_bin
clear Data_length
clear Header_length
clear ERROR_bit_test