# == Schema Information
#
# Table name: expenses
#
#  id                   :integer          not null, primary key
#  amount_id            :integer
#  expense_status_id    :integer
#  note                 :text(65535)
#  date                 :date
#  user_id              :integer
#  expense_type_id      :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  manager_memo         :text(65535)
#  rejecting_manager_id :integer
#  report_id            :integer
#  category_id          :integer
#  is_deleted           :boolean          default(FALSE), not null
#  transcribed          :boolean          default(FALSE)
#  personal             :boolean          default(FALSE)
#

require 'test_helper'

class ExpenseTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  def setup
    # creating a bunch of different types of expenses to check the validations
  end
end
