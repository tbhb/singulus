# frozen_string_literal: true

# Represents a user who can log in to Singulus.
#
# ## Schema Information
#
# Table name: `users`
#
# ### Columns
#
# Name                       | Type               | Attributes
# -------------------------- | ------------------ | ---------------------------
# **`id`**                   | `uuid`             | `not null, primary key`
# **`current_sign_in_at`**   | `datetime`         |
# **`current_sign_in_ip`**   | `inet`             |
# **`email`**                | `string`           | `default(""), not null`
# **`encrypted_password`**   | `string`           | `default(""), not null`
# **`failed_attempts`**      | `integer`          | `default(0), not null`
# **`last_sign_in_at`**      | `datetime`         |
# **`last_sign_in_ip`**      | `inet`             |
# **`locked_at`**            | `datetime`         |
# **`name`**                 | `string`           | `default(""), not null`
# **`profile_url`**          | `text`             |
# **`remember_created_at`**  | `datetime`         |
# **`sign_in_count`**        | `integer`          | `default(0), not null`
# **`twitter_username`**     | `text`             |
# **`unlock_token`**         | `string`           |
# **`created_at`**           | `datetime`         | `not null`
# **`updated_at`**           | `datetime`         | `not null`
# **`twitter_user_id`**      | `text`             |
#
# ### Indexes
#
# * `index_users_on_email` (_unique_):
#     * **`email`**
# * `index_users_on_profile_url`:
#     * **`profile_url`**
# * `index_users_on_unlock_token` (_unique_):
#     * **`unlock_token`**
#
class User < ApplicationRecord
  devise :database_authenticatable, :lockable,
         :rememberable, :trackable, :validatable

  has_many :photo_attachments, -> { where(rel: 'photo') },
           class_name: 'Attachment', as: :attacher, inverse_of: :attacher, dependent: :destroy
  has_many :photos, through: :photo_attachments, source: :attachable, source_type: 'Photo'
  accepts_nested_attributes_for :photo_attachments, allow_destroy: true

  has_many :access_grants,
           inverse_of: :user,
           class_name: 'Auth::AccessGrant',
           foreign_key: :resource_owner_id,
           dependent: :delete_all

  has_many :access_tokens,
           inverse_of: :user,
           class_name: 'Auth::AccessToken',
           foreign_key: :resource_owner_id,
           dependent: :delete_all

  has_many :posts, foreign_key: :author_id, inverse_of: :author, dependent: :destroy

  def photo
    photos.first
  end

  def photo_url
    photo&.file_url
  end

  def open_graph_photo_url
    photo&.open_graph_url
  end

  def twitter_card_photo_url
    photo&.twitter_card_url
  end

  def to_indieauth_json
    as_indieauth_json.to_json
  end

  def as_indieauth_json
    {
      me: profile_url,
      profile: {
        type: 'card',
        name: name,
        url: profile_url,
        photo: photo_url
      }
    }
  end
end
