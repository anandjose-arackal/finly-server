# == Schema Information
#
# Table name: transaction_statuses
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class TransactionStatus < ActiveRecord::Base
  include Seedable

  def self.values
    [:success, :failure]
  end

end
