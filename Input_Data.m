function [ Data_Payload,  Section_value] = Input_Data( Data_length )

Data_Payload = randi([0 1], 1, Data_length);%���������� ������� ������

Section_value = ceil(length(Data_Payload)/128);%����������� ���������� ������

Data_Payload(Data_length + 1: 128*Section_value) = zeros();%���������� ������� ������


end

