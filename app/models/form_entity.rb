# == Schema Information
#
# Table name: form_entities
#
#  id                           :bigint           not null
#  company_id                   :integer          not null
#  form_id                      :integer          not null
#  form_section_id              :integer          not null
#  created_by_user_id           :integer
#  parent_id                    :integer
#  field_key                    :string(255)      not null
#  label                        :string(255)
#  placeholder                  :boolean
#  hint                         :boolean
#  field_type                   :boolean
#  default_value                :boolean
#  editable                     :boolean
#  required                     :boolean
#  active                       :boolean
#  unique                       :boolean
#  visible                      :boolean
#  position                     :boolean
#  custom_field                 :boolean
#  dependent                    :boolean
#  conditional_requiredg        :boolean
#  can_visible_be_changed       :boolean
#  can_editable_be_changed      :boolean
#  can_required_be_changed      :boolean
#  can_uniqueness_be_changed    :boolean
#  can_be_disabled              :boolean
#  can_label_be_renamed         :boolean
#  can_not_be_hidden            :boolean
#  can_be_filtered              :boolean
#  can_choices_be_changed       :boolean
#  show_in_bulk_import          :boolean
#  allow_sort_in_filter         :boolean
#  allow_clearing_default_value :boolean
#  options                      :text(65535)
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#

class FormEntity < ApplicationRecord
  include SoftDeletable, UUIDHelper

  belongs_to :company
  belongs_to :form_section
  belongs_to :form
  belongs_to :parent, class_name: 'FormEntity', optional: true

  has_many :choices, class_name: 'FormEntityChoice', dependent: :destroy

  accepts_nested_attributes_for :choices

  serialize :options, JSON
  serialize :chained, JSON
  serialize :data_provider, JSON
end
