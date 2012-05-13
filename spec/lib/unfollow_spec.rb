require_relative '../spec_helper'

describe Unfollow do
  describe 'validations' do
    it 'validates presence of user, oauth_token, oauth_token_secret and date' do
      unfollow = Unfollow.new
      unfollow.valid?

      unfollow.errors.each do |error|
        error.first.should =~ /not be blank/
      end
    end
  end
end
