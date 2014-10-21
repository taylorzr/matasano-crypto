class Array
  def pad(byte_count: 20, padding: 4)
    pad_count = byte_count - self.count
    self.clone.tap{ |new_array| pad_count.times{ new_array << padding } }
  end
end

# Given data
message = "YELLOW SUBMARINE"
expected_output = "YELLOW SUBMARINE\x04\x04\x04\x04"

# Test
bytes = message.unpack("C*")
output = bytes.pad.pack("C*")
puts output == expected_output
