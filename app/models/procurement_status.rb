# == Schema Information
#
# Table name: procurement_statuses
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :text(65535)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class ProcurementStatus < ActiveRecord::Base
  include Seedable
  def self.values
    %w( draft )
  end

end
