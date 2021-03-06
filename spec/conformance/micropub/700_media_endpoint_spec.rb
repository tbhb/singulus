# frozen_string_literal: true

require 'rails_helper'
require_relative '../../support/contexts/micropub'

RSpec.describe 'Micropub Server Implementation Report - Media Endpoint', type: :request do
  include_context 'when authenticated as a valid Micropub client'

  before { post '/micropub/media', params: params, headers: headers }

  # https://micropub.rocks/server-tests/700?endpoint=501
  describe '700 - Upload a jpg to the Media Endpoint' do
    let(:photo) { fixture_file_upload(Rails.root.join('spec/fixtures/photos/sunset.jpg'), 'image/jpeg') }
    let(:params) { { file: photo } }
    let(:new_photo) { Photo.where('file_data @> ?', { metadata: { filename: 'sunset.jpg' } }.to_json).first }

    it 'returns HTTP created' do
      expect(response).to have_http_status(:created)
    end

    it 'returns a Location header with the URL of the new photo' do
      expect(response.headers['Location']).to eq(new_photo.file_url)
    end

    it 'creates an orphan photo' do
      expect(new_photo).not_to be_nil
    end

    it 'sets the mime type for the photo' do
      expect(new_photo.mime_type).to eq('image/jpeg')
    end
  end

  # https://micropub.rocks/server-tests/701?endpoint=501
  describe '701 - Upload a png to the Media Endpoint' do
    let(:photo) { fixture_file_upload(Rails.root.join('spec/fixtures/photos/micropub-rocks.png'), 'image/png') }
    let(:params) { { file: photo } }
    let(:new_photo) { Photo.where('file_data @> ?', { metadata: { filename: 'micropub-rocks.png' } }.to_json).first }

    it 'returns HTTP created' do
      expect(response).to have_http_status(:created)
    end

    it 'returns a Location header with the URL of the new photo' do
      expect(response.headers['Location']).to eq(new_photo.file_url)
    end

    it 'creates an orphan photo' do
      expect(new_photo).not_to be_nil
    end

    it 'sets the mime type for the photo' do
      expect(new_photo.mime_type).to eq('image/png')
    end
  end

  # https://micropub.rocks/server-tests/702?endpoint=501
  describe '702 - Upload a gif to the Media Endpoint' do
    let(:photo) { fixture_file_upload(Rails.root.join('spec/fixtures/photos/w3c-socialwg.gif'), 'image/gif') }
    let(:params) { { file: photo } }
    let(:new_photo) { Photo.where('file_data @> ?', { metadata: { filename: 'w3c-socialwg.gif' } }.to_json).first }

    it 'returns HTTP created' do
      expect(response).to have_http_status(:created)
    end

    it 'returns a Location header with the URL of the new photo' do
      expect(response.headers['Location']).to eq(new_photo.file_url)
    end

    it 'creates an orphan photo' do
      expect(new_photo).not_to be_nil
    end

    it 'sets the mime type for the photo' do
      expect(new_photo.mime_type).to eq('image/gif')
    end
  end
end
