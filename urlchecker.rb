# email nv1982@gmail.com if you have any questions about this script
# Twitter: @andreikoenig
# andreikoenig.blogspot.com  my blog

require 'net/http'
require 'net/smtp'

content =[]
ignored_urls = []

file = File.open("urldoc.txt", "r")
while !file.eof?
	line = file.readline
	next if line.strip! == ""
	if line.match(/^#/)
		ignored_urls.push(line)
	else
		content.push(line)
	end
end
file.close

puts "Number of URLS to be tested is: #{content.length}"
puts "How many URLs would you like to test?"
input = gets
puts "Testing first #{input.chomp} URLs......"

error_404 = 0

result = []
invalid_urls = []

content.each_with_index do |url, i|
	break if i > input.to_i - 1
	begin
		res = Net::HTTP.get_response(URI(url))
		error_404 += 1 if res.code == "404"
		result.push("For #{url}: The CODE is: #{res.code} "\
		"and the message is: #{res.message}.")
	rescue
		result.push("For #{url}: Error occured - please check your URL.")
		invalid_urls.push(url)
	end
	print "* "
end

puts "\nNumber of URLs NOT FOUND (404): #{error_404}"
puts "Number of Ignored URLS: #{ignored_urls.length}"
puts "Number of Invalid URLs: #{invalid_urls.length}"
puts
puts "Sending an email with results. Please wait..."


message = <<MESSAGE_END
From: name <user@gmail.com>
To: name <email address>
Subject: URL Test Result

  Here is the result of the URL Test.
  =======================================================================
  Number of total URLs in the file: #{content.length}.
  Number of URLs tested: #{input.chomp}.
  Number of URLs NOT FOUND (404): #{error_404}.
  Number of Ignored URLs (commented out): #{ignored_urls.length}.
  Number of Invalid URLs: #{invalid_urls.length}. (see full list in the end of the email.)

  -----------------------------------------------------------------------

  URL CHECK RESULT:

  #{result.join("\n  ")}
  -----------------------------------------------------------------------

  THE FOLLLOWING URLS APPEAR TO BE INVALID, PLEASE RECHECK:

  #{invalid_urls.join("\n  ")}
  -----------------------------------------------------------------------



  For support, please email: email address
MESSAGE_END


smtp = Net::SMTP.new('smtp.gmail.com', 587)
smtp.enable_starttls
smtp.start('gmail.com', 'user@gmail.com', 'PASSWORD', :login)
smtp.send_message message, 'user@gmail.com', 'email address'
smtp.finish
puts "Email sent."