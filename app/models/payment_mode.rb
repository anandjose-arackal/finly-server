# == Schema Information
#
# Table name: payment_modes
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class PaymentMode < ActiveRecord::Base

  MODES = {cash: 1, card: 2}

  def self.id_for(item)
    MODES[item]
  end

end
