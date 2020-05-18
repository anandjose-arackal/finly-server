# == Schema Information
#
# Table name: form_sections
#
#  id                      :bigint           not null
#  uuid                    :string(36)       not null, primary key
#  section_id              :string(255)      not null
#  form_id                 :string(36)       not null
#  company_id              :integer          not null
#  active                  :boolean          default(TRUE)
#  deleted_at              :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  associate_custom_fields :boolean          default(FALSE)
#  title                   :string(255)
#

require 'rails_helper'

RSpec.describe FormSection, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
