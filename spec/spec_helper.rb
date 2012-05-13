require 'simplecov'
SimpleCov.start { add_filter '/spec/' }

ENV['RACK_ENV'] = 'test'

require 'bundler'
Bundler.require(:test)

require 'rack/test'
require './tmpfollow'

OmniAuth.config.test_mode = true
OmniAuth.config.logger = Logger.new('/dev/null')

def app
  TmpFollow
end

RSpec.configure do |config|
  config.include Rack::Test::Methods

  # reset database before each example is run
  config.before { DataMapper.auto_migrate! }
end
