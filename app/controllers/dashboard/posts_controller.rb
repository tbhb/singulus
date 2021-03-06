# frozen_string_literal: true

module Dashboard
  # Manages posts.
  class PostsController < DashboardController
    before_action :find_post, only: %i[show edit update destroy]

    def index
      @posts = Post.order(published_at: :desc, created_at: :desc).page(params[:page])
    end

    def new
      @post = Post.new
      @post.photo_attachments.build
      @post.featured_photo_attachments.build
    end

    def create
      @post = Post.new(post_params)
      @post.author = current_user
      @post.published_at = Time.now.utc
      if @post.save_unique
        queue_publish(@post)
        create_link(@post)
        redirect_to dashboard_post_path(@post), notice: 'Post was successfully created'
      else
        render :new
      end
    end

    def show; end

    def edit
      @post.photo_attachments.build if @post.photos.empty?
      @post.featured_photo_attachments.build if @post.featured_photos.empty?
    end

    def update
      if @post.update(post_params)
        queue_publish(@post)
        redirect_to dashboard_post_path(@post), notice: 'Post was successfully updated'
      else
        render :edit
      end
    end

    def destroy
      @post.destroy
      HugoDeleteWorker.perform_async(@post.id, @post.hugo_source_path)
      redirect_to dashboard_posts_path
    end

    private

    def queue_publish(post)
      HugoPublishWorker.perform_async(post.id)
    end

    def create_link(post)
      post.links.create(name: post.short_uid, target_url: post.permalink_url, tags: %w[auto])
    end

    def find_post
      @post = Post.find(params[:id])
    end

    def post_params # rubocop:disable Metrics/MethodLength
      params.require(:post).permit(
        :name, :content, :slug, :summary, :category_names,
        references_attributes: [
          :citation_id, :rel,
          {
            citation_attributes: [
              :accessed_at, :author, :content, :name, :publication, :published_at, :uid, { urls: [] }
            ]
          }
        ],
        featured_photo_attachments_attributes: [{ attachable_attributes: %i[alt file] }],
        photo_attachments_attributes: [{ attachable_attributes: %i[alt file] }]
      )
    end
  end
end
