require 'rubygems'

ROOT_PATH = File.dirname(__FILE__)

HOST = '0.0.0.0'
PORT = 31337
ENDIAN = :big

$: << File.join( ROOT_PATH, '.' )
$LOAD_PATH.unshift *Dir.glob( File.expand_path( './app/**/*' ) )
$: << File.join( ROOT_PATH, 'lib' )
