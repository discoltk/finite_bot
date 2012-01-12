#
#  tinyurl.rb
#

module FiniteBot
  class TinyURL
    include Cinch::Plugin

    listen_to :message

    def title(url)
      begin
        html = open(url).read
      rescue
        return nil
      end
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
          unless APP_CONFIG[:tinyurl][:display_titles].nil? or APP_CONFIG[:tinyurl][:display_titles] == false
            short_urls = urls.map { |url|
              cur_title = title(url) ? title(url) : nil rescue nil

              output = shorten(url)
              output = output + " -- " + cur_title unless cur_title.nil?

              output
              }.compact
            end
            m.reply short_urls.join(", ") unless short_urls.empty?
        end
      end
    end
  end
end