# 
#  imap.rb
# 

module FiniteBot
  class Imap
    include Cinch::Plugin

    listen_to :join

    def initialize(*args)
      super
      @mail_host     = config[:host] 
      @mail_user     = config[:user]
      @mail_password = config[:password]
      @mail_folder   = config[:folder] || 'INBOX'
      @mail_port     = config[:port] || 143
      @mail_ssl      = config[:ssl] || false
      @mark_as_read  = config[:mark_as_read ] || true
      @interval      = config[:interval] || 300
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
end