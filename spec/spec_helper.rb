require 'simplecov'
SimpleCov.start

require 'ruby-debug'

$: << File.join( File.dirname(__FILE__), '..' )
$: << File.join( File.dirname(__FILE__), '..', 'messages' )
$: << File.join( File.dirname(__FILE__), '..', 'handlers' )

require 'factory_girl'
require 'config'


RSpec.configure do |config|
  FactoryGirl.find_definitions

  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
end

