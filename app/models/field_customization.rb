class FieldCustomization < ActiveRecord::Base
  belongs_to :scopable, polymorphic: true

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
