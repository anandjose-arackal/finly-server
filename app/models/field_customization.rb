# == Schema Information
#
# Table name: field_customizations
#
#  id            :integer          not null, primary key
#  class_name    :string(255)      not null
#  field_name    :string(255)      not null
#  enabled       :boolean          default(FALSE), not null
#  presence      :boolean          default(FALSE), not null
#  show_in_pdf   :boolean          default(FALSE), not null
#  scopable_id   :integer          not null
#  scopable_type :string(255)      not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class FieldCustomization < ApplicationRecord
  belongs_to :scopable, optional: true, polymorphic: true

  validates :scopable, presence: true
  validates :class_name, presence: true
  validates :field_name, presence: true

  scope :with_scope, -> (scope) { where scopable: scope }
  scope :with_class_name, -> (class_name) { where class_name: class_name }
  scope :with_field_name, -> (field_name) { where field_name: field_name }

  def options
    {
        enabled: enabled, presence: presence, show_in_pdf: show_in_pdf
    }
  end

end
