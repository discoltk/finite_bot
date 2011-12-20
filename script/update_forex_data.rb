#!/usr/bin/env ruby -wT0
#
#  update_forex_data.rb
#
#  Created by hMz on 2011-08-19.
#

APP_CONFIG = {
  :url  => "http://www.x-rates.com/calculator.html"
}

require 'net/http'
require 'uri'

url = URI.parse(APP_CONFIG[:url])

res = Net::HTTP.start(url.host, url.port) {|http|
  http.get(url.to_s)
}

output = res.body

File.open("forex.data", "w") do |fh|
  [ %r{var currency}, %r{var rate} ].each do |my_variable|
    my_variable = output.split("\n").select {|x| x =~ /^#{my_variable}/}
    my_variable.first.gsub!(/.*\((.*)\)\;/,'\1')
    my_variable.first.gsub!(/["]/,'')
    fh.write("#{my_variable.first}\n")
  end
end
