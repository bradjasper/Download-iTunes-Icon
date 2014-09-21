#!/usr/bin/ruby
# encoding: utf-8
#
# Grab iTunes Icon - Brett Terpstra 2014 <http://brettterpstra.com>
#
# Retrieve an iOS app icon at the highest available resolution
# All arguments are combined to create an iTunes search
# The icon for the first result, if found, is written to a filename based on search terms
#
# example:
# $ itunesicon super monsters ate my condo
#
# http://brettterpstra.com/2013/04/28/instantly-grab-a-high-res-icon-for-any-ios-app/
# http://brettterpstra.com/2013/12/18/icon-grabber-updated-to-search-any-platform/

%w[net/http open-uri cgi].each do |filename|
  require filename
end

def find_icon(terms, entity, size)
  url = URI.parse("http://itunes.apple.com/search?term=#{CGI.escape(terms)}&entity=#{entity}")
  res = Net::HTTP.get_response(url).body
  match = res.match(/"#{size}":"(.*?)",/)
  unless match.nil?
    return match[1]
  else
    return false
  end
end

terms = ARGV.join(" ")
entity = "iPadSoftware"
type = "_ipad"
if terms =~ /[\#@](ipad|iphone|mac)/i
  if terms =~ /[\#@]iphone/i
    entity = "software"
    type = "_iphone"
  elsif terms =~ /[\#@]mac/i
    entity = "macSoftware"
    type = "_mac"
  end
  terms.gsub!(/[\#@](ipad|iphone|mac)/i, "").gsub!(/\s+/," ")
end

format = "artworkUrl100"
if terms =~ /~(s(mall)?|m(edium)?|l(arge)?)/i
  size = $1
  format = case size
    when /s(mall)?/ then "artworkUrl60"
    when /m(edium)?/ then "artworkUrl512"
    else "artworkUrl100"
  end
  terms.gsub!(/~(s(mall)?|m(edium)?|l(arge)?)/i, "").gsub!(/\s+/," ")
end


terms.strip!

icon_url = find_icon(terms, entity, format)
unless icon_url
  puts "Error: failed to locate iTunes url. You may need to adjust your search terms."
  exit
end
url = URI.parse(icon_url)
target = File.expand_path("./images/icon-"+terms.gsub(/[^a-z0-9]+/i,'-')+"."+icon_url.match(/\.(jpg|png)$/)[1])
rounded = File.expand_path("./images/icon-"+terms.gsub(/[^a-z0-9]+/i,'-')+"-rounded."+icon_url.match(/\.(jpg|png)$/)[1])
twox = File.expand_path("./images/icon-"+terms.gsub(/[^a-z0-9]+/i,'-')+"@2x."+icon_url.match(/\.(jpg|png)$/)[1])
threex = File.expand_path("./images/icon-"+terms.gsub(/[^a-z0-9]+/i,'-')+"@3x."+icon_url.match(/\.(jpg|png)$/)[1])
begin
  open(url) do |f|
    File.open(target,'w+') do |file|
      file.puts f.read
    end
    puts "#{target}"
  end
rescue
  puts "Error: failed to save icon."
end

# Make rounded
convert = `convert -size 1024x1024 xc:none -fill white -draw 'roundRectangle 0,0 1024,1024 160,160' #{target} -compose SrcIn -composite #{rounded}`

# Make @2x and @3x assets
convert = `convert #{rounded} -resize 80x80 #{twox}`
convert = `convert #{rounded} -resize 120x120 #{threex}`

puts rounded
puts twox
puts threex
