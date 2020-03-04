# == Schema Information
#
# Table name: form_sections
#
#  id           :bigint           not null
#  uuid         :string(36)       not null, primary key
#  name         :string(255)      not null
#  form_id      :integer          not null
#  company_id   :integer          not null
#  active       :boolean          default(TRUE)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  section_type :string(255)
#  deleted_at   :datetime
#

require 'rails_helper'

RSpec.describe FormSection, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
