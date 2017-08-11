# == Schema Information
#
# Table name: transaction_types
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class TransactionType < ActiveRecord::Base
  include Seedable

  def self.values
    [:credit, :debit]
  end

end
