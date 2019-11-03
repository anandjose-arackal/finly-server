# == Schema Information
#
# Table name: form_dependency_types
#
#  id         :bigint           not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe FormDependencyType, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
