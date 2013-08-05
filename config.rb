require 'rubygems'

ROOT_PATH = File.dirname(__FILE__)

HOST = '0.0.0.0'
DEVICE_PORT = 31337
WEB_PORT = 10080
ENDIAN = :little

$: << File.join( ROOT_PATH, '.' )
$LOAD_PATH.unshift *Dir.glob( File.expand_path( './app/**/*' ) )
$: << File.join( ROOT_PATH, 'lib' )
