# == Schema Information
#
# Table name: form_entity_choices
#
#  id                 :bigint           not null
#  uuid               :string(36)       not null, primary key
#  company_id         :integer          not null
#  form_id            :string(36)       not null
#  form_section_id    :string(36)       not null
#  form_entity_id     :string(36)       not null
#  created_by_user_id :integer
#  name               :string(255)      not null
#  position           :integer          not null
#  active             :boolean          default(TRUE)
#  deleted_at         :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'rails_helper'

RSpec.describe FormEntityChoice, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
