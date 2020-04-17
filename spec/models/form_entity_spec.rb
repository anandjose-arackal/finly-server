# == Schema Information
#
# Table name: form_entities
#
#  id                           :bigint           not null
#  uuid                         :string(36)       not null, primary key
#  company_id                   :integer          not null
#  form_id                      :string(36)       not null
#  form_section_id              :string(36)       not null
#  created_by_user_id           :integer
#  field_key                    :string(255)      not null
#  label                        :string(255)
#  placeholder                  :string(255)
#  hint                         :string(255)
#  field_type                   :string(255)
#  default_value                :string(255)
#  multiple                     :boolean
#  editable                     :boolean
#  required                     :boolean
#  active                       :boolean
#  unique                       :boolean
#  visible                      :boolean
#  position                     :integer
#  custom_field                 :boolean
#  dependent                    :boolean
#  conditional_required         :boolean
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
#  chained                      :text(65535)
#  data_provider                :text(65535)
#  deleted_at                   :datetime
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  choices_provider             :text(65535)
#  internal                     :boolean          default(FALSE)
#  is_modified                  :boolean          default(FALSE)
#  field_path                   :string(255)
#  parent_id                    :string(255)
#  populate_if_empty            :string(255)
#  associate_custom_fields      :boolean          default(FALSE)
#

require 'rails_helper'

RSpec.describe FormEntity, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
