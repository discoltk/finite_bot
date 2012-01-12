$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '../lib')

require 'open-uri'
require "openssl"
require 'net/imap'

require "rubygems"
require 'bundler/setup'
require 'cinch'
require 'autoreload'

require 'finite_bot/const'
autoreload(:interval=>2, :verbose=>false) do
  require 'finite_bot/ctcp'
  require 'finite_bot/forex'
  require 'finite_bot/imap'
  require 'finite_bot/tinyurl'
end
