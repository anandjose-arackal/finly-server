class FieldParentMapping < ActiveRecord::Base
  belongs_to :field_configuration
  belongs_to :field_parent_type
end
