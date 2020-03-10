# == Schema Information
#
# Table name: forms
#
#  id         :bigint           not null
#  uuid       :string(36)       not null, primary key
#  klass_name :string(255)      not null
#  model      :string(255)      not null
#  company_id :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Form, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
