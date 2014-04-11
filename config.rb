require 'rubygems'

ROOT_PATH = File.dirname(__FILE__)

API_VERSION = 1
HOST = '0.0.0.0'
DEVICE_PORT = 31337
WEB_PORT = 10080

BREWBIT_API_HOST = ENV['BREWBIT_API_HOST'] || 'localhost:3000'
BREWBIT_API_URL = "http://#{BREWBIT_API_HOST}/api"

$LOAD_PATH << File.join( ROOT_PATH, '.' )
$LOAD_PATH.unshift *Dir.glob( File.expand_path( './app/**/*' ) )
$LOAD_PATH << File.join( ROOT_PATH, 'app' )
$LOAD_PATH << File.join( ROOT_PATH, 'lib' )

