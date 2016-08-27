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

  validates :name, presence: true

  # delegated from expense model
  def expense_status
    self.name
  end

  def self.unreported_id
    1
  end

  def self.unsubmitted_id
    2
  end

  def self.submitted_id
    3
  end

  def self.rejected_id
    4
  end

end
