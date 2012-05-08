ENV['RACK_ENV'] = 'test'

require 'bundler'
Bundler.require(:test)

require 'rack/test'
require './tmpfollow'

Sinatra::Base.set :environment, :test
Sinatra::Base.set :run, false
Sinatra::Base.set :raise_errors, true
Sinatra::Base.set :logging, false
Sinatra::Base.set :session, false

def app
  TmpFollow
end

RSpec.configure do |config|
  config.include Rack::Test::Methods

  # reset database before each example is run
  config.before { DataMapper.auto_migrate! }
end
