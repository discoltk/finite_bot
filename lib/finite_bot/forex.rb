#
#  forex.rb
#

module FiniteBot
  class ForEX
    include Cinch::Plugin

    listen_to :channel

    def getrate(*p)
      File.open("config/forex.data") do |fh|
        fxsymbols = fh.gets.split(',')
        fxrates = fh.gets.split(',')
        Hash[*fxsymbols.zip(fxrates).flatten]
      end
    end

    def listen(m)
      commonfx = ["USD", "EUR", "JPY", "PHP", "CHF"]
      regex = Regexp.new(/([0-9.]+?)\s+(JPY|USD|EUR|PHP|CHF)/i)
      m.message.gsub!(",","")
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
end
