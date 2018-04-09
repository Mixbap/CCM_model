function [ Encrypted_Data ] = Encrypted_AES( Input_Data, Key_AES )

Encrypted_Data = xor(Input_Data, Key_AES);

end

