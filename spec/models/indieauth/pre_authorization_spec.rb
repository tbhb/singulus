# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IndieAuth::PreAuthorization, type: :model do # rubocop:disable RSpec/MultipleMemoizedHelpers
  subject(:pre_auth) do
    described_class.new(
      Doorkeeper.configuration,
      pre_auth_params,
      user
    )
  end

  let(:user) { FactoryBot.create(:user) }

  # TODO: Temporary until we have the client get upserted
  let(:client) { FactoryBot.create(:oauth_application, uid: client_id, confidential: false) }
  let(:profile_url) { 'https://example.com/profile' }
  let(:client_id) { 'https://client.net' }
  let(:redirect_uri) { 'https://client.net/auth/callback' }
  let(:response_type) { 'code' }
  let(:scope) { 'profile' }
  let(:pre_auth_params) do
    {
      client_id: client.uid,
      redirect_uri: redirect_uri,
      me: user.profile_url,
      response_type: response_type,
      scope: scope,
      state: '123456'
    }
  end

  it 'is authorizable with valid parameters' do
    expect(pre_auth).to be_authorizable
  end

  context 'when redirect_uri is on a different domain than client_id' do # rubocop:disable RSpec/MultipleMemoizedHelpers
    let(:redirect_uri) { 'https://different-domain.com/auth/callback' }

    it 'is not authorizable' do
      expect(pre_auth).not_to be_authorizable
    end
  end
end
