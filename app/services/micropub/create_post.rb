# frozen_string_literal: true

module Micropub
  # Base class for post creation.
  class CreatePost
    ALLOWED_PROPERTIES = %i[
      category
      content
      name
      photo
      summary
      bookmark_of
      in_reply_to
      like_of
      location
      repost_of
      rsvp
      syndications
    ].freeze

    def call(params)
      @author_id = params.delete(:author_id)
    end

    protected

    attr_reader :author_id

    def create_post(attrs)
      post = Post.new(attrs)
      post.author_id = author_id
      post.published_at = Time.now.utc
      HugoPublishWorker.perform_async(post.id) if post.save_unique
      post
    end

    def existing_asset?(url)
      url.start_with?(uploads_url)
    end

    def associate_existing_photo(url, alt)
      photo = find_photo_by_filename(file_id(url))
      return unless photo

      Photo.update(alt: alt) if alt
      { attachable_id: photo.id }
    end

    def file_id(url)
      Pathname.new(URI(url).path.delete_prefix(URI(uploads_url).path)).basename.to_s
    end

    def find_photo_by_filename(filename)
      Photo.where('file_data @> ?', { id: filename }.to_json).first
    end

    def uploads_url
      @uploads_url ||= Rails.configuration.x.uploads.url
    end
  end
end
