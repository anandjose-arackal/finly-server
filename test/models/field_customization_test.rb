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

require 'test_helper'

class FieldCustomizationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
