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

class String
  def english_rating
    common_chars = "ETAOIN SHRDLU"
    common_chars.each_char.with_index.reduce(0) do |rating, (char, index) |
      multiplier = common_chars.length - index
      rating + (multiplier * self.upcase.count(char))
    end
  end
end


# Given data
ciphered_hex = "1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736"

# Test
ciphered_bytes = hex_to_bytes(ciphered_hex)
possible_outputs = rainbow_decipher(ciphered_bytes).map(&method(:bytes_to_s))
output = possible_outputs.max_by(&:english_rating)
if output == "Cooking MC's like a pound of bacon"
  puts "Great success"
else
  puts "Fail: #{output.inspect}"
end
