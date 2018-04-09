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


%----Encryption header-----------------------------------
Encrypted_Initial_Vector = Encrypted_AES(Intial_Vector, Key_Vector);%����������� initial vector
AES_Header = xor(Encrypted_Initial_Vector, Header_TB);%xor ������������� initial vector � ���������

%--------Create MIC------------------------------------------------------
In_Data = AES_Header;

for k = 0:(Section_value - 1)
    
    Encrypted_input_data = Encrypted_AES(In_Data, Key_Vector);%���������� ������
    In_Data = xor(Encrypted_input_data, Data_Payload(128*k + 1 : 128*k + 128));%xor � �������  
end

Enc_input_data = Encrypted_AES(In_Data, Key_Vector);

MIC = Enc_input_data(1:64); %������ ������� 64 ��� MIC 


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

% %---Decrypted MIC----------------------------------------------------------
% Counter = Create_Counter(0, Nonce);
% 
% Encrypted_Counter_MIC = Encrypted_AES(Counter, Key_Vector); %AES Counter MIC
% Decrypted_MIC = xor(Encrypted_MIC, Encrypted_Counter_MIC); %����������� MIC

%---Decrypted MIC-------------------------------------------------------
In_Data = AES_Header;

for k = 0:(Section_value - 1)
    
    Encrypted_input_data = Encrypted_AES(In_Data, Key_Vector);%���������� ������
    In_Data = xor(Encrypted_input_data, Decrypted_Data(128*k + 1 : 128*k + 128));%xor � �������  
end

Enc_input_data = Encrypted_AES(In_Data, Key_Vector);

Decrypted_MIC = Enc_input_data(1:64); %������ ������� 64 ��� MIC 


% %---Decrypted Header-------------------------------------------------------
% In_Data = Encrypted_AES(Decrypted_MIC, Key_Vector);%����������� ������������ MIC
% 
% for k = (Section_value - 1):0
%     AES_MIC_xor_Decrypted_Data = xor(In_Data, Decrypted_Data(128*k + 1 : 128*k + 128));%xor � �������
%     In_Data = Encrypted_AES(AES_MIC_xor_Decrypted_Data, Key_Vector);%���������� ������
% end
% 
% Encrypted_Initial_Vector = Encrypted_AES(Intial_Vector, Key_Vector);%����������� initial vector
% 
% Decrypted_Header = xor(Encrypted_Initial_Vector, In_Data);


% ---Add random error bit MIC-----------------------------------------------
ERROR_bit = randi([1 64], 1, 1);
Decrypted_MIC(ERROR_bit) = 1;
% Decrypted_MIC(ERROR_bit) = not(Decrypted_MIC(ERROR_bit));


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