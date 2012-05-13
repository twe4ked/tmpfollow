ENV['RACK_ENV'] ||= 'development'

require 'bundler'
Bundler.require(:default, ENV['RACK_ENV'].to_sym)

require 'logger'
require 'sinatra/reloader' if Sinatra::Base.development?

class TmpFollow < Sinatra::Base
  enable :sessions
  use Rack::Flash

  configure do
    Dir.glob('./lib/*.rb') { |file| require file }

    database_url = ENV['SHARED_DATABASE_URL'] || "postgres://#{ENV['USER']}@localhost/tmpfollow_#{development? ? 'development' : 'test'}"

    DataMapper.setup(:default, database_url)
    DataMapper::Logger.new($stdout, :debug)

    Twitter.configure do |config|
      config.consumer_key    = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
    end

    Compass.configuration do |config|
      config.project_path = File.dirname(__FILE__)
      config.sass_dir = 'views'
    end

    set :haml, {format: :html5}
  end

  use OmniAuth::Builder do
    provider :twitter, ENV['TWITTER_CONSUMER_KEY'], ENV['TWITTER_CONSUMER_SECRET']
  end

  helpers do
    def flashes
      [:notice, :alert].map do |type|
        "<p class='flash #{type}'>#{flash[type]}</p>" if flash[type] != nil
      end.join("\n")
    end

    def authenticated?
      session[:oauth_token] != nil && session[:oauth_token_secret] != nil
    end
  end

  get '/' do
    haml :index
  end

  before '/follow' do
    # validate username matches twitter username format
    # TODO: remove the '@' if it exists
    unless params[:user] =~ /^[A-Za-z0-9_]+/
      flash[:alert] = 'Username invalid.'
      redirect to '/'
    end

    # validate days is an integer
    unless is_numeric?(params[:days]) || params[:days] == ''
      flash[:alert] = 'Not a number.'
      redirect to '/'
    end
  end

  post '/follow' do
    unfollow = Unfollow.new.tap do |u|
      u.user               = params[:user]
      u.date               = Date.today + params[:days].to_i
      u.oauth_token        = session[:oauth_token]
      u.oauth_token_secret = session[:oauth_token_secret]
    end

    client = Twitter::Client.new(
      :oauth_token        => unfollow.oauth_token,
      :oauth_token_secret => unfollow.oauth_token_secret
    )
    client.follow unfollow.user

    if unfollow.save
      flash[:notice] = "@#{unfollow.user} will be unfollowed on #{unfollow.date.strftime("%A, %b #{unfollow.date.day.ordinalize}")}!"
    else
      flash[:alert] = 'Not saved.'
    end

    redirect to '/'
  end

  get '/auth/:provider/callback' do
    auth_hash = env['omniauth.auth'] # => OmniAuth::AuthHash

    # store oauth_token and oauth_token_secret in the session
    session[:oauth_token]        = auth_hash[:credentials][:token]
    session[:oauth_token_secret] = auth_hash[:credentials][:secret]

    # store username
    session[:username] = auth_hash[:info][:nickname]

    flash[:notice] = 'Authenticated successfully.'
    redirect to '/'
  end

  get '/auth/failure' do
    flash[:alert] = 'Authentication failed.'
    redirect to '/'
  end

  get '/signout' do
    session[:oauth_token]        = nil
    session[:oauth_token_secret] = nil

    flash[:alert] = 'Signed out successfully.'
    redirect to '/'
  end

  get '/application.css' do
    scss :application, Compass.sass_engine_options
  end

  private

  def is_numeric?(str)
    !!str.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/)
  end
end
