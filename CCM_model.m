script
clear

%---Input Parameters-------------------------------------------------------
ERROR = 0; %���������� ��������� �������
Test_value = 1000; %���������� �������� ������
Data_length = 400; %������ ������
Header_length = 16; %������ ��������� (<128)


for N = 1:Test_value

%---Create Nonce-----------------------------------------
Nonce = Create_Nonce();

%---Create Initial Vector----------------------------------
Intial_Vector = Initialization_Initial_Vector(Header_length, Nonce);

%---Input Data---------------------------------------------
[Data_Payload, Section_value] = Input_Data(Data_length);

%---Create Key vector--------------------------------------
Key_Vector = AES_key();

%---Create Header------------------------------------------
Header_TB = Create_Header(Header_length);


%--------Create MIC------------------------------------------------------
MIC = Create_MIC(Header_TB, Intial_Vector, Section_value, Data_Payload, Key_Vector);

%------Create Encryption Data------------------------------------------------------------------------
for k = 0:(Section_value - 1)
    
    Counter = Create_Counter(k+1, Nonce);
    
    Encrypted_Counter = Encrypted_AES(Counter, Key_Vector); %����������� Counter
    Encrypted_Data(128*k + 1 : 128*k + 128) = xor(Encrypted_Counter, Data_Payload(128*k + 1 : 128*k + 128)); %xor ������ � AES Counter
    
end


%-------Create Encryption MIC-------------------------------------
MIC(65:128) = 0; %���������� MIC ������
Counter = Create_Counter(0, Nonce);

Encrypted_Counter_MIC = Encrypted_AES(Counter, Key_Vector); %AES Counter MIC
Encrypted_MIC = xor(MIC, Encrypted_Counter_MIC); %����������� MIC


%---Create full data section-----------------------------------------------
Full_Data_section = [Header_TB Encrypted_Data Encrypted_MIC];

%--------------------------------------------------------------------------
%------------------------Decrypted-----------------------------------------
%--------------------------Data--------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------


%---Decrypted Data---------------------------------------------------------
for k = 0:(Section_value - 1)
    
    Counter = Create_Counter(k+1, Nonce);
    
    Encrypted_Counter = Encrypted_AES(Counter, Key_Vector); %����������� Counter
    Decrypted_Data(128*k + 1 : 128*k + 128) = xor(Encrypted_Counter, Encrypted_Data(128*k + 1 : 128*k + 128)); %xor ������ � AES Counter
    
end

%---Decrypted MIC-------------------------------------------------------
Decrypted_MIC = Create_MIC(Header_TB, Intial_Vector, Section_value, Decrypted_Data, Key_Vector);
 
% % ---Add random error bit MIC-----------------------------------------------
% ERROR_bit = randi([1 64], 1, 1);
% Decrypted_MIC(ERROR_bit) = 1;

%---Search error------------------------------------------------------
if Decrypted_MIC == MIC(1:64)
    
else
   ERROR = ERROR + 1; 
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