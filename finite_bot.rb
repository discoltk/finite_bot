# 
#  finite_bot.rb
#  

require 'open-uri'
require "openssl"
require 'net/imap'

require "rubygems"
require 'bundler/setup'
require 'cinch'

require './lib/finite_bot/forex'
require './lib/finite_bot/imap'
require './lib/finite_bot/tinyurl'

include FiniteBot

bot = Cinch::Bot.new do
  configure do |c|
   c.server = "irc.efnet.net"
   c.port = "6667"
   c.nick = "fbot12"
   c.user = "silicon"
   c.password = ""
   c.channels = ["#baykids"]
   c.plugins.plugins = [TinyURL, ForEX, Imap]
   c.plugins.options[Imap] = {
     :host => '',
     :user => '',
     :password => "",
     :port => 993,
     :folder => '',
     :ssl => true,
     :interval => 10,
   }
  end
end

bot.start
