# == Schema Information
#
# Table name: gst_configs
#
#  id         :bigint           not null, primary key
#  gst        :boolean
#  tds        :boolean
#  company_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe GstConfig, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
