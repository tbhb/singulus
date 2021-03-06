# frozen_string_literal: true

# [Micropub](https://micropub.spec.indieweb.org/) server implementation.
class MicropubController < ActionController::API
  include Doorkeeper::Helpers::Controller

  protected

  def handle_unsupported_media_type!
    return if supported_media_types.include?(request.media_type)

    error = { error: 'invalid_request', error_description: 'Unsupported media type' }
    render json: error.to_json, status: :unsupported_media_type
  end

  def doorkeeper_unauthorized_render_options(*)
    { json: { error: 'unauthorized' } }
  end
end
