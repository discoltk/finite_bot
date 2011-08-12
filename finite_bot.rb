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

$APP_CONFIG = YAML.load_file("./config/config.yaml")

bot = Cinch::Bot.new do
  configure do |c|
   c.server          = $APP_CONFIG[:irc][:server]
   c.port            = $APP_CONFIG[:irc][:port]
   c.nick            = $APP_CONFIG[:irc][:nick]
   c.user            = $APP_CONFIG[:irc][:user]
   c.password        = $APP_CONFIG[:irc][:password]
   c.channels        = $APP_CONFIG[:irc][:channels].to_array
   c.plugins.plugins = [TinyURL, ForEX, Imap]
   c.plugins.options[Imap] = {
     :host     => '',
     :user     => '',
     :password => "",
     :port     => 993,
     :folder   => '',
     :ssl      => true,
     :interval => 10,
   }
  end
end

bot.start
