function [ Nonce, Intial_Vector, Data_Payload, Section_value, Key_Vector, Header_TB ] = Initialization(Header_length, Data_length)
%---Create Nonce----------------------------------------
Nonce = randi([0 1], 1, 100);

%----Create Flag--------------------------------------
Flag_Initial_Vector(1:8) = 0;

%----Creare TBlen------------------------------------
TBlen_bin = dec2bin(Header_length, 20); %������� � ��������� �����

for i = 1:20
    TBlen(i) = str2num(TBlen_bin(i)); %��������� ������� TBlen
end 


Intial_Vector = [Flag_Initial_Vector Nonce TBlen];

%---Input Data-----------------------------------------------------------
Data_Payload = randi([0 1], 1, Data_length);%���������� ������� ������

Section_value = ceil(length(Data_Payload)/128);%����������� ���������� ������

Data_Payload(Data_length + 1: 128*Section_value) = zeros();%���������� ������� ������

%---AES Key---------------------------------------------------------------
Key_Vector = randi([0 1], 1, 128);

%---Create Header---------------------------------------------------------
Header_TB = randi([0 1], 1, Header_length);
Header_TB(Header_length + 1: 128) = zeros();

end

