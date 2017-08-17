# == Schema Information
#
# Table name: expense_statuses
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  order      :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#



class ExpenseStatus < ActiveRecord::Base
  include Seedable

  validates :name, presence: true

  def self.values
    [:unreported, :unsubmitted, :rejected, :submitted, :verified]
  end

  # delegated from expense model
  def expense_status_name
    self.name
  end

  def self.unreported_id
    self.id_for(:unreported)
  end

  def self.unsubmitted_id
    self.id_for(:unsubmitted)
  end

  def self.submitted_id
    self.id_for(:submitted)
  end

  def self.rejected_id
    self.id_for(:rejected)
  end

  def self.verified_id
    self.id_for(:verified)
  end

end
