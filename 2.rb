def fixed_xor(ciphered, key)
  ciphered_bytes = [ciphered].pack("H*").bytes
  key_bytes = [key].pack("H*").bytes
  deciphered_bytes = ciphered_bytes.zip(key_bytes).collect do |ciphered_byte, key_byte|
    ciphered_byte ^ key_byte
  end
  deciphered_bytes.map{ |byte| byte.to_s(16) }.join
end

# Given data
input = "1c0111001f010100061a024b53535009181c"
key = "686974207468652062756c6c277320657965"
expected_output = "746865206b696420646f6e277420706c6179"

# Test
output = fixed_xor(input, key)
if output == expected_output
  puts "Great success"
else
  puts "Fail: #{output}"
end
