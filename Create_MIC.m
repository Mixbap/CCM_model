function [ MIC ] = Create_MIC( Header_TB, Intial_Vector, Section_value, Data_Payload , Key_Vector)

Encrypted_Initial_Vector = Encrypted_AES(Intial_Vector, Key_Vector);%����������� initial vector
AES_Header = xor(Encrypted_Initial_Vector, Header_TB);%xor ������������� initial vector � ���������

In_Data = AES_Header;

for k = 0:(Section_value - 1)
    
    Encrypted_input_data = Encrypted_AES(In_Data, Key_Vector);%���������� ������
    In_Data = xor(Encrypted_input_data, Data_Payload(128*k + 1 : 128*k + 128));%xor � �������  
end

Enc_input_data = Encrypted_AES(In_Data, Key_Vector);

MIC = Enc_input_data(1:64); %������ ������� 64 ��� MIC 

end

