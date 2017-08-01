# == Schema Information
#
# Table name: bank_transfer_statuses
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class BankTransferStatus < ActiveRecord::Base

  include Seedable

  def self.values
    [:completed, :processing, :failed]
  end

end
