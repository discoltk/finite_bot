# 
#  ctcp.rb
# 

module FiniteBot
  class Ctcp
    include Cinch::Plugin

    ctcp :ping
    ctcp :time
    ctcp :userinfo
    ctcp :version

    def ctcp_ping(m)
      m.ctcp_reply m.ctcp_args.join(" ")
    end

    def ctcp_time(m)
      m.ctcp_reply Time.now.strftime("%a %b %d %H:%M:%S %Z %Y")
    end

    def ctcp_userinfo(m)
      m.ctcp_reply "Finite Bot #{VERSION}"
    end

    def ctcp_version(m)
      m.ctcp_reply "Finite Bot #{VERSION}"
    end
  end
end