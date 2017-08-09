# == Schema Information
#
# Table name: payment_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#



class PaymentType < ActiveRecord::Base
  include Seedable

  def self.values
    [:credit, :debit]
  end

end
