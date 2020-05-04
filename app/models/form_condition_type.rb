class FormConditionType < ApplicationRecord
  include Seedable

  set_values :read_only, :editable, :visible, :hidden, :required, :optional
end
