# frozen_string_literal: true

unless ENV['WEBPACK_COMPILE_ONLY']
  require 'shrine/storage/s3'

  case Rails.env
  when 'development', 'test'
    s3_options = {
      access_key_id: ENV['MINIO_ACCESS_KEY'],
      secret_access_key: ENV['MINIO_SECRET_KEY'],
      endpoint: 'http://localhost:9000',
      region: 'us-east-1',
      force_path_style: true,
      public: true,
      bucket: "singulus-#{Rails.env}"
    }
  when 'production'
    s3_options = { bucket: ENV['UPLOADS_BUCKET'] }
  end

  default_url_options = {
    host: Rails.configuration.x.uploads.url,
    public: true
  }
  url_options = {
    store: default_url_options,
    photo: default_url_options,
    video: default_url_options,
    audio: default_url_options
  }

  Shrine.logger = Rails.logger
  Shrine.logger.level = Logger::WARN if Rails.env.test?

  Shrine.storages = {
    cache: Shrine::Storage::S3.new(prefix: 'cache', **s3_options),
    store: Shrine::Storage::S3.new(**s3_options),

    photo: Shrine::Storage::S3.new(prefix: 'photo', **s3_options),
    video: Shrine::Storage::S3.new(prefix: 'video', **s3_options),
    audio: Shrine::Storage::S3.new(prefix: 'sound', **s3_options)
  }

  Shrine.plugin(:instrumentation, notifications: ActiveSupport::Notifications)
  Shrine.plugin(:activerecord)
  Shrine.plugin(:url_options, **url_options)
end
