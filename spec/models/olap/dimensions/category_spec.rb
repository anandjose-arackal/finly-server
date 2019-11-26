# == Schema Information
#
# Table name: olap_dimensions_categories
#
#  id           :bigint           not null, primary key
#  finly_ref_id :bigint           not null
#  name         :string(255)
#  gl_code      :string(255)
#  active       :boolean
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'rails_helper'

RSpec.describe Olap::Dimensions::Category, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
