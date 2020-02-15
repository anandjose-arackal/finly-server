# == Schema Information
#
# Table name: payment_receivable_statuses
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  uuid       :string(36)
#  deleted_at :datetime
#

class PaymentReceivableStatus < ApplicationRecord
  include Seedable

  def self.values
    [:active, :inactive, :received, :partially_received]
  end

end
