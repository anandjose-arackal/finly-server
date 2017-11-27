# == Schema Information
#
# Table name: tally_configurations
#
#  id           :integer          not null, primary key
#  company_id   :integer          not null
#  company_name :string(255)
#  active       :boolean
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class TallyConfiguration < ActiveRecord::Base
  belongs_to :company
end
