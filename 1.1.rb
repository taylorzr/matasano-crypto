require 'base64'

def hex_to_base64(hex)
  string = [hex].pack("H*")
  Base64.strict_encode64(string)
end


# Test
input = "49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d"

output = hex_to_base64(input)

expected_output= "SSdtIGtpbGxpbmcgeW91ciBicmFpbiBsaWtlIGEgcG9pc29ub3VzIG11c2hyb29t"

if output == expected_output
  puts "Great success"
else
  puts "Failure: #{output.inspect}"
end
