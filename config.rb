require 'rubygems'

ROOT_PATH = File.dirname(__FILE__)

HOST = '0.0.0.0'
DEVICE_PORT = 31337
WEB_PORT = 10080
ENDIAN = :little
BREWBIT_API_URL = "http://brewbit.dev/api"

$: << File.join( ROOT_PATH, '.' )
$LOAD_PATH.unshift *Dir.glob( File.expand_path( './app/**/*' ) )
$: << File.join( ROOT_PATH, 'lib' )
$: << File.join( ROOT_PATH, 'app' )
