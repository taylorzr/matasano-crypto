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
  def decrypt
    key_size = self.key_size
    grouped_bytes = self.group_by.with_index{ |byte, index| index % key_size }.values
    key_array = []
    grouped_plain_texts = grouped_bytes.collect do |bytes|
      rainbow_plain_texts = rainbow_xor(bytes).map{ |bytes| bytes.pack("C*") }
      best_plain_text = rainbow_plain_texts.max_by(&:english_rating) 
      key_array << rainbow_plain_texts.index(best_plain_text)
      best_plain_text
    end

    plain_texts = grouped_plain_texts.collect do |group|
      group.each_char.to_a
    end

    result = (0..28).reduce([]) do |plain_text, group_number|
      plain_text << plain_texts.collect{ |plain_text_group| plain_text_group[group_number] }
    end

    puts key_array.pack("C*")
    result.flatten.join
  end

  def ham_diff(other)
    self.zip(other).reduce(0) do |count, (byte1, byte2)| diff = (byte1 ^ byte2).to_s(2).count("1")
      count + diff
    end
  end

  def average_ham_diff(key_size)
    byte_groups = self.each_slice(key_size).to_a
    total_diff = (1..byte_groups.count - 2).to_a.reduce(0) do |diff, index|
      byte_group1, byte_group2 = byte_groups[index - 1], byte_groups[index]
      diff + byte_group1.ham_diff(byte_group2)
    end
    total_diff.to_f / byte_groups.length
  end

  def key_size(smallest: 2, largest: 40)
    keyed_ham_diffs = (smallest..largest).collect do |potential_key_size|
      average_diff = self.average_ham_diff(potential_key_size)
      normalized_diff = average_diff / potential_key_size
      [potential_key_size, normalized_diff]
    end
    keyed_ham_diffs.sort_by!{ |(key_size, ham_diff)| ham_diff }
    keyed_ham_diffs.first.first
  end

  def xor(bytes, key)
    bytes.map{ |byte| byte ^ key }  
  end

  def rainbow_xor(bytes, start: 0, stop: 127)
    (start..stop).collect{ |key| xor(bytes, key) }
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
puts bytes.key_size
puts bytes.decrypt
