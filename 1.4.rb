class String
  def english_rating
    common_chars = "ETAOIN SHRDLU"
    common_chars.each_char.with_index.reduce(0) do |rating, (char, index) |
      multiplier = common_chars.length - index
      rating + (multiplier * self.upcase.count(char))
    end
  end
end

def hex_to_bytes(hex)
  [hex].pack("H*").bytes
end

def bytes_to_s(bytes)
  bytes.pack("C*") 
end

def decipher(bytes, key)
  bytes.map{ |byte| byte ^ key }  
end

def rainbow_decipher(bytes, start: 0, stop: 127)
  (start..stop).collect{ |key| decipher(bytes, key) }
end

require 'pry'

def file_lines_to_a(file_path)
  file = File.open(file_path, "r")
  file.each_line.collect do |line|
    line.chomp
  end
end

def crack_hidden_ciphered(file_path)
  double_rainbow = file_lines_to_a(file_path).collect.with_index(1) do |ciphered_string, line_number|
    ciphered_bytes = hex_to_bytes(ciphered_string)
    potential_bytes = rainbow_decipher(ciphered_bytes)
    [line_number, potential_bytes.map(&method(:bytes_to_s)).max_by(&:english_rating)]
  end
  double_rainbow.max_by do |line_number, deciphered_string|
    deciphered_string.english_rating
  end
end

# Test
line_number, message =  crack_hidden_ciphered("4.txt")
puts "Line number #{line_number} contains the message: "
p message
