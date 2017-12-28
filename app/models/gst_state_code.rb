# == Schema Information
#
# Table name: gst_state_codes
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  state_code :string(255)
#

class GstStateCode < ActiveRecord::Base


end
