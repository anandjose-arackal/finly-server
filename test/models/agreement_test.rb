# == Schema Information
#
# Table name: agreements
#
#  id                :integer          not null, primary key
#  agreement_type_id :integer          not null
#  file_file_name    :string(255)      not null
#  file_content_type :string(255)      not null
#  file_file_size    :integer          not null
#  file_updated_at   :datetime         not null
#  version           :string(255)      not null
#  active            :boolean          default(FALSE), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  url               :string(255)
#

require 'test_helper'

class AgreementTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
