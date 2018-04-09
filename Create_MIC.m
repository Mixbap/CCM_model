function [ MIC ] = Create_MIC( Header_TB, Intial_Vector, Section_value, Data_Payload , Key_Vector)

Encrypted_Initial_Vector = Encrypted_AES(Intial_Vector, Key_Vector);%зашифровали initial vector
AES_Header = xor(Encrypted_Initial_Vector, Header_TB);%xor зашифрованого initial vector и заголовка

In_Data = AES_Header;

for k = 0:(Section_value - 1)
    
    Encrypted_input_data = Encrypted_AES(In_Data, Key_Vector);%шифрование данных
    In_Data = xor(Encrypted_input_data, Data_Payload(128*k + 1 : 128*k + 128));%xor с данными  
end

Enc_input_data = Encrypted_AES(In_Data, Key_Vector);

MIC = Enc_input_data(1:64); %взятие старших 64 бит MIC 

end

