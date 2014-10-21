require 'base64'

def base64_file_to_string(file_path)
  file = File.open(file_path, "r")
  line_strings = file.each_line.collect do |line|
    Base64.decode64(line)
  end
  line_strings.join
end

require 'openssl'

# Given data
encrypted = base64_file_to_string("7.txt")

# Decipher
decipher = OpenSSL::Cipher.new('AES-128-ECB')
decipher.decrypt
decipher.key = "YELLOW SUBMARINE"

# Test
message = decipher.update(encrypted) + decipher.final 
puts message

