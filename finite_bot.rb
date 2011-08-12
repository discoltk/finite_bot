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

$APP_CONFIG = YAML.load_file("./config/irc.yaml")

bot = Cinch::Bot.new do
  configure do |c|
   c.server          = $APP_CONFIG[:server]
   c.port            = $APP_CONFIG[:port]
   c.nick            = $APP_CONFIG[:nick]
   c.user            = $APP_CONFIG[:user]
   c.password        = $APP_CONFIG[:password]
   c.channels        = $APP_CONFIG[:channels].to_array
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
