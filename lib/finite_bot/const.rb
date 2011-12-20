#
# const.rb
#

APP_ROOT = "#{File.dirname(__FILE__)}/../.."

raise ArgumentError, "Unable to read config file" unless File.exists?("#{APP_ROOT}/config/config.yaml")

APP_CONFIG = YAML.load_file("#{APP_ROOT}/config/config.yaml")

VERSION  = 0.14
