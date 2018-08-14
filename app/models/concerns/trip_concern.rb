require 'active_support/concern'

module TripConcern
  extend ActiveSupport::Concern

  included do
    %w(primary_action repeat schedule).each do |field|
      scope "including_all_#{field}".to_sym, -> (actions) { where(matching_action_query(actions, field,'AND')) }
      scope "including_any_#{field}".to_sym, -> (actions) { where(matching_action_query(actions, field,'OR')) }
    end
  end
  class_methods do
    def matching_action_query(actions,colum_name, condition_separator = 'OR')
      query = actions.map { |action| ["? = any(#{colum_name})", action] }
      [query.map(&:first).join(" #{condition_separator} "), *query.flat_map { |c| c[1..-1] }]
    end
  end
end