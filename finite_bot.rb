require 'open-uri'
require "openssl"
require 'net/imap'
require 'cinch'

class TinyURL
  include Cinch::Plugin

  listen_to :channel

  def shorten(url)
    url = open("http://tinyurl.com/api-create.php?url=#{URI.escape(url)}").read
    url == "Error" ? nil : url
  rescue OpenURI::HTTPError
    nil
  end

  def listen(m)
    urls = URI.extract(m.message, "http")
    short_urls = urls.map { |url| shorten(url) }.compact
    unless short_urls.empty?
      m.reply short_urls.join(", ")
    end
  end
end

class ForEX
  include Cinch::Plugin

  listen_to :channel

  def getrate(*p)
    fxdatafile = File.new("forex.data", "r")
    fxsymbols = fxdatafile.gets.split(',')
    fxrates = fxdatafile.gets.split(',')
    rates = Hash[*fxsymbols.zip(fxrates).flatten]
    fxdatafile.close
    return rates
  end

  def listen(m)
    commonfx = ["USD", "EUR", "JPY", "PHP", "CHF"]
    regex = Regexp.new(/([0-9.]+?)\s*(JPY|USD|EUR|PHP|CHF)/i)
    matchdata = regex.match(m.message)
    if matchdata
        matchvalue=matchdata[1]
        matchsymbol=matchdata[2].upcase
        ircstring=matchvalue + " " + matchsymbol + " == "
        rates=getrate 
        for ss in 0...commonfx.length
            if commonfx[ss] != matchsymbol
              fxconv = matchvalue.to_f * rates[commonfx[ss]].to_f / rates[matchsymbol].to_f
              if commonfx[ss] == "JPY"
                  ircstring += sprintf("%.0f %s, ",fxconv.round,commonfx[ss])
              else
                  ircstring += sprintf("%.2f %s, ",fxconv.round(2),commonfx[ss])
              end
            end
        end
       m.reply ircstring.chop.chop
    end
  end
end

class Imap
  include Cinch::Plugin

  listen_to :join

  def initialize(*args)
    super
    @mail_host = config[:host] 
    @mail_user = config[:user]
    @mail_password = config[:password]
    @mail_folder = config[:folder] || 'INBOX'
    @mail_port = config[:port] || 143
    @mail_ssl = config[:ssl] || false
    @mark_as_read = config[:mark_as_read ] || true
    @interval = config[:interval] || 300
    @messages_seen = 0
  end


  def listen(m)
    loop do
    sleep(@interval)
    imap = imap_connect
    imap_poll(m, imap)
    imap.disconnect
    end 
  end
  def get_messages(conn)
    conn.search(["UNSEEN"]).each do |message_id|
    envelope = conn.fetch(message_id, "ENVELOPE")[0].attr["ENVELOPE"]
    body = conn.fetch(message_id, 'BODY[TEXT]')[0].attr['BODY[TEXT]']
    name = envelope.from[0].name
    mailbox = envelope.from[0].mailbox
    host = envelope.from[0].host
    from = name.nil? ? host : name
    subj = envelope.subject
    conn.store(message_id, "+FLAGS", [:Seen]) if @mark_as_read
    @messages_seen += 1
    yield mailbox, subj, body
    end
  end
  def imap_connect
    connection = Net::IMAP.new(@mail_host, @mail_port, @mail_ssl, nil, false)
    connection.login(@mail_user, @mail_password)
    connection.select(@mail_folder)
    return connection
  end
  def imap_poll(m, connection)
    get_messages(connection) do |mailbox, subj, body| 
      urls = URI.extract(body, "http")
      urls.uniq.each do |url|
        m.reply "[#{mailbox}] " + url
      end
    end
  end
end

bot = Cinch::Bot.new do
  configure do |c|
#    c.server = ""
#    c.port = ""
#    c.nick = ""
#    c.user = ""
#    c.password = ""
#    c.channels = [""]
#    c.plugins.plugins = [TinyURL, ForEX, Imap]
#    c.plugins.options[Imap] = {
#      :host => '',
#      :user => '',
#      :password => "",
#      :port => 993,
#      :folder => '',
#      :ssl => true,
#      :interval => 10,
#    }
  end

end

bot.start
