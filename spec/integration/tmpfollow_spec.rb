require_relative '../spec_helper'

describe TmpFollow do
  describe 'authenticating' do
    include Capybara::DSL

    before do
      Capybara.app = TmpFollow
    end

    context 'with valid credentials' do
      before do
        OmniAuth.config.mock_auth[:twitter] = {
          credentials: {
            token: '1234',
            secret: '5678'
          }
        }
      end

      it 'signs in with twitter' do
        visit '/'
        click_link 'Authenticate with Twitter'

        page.should have_content 'Authenticated successfully.'
        page.should_not have_content 'Authenticate with Twitter'
      end
    end

    context 'with invalid credentials' do
      before do
        OmniAuth.config.mock_auth[:twitter] = :invalid_credentials
      end

      it 'returns an error from twitter' do
        visit '/'
        click_link 'Authenticate with Twitter'

        page.should have_content 'Authentication failed.'
        page.should have_content 'Authenticate with Twitter'
        page.should_not have_content 'Authenticated successfully.'
      end
    end
  end
end
