#!/usr/bin/ruby
# encoding: utf-8
#
# Retrieve an iOS app icon at 512x512px
# All arguments are combined to create an iTunes search
# The icon for the first result, if found, is written to a filename based on search terms
#
# example:
# $ itunesicon super monsters ate my condo

%w[net/http open-uri cgi].each do |filename|
  require filename
end

def find_icon(terms)
  url = URI.parse("http://itunes.apple.com/search?term=#{CGI.escape(terms)}&entity=iPadSoftware")
  res = Net::HTTP.get_response(url).body
  match = res.match(/"artworkUrl512":"(.*?)",/)
  unless match.nil?
    return match[1]
  else
    return false
  end
end

terms = ARGV.join(" ")
icon_url = find_icon(terms)
unless icon_url
  puts "Failed to get iTunes url"
  exit
end
url = URI.parse(icon_url)
target = terms.gsub(/[^a-z0-9]+/i,'-')+"."+icon_url.match(/\.(jpg|png)$/)[1]
begin
  open(url) do |f|
    File.open(target,'w+') do |file|
      file.puts f.read
    end
    puts "File written to #{target}."
  end
rescue
  puts "Failed to write icon."
end
