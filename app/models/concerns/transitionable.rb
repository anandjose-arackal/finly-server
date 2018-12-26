module Transitionable
  extend ActiveSupport::Concern

  included do
    belongs_to :policy
    belongs_to :level, class_name: 'ReviewalLevel', foreign_key: :controlling_level_id

    has_many :document_level_reviewer_mappings, as: :document_reviewer_mappable
    has_many :trails, as: :parent
  end
end