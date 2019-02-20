# == Schema Information
#
# Table name: tally_configurations
#
#  id                   :integer          not null, primary key
#  company_id           :integer          not null
#  company_name         :string(255)
#  active               :boolean
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  voucher_expense_date :string(255)
#  custom_voucher       :boolean          default(FALSE)
#  voucher_extension    :string(255)
#

class TallyConfiguration < ApplicationRecord
  belongs_to :company, optional: true

  validates :voucher_expense_date, inclusion: {in: [nil, 'approval', 'expense']}

  def date_for(expense)
    case voucher_expense_date
      when 'approval'
        date = expense.report.approved_at&.strftime('%Y%m%d')
        return date unless date.blank?
    end
    expense.date.strftime('%Y%m%d')
  end

end
