#
#  tinyurl.rb
#

module FiniteBot
  class TinyURL
    include Cinch::Plugin

    listen_to :channel

    def title(url)
      html  = open(url).read
      title = %r{<title>(.*)</title>}m.match(html)[1]
      title.squeeze(" ").gsub("\r"," ").gsub("\n"," ").squeeze(" ").strip
    end

    def shorten(url)
      url = open("http://tinyurl.com/api-create.php?url=#{URI.escape(url)}").read
      url == "Error" ? nil : url
    rescue OpenURI::HTTPError
      nil
    end

    def listen(m)
      urls = URI.extract(m.message, ["http", "https"])

      unless urls.first.nil?
        unless urls.first.size < (APP_CONFIG[:tinyurl][:minimum_characters] || 25)
          short_urls = urls.map { |url|
            if APP_CONFIG[:tinyurl][:display_titles].nil? or APP_CONFIG[:tinyurl][:display_titles] == false
              shorten(url)
            else
              shorten(url)+" -- "+title(url)
            end
          }.compact
          m.reply short_urls.join(", ") unless short_urls.empty?
        end
      end
    end
  end
end