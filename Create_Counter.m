function [ Counter ] = Create_Counter( N, Nonce )

Flag_Counter(1:8) = 0;

%----Creare N vector------------------------------------
N_bin = dec2bin(N, 20); %������� � ��������� �����

for i = 1:20
    N(i) = str2num(N_bin(i)); %��������� ������� N
end


Counter = [Flag_Counter Nonce N];

end

