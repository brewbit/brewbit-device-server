require 'rubygems'
require 'log4r'

ROOT_PATH = File.dirname(__FILE__)

API_VERSION = 1
HOST = '0.0.0.0'
DEVICE_PORT = 31337
WEB_PORT = 10080
DEVICE_CONNECTION_TIMEOUT = 15

BREWBIT_API_HOST = ENV['BREWBIT_API_HOST'] || 'localhost:3000'
BREWBIT_API_URL = "http://#{BREWBIT_API_HOST}/api"

$LOAD_PATH << File.join( ROOT_PATH, '.' )
$LOAD_PATH.unshift *Dir.glob( File.expand_path( './app/**/*' ) )
$LOAD_PATH << File.join( ROOT_PATH, 'app' )
$LOAD_PATH << File.join( ROOT_PATH, 'lib' )

Log = Log4r::Logger.new( 'device_server' )
Log.level = Log4r::DEBUG

MEGABYTE = 1024 * 1024
MAX_LOG_SIZE = 60 * MEGABYTE
config = {
  filename:     "log/device_server.log",
  maxsize:      MAX_LOG_SIZE,
  max_backups:  2,
  trunc:        true
}
rolling_outputter = Log4r::RollingFileOutputter.new( 'device_server', config )
format = Log4r::PatternFormatter.new( :pattern => "[%l] %d :: %m",
                                      :date_pattern => "%a %d %b %H:%M %p %Y" )
rolling_outputter.formatter = format

Log.add rolling_outputter

