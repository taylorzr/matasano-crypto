class String
  def english_rating
    common_chars = "ETAOIN SHRDLU"
    common_chars.each_char.with_index.reduce(0) do |rating, (char, index) |
      multiplier = common_chars.length - index
      rating + (multiplier * self.upcase.count(char))
    end
  end
end

class Bytes
  
end

def decipher(bytes, key)
  bytes.map{ |byte| byte ^ key }  
end

def rainbow_decipher(bytes, start: 0, stop: 127)
  (start..stop).collect{ |key| decipher(bytes, key) }
end
 
def ham_diff(bytes1, bytes2)
  bytes1.zip(bytes2).reduce(0) do |count, (byte1, byte2)|
    diff = (byte1 ^ byte2).to_s(2).count("1")
    count + diff
  end
end

def average_ham_diff(byte_groups)
  total_diff = (1..byte_groups.count - 2).to_a.reduce(0) do |diff, index|
    byte_group1, byte_group2 = byte_groups[index - 1], byte_groups[index]
    diff + ham_diff(byte_groups[index - 1], byte_groups[index])
  end
  total_diff.to_f / byte_groups.length
end

def find_key_size(ciphered_bytes, smallest: 2, largest: 40)
  keyed_ham_diffs = (smallest..largest).collect do |key_size|
    byte_groups = ciphered_bytes.each_slice(key_size).to_a
    diff = average_ham_diff(byte_groups)
    [key_size, diff/key_size]
  end
  keyed_ham_diffs.sort_by!{ |(key_size, ham_diff)| ham_diff }
  keyed_ham_diffs.first.first
end

require 'base64'
require 'pry'

def base64_file_bytes(file_path)
  file = File.open(file_path, "r")
  line_strings = file.each_line.collect do |line|
    Base64.decode64(line)
  end
  #binding.pry
  line_strings.join.unpack("C*")
end

def group_bytes(bytes, key_size)
  bytes.group_by.with_index{ |byte, index| index % key_size }.values 
end

# Test
ciphered_bytes = base64_file_bytes("6.txt")
key_size = find_key_size(ciphered_bytes)
grouped_bytes = group_bytes(ciphered_bytes, key_size)
plain_texts = grouped_bytes.collect do |bytes|
  plain_texts = rainbow_decipher(bytes).map{ |bytes| bytes.pack("C*") }
  plain_texts.max_by(&:english_rating) 
end

plain_texts = plain_texts.collect do |group|
  group.each_char.to_a
end

result = (0..28).reduce([]) do |plain_text, group_number|
  plain_text << plain_texts.collect{ |plain_text_group| plain_text_group[group_number] }
end

puts result.flatten.join
