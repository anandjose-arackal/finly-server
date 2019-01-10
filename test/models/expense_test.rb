# == Schema Information
#
# Table name: expenses
#
#  id                     :integer          not null, primary key
#  amount_id              :integer
#  expense_status_id      :integer
#  note                   :text(65535)
#  date                   :date
#  user_id                :integer
#  expense_type_id        :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  manager_memo           :text(65535)
#  rejecting_manager_id   :integer
#  report_id              :integer
#  category_id            :integer
#  is_deleted             :boolean          default(FALSE), not null
#  transcribed            :boolean          default(FALSE)
#  personal               :boolean          default(FALSE)
#  reimbursable           :boolean
#  synced_with_quickbooks :boolean          default(FALSE)
#  split_link             :string(255)
#  deleted_to_split       :boolean          default(FALSE)
#  from_cash_on_hand      :boolean          default(FALSE)
#  cash_on_hand_blocked   :boolean
#  expense_tax_type_id    :integer
#  gst_percentage         :decimal(10, )
#  tds_percentage         :decimal(10, )
#  tds_amount_id          :integer
#  gst_type_id            :integer
#  tds_slab_id            :integer
#  gst_amount_id          :integer
#  usage_date_start       :datetime
#  usage_date_end         :datetime
#  usage_date_type        :string(255)
#  spent_from_id          :integer
#  custom_conversion_rate :boolean          default(FALSE)
#  cost_center_id         :integer
#  created_by_id          :integer
#  modified_by_id         :integer
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
