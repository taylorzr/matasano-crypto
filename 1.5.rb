def repeating_xor(vanilla, key="ICE")
  vanilla_bytes = vanilla.unpack("C*")
  key_bytes = key.unpack("C*")
  vanilla_bytes.map.with_index do |vanilla_byte, vanilla_index|
    key = key_bytes[vanilla_index % key_bytes.count]
    vanilla_byte ^ key
  end
end

def bytes_to_hex(bytes)
  bytes.map{ |byte| "%02x" % byte }
end

# Given data
plain_text = "Burning 'em, if you ain't quick and nimble\nI go crazy when I hear a cymbal"
expected_output = "0b3637272a2b2e63622c2e69692a23693a2a3c6324202d623d63343c2a26226324272765272a282b2f20430a652e2c652a3124333a653e2b2027630c692b20283165286326302e27282f"

# Test
ciphered_bytes = repeating_xor(plain_text)
output = bytes_to_hex(ciphered_bytes).join
if output == expected_output
  puts "Great success"
else
  puts "Fail: #{output}"
end
