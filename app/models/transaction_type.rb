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

  def credit?
    self.id == TransactionType.id_for(:credit)
  end

  def debit?
    self.id == TransactionType.id_for(:debit)
  end

end
