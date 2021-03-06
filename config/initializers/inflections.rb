# frozen_string_literal: true

ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.uncountable %w[indieauth]
end

ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym 'IndieAuth'
  inflect.acronym 'GitHub'
  inflect.acronym 'JSON'
  inflect.acronym 'OAuth'
  inflect.acronym 'UID'
end
