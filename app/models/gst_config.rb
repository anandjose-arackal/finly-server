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

class GstConfig < ApplicationRecord
  belongs_to :company
end
