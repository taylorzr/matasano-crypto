require 'pry'
require 'openssl'

def base64_file_bytes(file_path)
  require 'base64'
  file = File.open(file_path, "r")
  line_strings = file.each_line.collect do |line|
    Base64.decode64(line)
  end
  line_strings.join.unpack("C*")
end

class Array
  def xor(bytes)
    self.zip(bytes).collect do |byte1, byte2|
      byte1 ^ byte2
    end
  end
end

class String
  def cbc_decrypt(key, iv)
    decipher = OpenSSL::Cipher.new('AES-128-ECB')
    decipher.decrypt
    decipher.key = key
    decipher.padding = 0
    blocked_bytes = self.bytes.each_slice(iv.length).to_a
    previous_block = iv
    decrypted_blocks = blocked_bytes.collect do |block|
      deciphered_block = decipher.update(block.pack("C*")) + decipher.final
      dechained_block = deciphered_block.bytes.xor(previous_block.bytes).pack("C*")
      previous_block = block.pack("C*")
      dechained_block
    end
    decrypted_blocks.join
  end

  def cbc_encrypt(key, iv)
    cipher = OpenSSL::Cipher.new('AES-128-ECB')
    cipher.encrypt
    cipher.key = key
    blocked_bytes = self.bytes.each_slice(iv.length).to_a   
    previous_block = iv
    encrypted_blocks = blocked_bytes.collect do |block|
      chained_block = block.xor(previous_block.bytes)    
      ciphered_block = cipher.update(chained_block.pack("C*")) + cipher.final
      previous_block = ciphered_block
    end
    encrypted_blocks.join
  end

end

bytes = base64_file_bytes("10.txt")

test_string = "Zach is hacking and he needs a string that is much longer so he can see if this is working so hopefully this string is long enough"

encrypted_test = test_string.cbc_encrypt("YELLOW SUBMARINE", 0.chr * 16)
p decrypted_test = encrypted_test.cbc_decrypt("YELLOW SUBMARINE", 0.chr * 16)

