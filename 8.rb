class String
  def hex_to_bytes
    [self].pack("H*").unpack("C*")
  end
end

class Array
  def aes_ecb_encrypted?
    groups_of_bytes = self.each_slice(16).to_a
    if not groups_of_bytes.count == groups_of_bytes.uniq.count
      return true
    end
  end
end


# Given data
inputs = File.open("8.txt", "r").each_line.to_a


# Test
inputs.each.with_index(1) do |input, index|
  bytes = input.hex_to_bytes
  if bytes.aes_ecb_encrypted?
    puts "Line #{index} is probably aes ecb encrypted"
  end
end
