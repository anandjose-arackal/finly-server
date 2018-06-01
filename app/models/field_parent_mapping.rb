class FieldParentMapping < ActiveRecord::Base
  belongs_to :field_configuration
  belongs_to :field_parent_type

  scope :pluck_field_parent_type_id, -> { pluck :field_parent_type_id }

  validates :field_parent_type_id, presence: true
  # validates :field_configuration, presence: true

end
