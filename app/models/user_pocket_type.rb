# == Schema Information
#
# Table name: user_pocket_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class UserPocketType < ActiveRecord::Base

  include Seedable

  def self.values
    %w(bank_transfer card_transfer cash credit_card reimbursement paid_by_company)
  end

  def cash_pocket?
    self.id == UserPocketType.id_for(:cash)
  end

  def credit_card_pocket?
    self.id == UserPocketType.id_for(:credit_card)
  end

  def reimbursement?
    self.id == UserPocketType.id_for(:reimbursement)
  end

  def paid_by_company?
    self.id == UserPocketType.id_for(:paid_by_company)
  end

end
