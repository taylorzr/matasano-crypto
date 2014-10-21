class String
  def english_rating
    common_chars = "ETAOIN SHRDLU"
    common_chars.each_char.with_index.reduce(0) do |rating, (char, index) |
      multiplier = common_chars.length - index
      rating + (multiplier * self.upcase.count(char))
    end
  end
end

class Array
  def decrypt_group
    plain_text_rainbow = self.rainbow_xor.map{ |byte| byte.pack("C*") }
    plain_text = plain_text_rainbow.max_by(&:english_rating) 
    key_char = plain_text_rainbow.index(plain_text).chr
    [key_char, plain_text.each_char.to_a]
  end

  def group_by_key_size(key_size)
    self.group_by.with_index{ |byte, index| index % key_size }.values
  end

  def ungroup_by_key_size(key_size)
    (0..key_size-1).each_with_object([]) do |index, message_chars|
      self.each do |group|
	message_chars << group[index]
      end
    end
  end

  def decrypt
    key_size = self.key_size
    bytes_groups = self.group_by_key_size(key_size)
    grouped_message_chars = []
    key_chars = []
    bytes_groups.each do |bytes_group|
      key_char, message_chars = bytes_group.decrypt_group
      key_chars << key_char
      grouped_message_chars << message_chars
    end
    message_chars = grouped_message_chars.ungroup_by_key_size(key_size)
    [key_chars, message_chars]
  end

  def ham_diff(other)
    self.zip(other).reduce(0) do |count, (byte1, byte2)| diff = (byte1 ^ byte2).to_s(2).count("1")
      count + diff
    end
  end

  def key_rating(key_size)
    byte_groups = self.each_slice(key_size).to_a[0..-2]
    total_diff = byte_groups[0..-2]
		 .zip(byte_groups[1..-1])
		 .reduce(0) do |total_diff, (byte_group, byte_group_next)|
      diff = byte_group.ham_diff(byte_group_next)
      total_diff + diff
    end
    total_diff.to_f / (byte_groups.length - 1) / key_size
  end

  def key_size(smallest: 2, largest: 40)
    key_sizes_rainbow = (smallest..largest).each_with_object({}) do |potential_key_size, key_sizes|
      key_rating  = self.key_rating(potential_key_size)
      key_sizes[potential_key_size] = key_rating
    end
    key_sizes_rainbow.min_by{ |key_size, key_rating| key_rating }.first
  end

  def xor(key)
    self.collect{ |byte| byte ^ key }  
  end

  def rainbow_xor(start: 0, stop: 127)
    (start..stop).collect{ |key| self.xor(key) }
  end
end

require 'base64'

def base64_file_bytes(file_path)
  file = File.open(file_path, "r")
  line_strings = file.each_line.collect do |line|
    Base64.decode64(line)
  end
  line_strings.join.unpack("C*")
end

# Test
bytes = base64_file_bytes("6.txt")
key_chars, message_chars = bytes.decrypt
puts
puts "Key: "
puts "  #{key_chars.join}"
puts
puts "Message: "
message_chars.join.split("\n").each do |line|
  puts "  #{line}"
end
