require_relative '../spec_helper'

describe TmpFollow do
  describe 'authenticating' do
    include Capybara::DSL

    before do
      Capybara.app = TmpFollow
    end

    it 'signs in with twitter', :type => :request do
      visit '/'
      click_link 'Authenticate with Twitter'

      page.should have_content 'Authenticated successfully.'
      page.should_not have_content 'Authenticate with Twitter'
    end

    it 'returns an error from twitter' do
      OmniAuth.config.mock_auth[:twitter] = :invalid_login

      visit '/'
      click_link 'Authenticate with Twitter'

      page.should have_content 'Authentication failed.'
      page.should have_content 'Authenticate with Twitter'
      page.should_not have_content 'Authenticated successfully.'
    end
  end
end
