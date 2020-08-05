# frozen_string_literal: true

# == Schema Information
#
# Table name: posts
#
#  id           :uuid             not null, primary key
#  categories   :text             default([]), is an Array
#  content      :text
#  name         :text
#  properties   :jsonb            not null
#  published_at :datetime
#  short_uid    :text
#  slug         :text
#  summary      :text
#  url          :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  author_id    :uuid             not null
#
# Indexes
#
#  index_posts_on_author_id     (author_id)
#  index_posts_on_categories    (categories) USING gin
#  index_posts_on_properties    (properties) USING gin
#  index_posts_on_published_at  (published_at)
#  index_posts_on_short_uid     (short_uid) UNIQUE
#  index_posts_on_slug          (slug) UNIQUE
#  index_posts_on_url           (url)
#
# Foreign Keys
#
#  fk_rails_...  (author_id => users.id)
#
FactoryBot.define do
  factory :post do
    trait :published do
      published_at { Faker::Date.backward(days: 365) }
    end

    factory :article do
      content { Faker::Lorem.paragraphs.join("\n\n") }
      summary { Faker::Lorem.paragraph }
      name { Faker::Lorem.sentence }
    end

    factory :note do
      content { Faker::Lorem.paragraph_by_chars(number: 250) }
    end
  end
end
