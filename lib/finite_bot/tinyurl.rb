# 
#  tinyurl.rb
# 

module FiniteBot
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

      unless urls.first.size < 30
        short_urls = urls.map { |url| shorten(url) }.compact
        m.reply short_urls.join(", ") unless short_urls.empty?
      end
    end
  end
end