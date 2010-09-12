$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'trinidad_lifecycle_extension'

require 'rubygems'
require 'trinidad'
require 'spec'

Spec::Runner.configure do |config| 
  config.mock_with :mocha
end
