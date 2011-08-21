# 
#  ctcp.rb
# 

module FiniteBot
  class Ctcp
    include Cinch::Plugin

    ctcp :userinfo

    def ctcp_userinfo(m)
      m.ctcp_reply "Finite Bot #{VERSION}"
    end
  end
end