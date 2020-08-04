# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/', type: :request do
  describe 'GET /' do
    it 'returns HTTP success' do
      get '/'
      expect(response).to have_http_status(:success)
    end
  end
end
