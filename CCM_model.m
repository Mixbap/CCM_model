script
clear

%---Input Parameters-----------------------------------
ERROR_bit = 0; %���������� ��������� ���
ERROR = 0; %���������� ��������� �������
Test_value = 1000; %���������� �������� ������
Data_length = 400; %������ ������
Header_length = 16; %������ ��������� (<128)


for N = 1:Test_value

%---Create Nonce-----------------------------------------
Nonce = Create_Nonce();

%---Create Initial Vector----------------------------------
Intional_Vector = Initialization_Initial_Vector(Header_length, Nonce);

%---Input Data---------------------------------------------
Data_Payload = Input_Data(Data_length);

%---Create Key vector--------------------------------------
Key_Vector = AES_key();

%---Create Header------------------------------------------
Header_TB = Create_Header(Header_length);

%---Create Counter-----------------------------------------
Counter = Create_Counter(N, Nonce);


%----Encryption header-----------------------------------
for i = 1:128
    AES_Initional_Vector(i) = xor(Intional_Vector(i), Key_Vector(i)); %AES ��� Initial Vector
end

Header_TB_128(length(Header_TB):128) = 0;%���������� ��������� ������

for i = 1:128
    AES_Header(i) = xor(AES_Initional_Vector(i), Header_TB_128(i)); %XOR � ����������
end
%-----------------------------------------------------------

Frame_value = ceil(length(Data_Payload)/128);%����������� ���������� �������

Data_Payload_128(1:length(Data_Payload)) = Data_Payload;
Data_Payload_128((length(Data_Payload) + 1):(128*Frame_value)) = 0; %���������� ���������� ������ ������ 

%--------Create MIC------------------------------------------------------
AES_encrypt(i) = xor(AES_Header(i), Key_Vector(i)); %AES ��������� � AES Initional Vector

for k = 0:Frame_value - 1
for i = 1:128
    AES_Data_Payload(i) = xor(AES_encrypt(i), Data_Payload_128((128*k) + i));%xor � �������
    AES_Data_Payload_encrypt(i) = xor(AES_Data_Payload(i), Key_Vector(i));%AES
end
end

MIC = AES_Data_Payload_encrypt(1:64); %������ ������� 64 ��� MIC 


%------Create Encryption Data------------------------------------------------------------------------
for k = 0:Frame_value - 1
    N_inc_bin = dec2bin(k + 1, 20); %������� � ��������� ����� ��� ��������
    
    for i = 1:20
        N_inc(i) = str2num(N_inc_bin(i)); %��������� ������� N_inc
    end 
    
    %������������ Counter
    Counter(1:8) = Flag_Counter;
    Counter(9:108) = Nonce;
    Counter(109:128) = N_inc;
    
    for n = 1:128
        AES_Counter(n) = xor(Counter(n), Key_Vector(n)); %AES Counter
        Encrypted_Data((128*k) + n) = xor(AES_Counter(n), Data_Payload_128((128*k) + n)); %xor ������ � AES Counter
    end
end
%-------Create Encryption MIC-------------------------------------
%������������ Counter ��� MIC
Counter(1:8) = Flag_Counter;
Counter(9:108) = Nonce;
Counter(109:128) = 0;

MIC(65:128) = 0; %���������� MIC ������

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
    N_inc_bin = dec2bin(k + 1, 20); %������� � ��������� ����� ��� ��������
    
    for i = 1:20
        N_inc(i) = str2num(N_inc_bin(i)); %��������� ������� N_inc
    end 
    
    %������������ Counter
    Counter(1:8) = Flag_Counter;
    Counter(9:108) = Nonce;
    Counter(109:128) = N_inc;
    
    for n = 1:128
        AES_Counter(n) = xor(Counter(n), Key_Vector(n)); %AES Counter
        Decrypted_Data_Payload((128*k) + n) = xor(AES_Counter(n), Encrypted_Data((128*k) + n)); %xor ������ � AES Counter
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