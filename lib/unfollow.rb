require 'dm-timestamps'

class Unfollow
  include DataMapper::Resource

  property :id,                 Serial
  property :user,               String, :required => true
  property :oauth_token,        String, :required => true
  property :oauth_token_secret, String, :required => true
  property :date,               Date,   :required => true

  timestamps :at
end
