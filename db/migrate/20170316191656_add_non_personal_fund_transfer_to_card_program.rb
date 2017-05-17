class AddNonPersonalFundTransferToCardProgram < ActiveRecord::Migration
  def change
    # add_column :card_programs, :non_personal_fund_transfer, :boolean
    if CardProgram.count > 0
      CardProgram.all.each do |program|
        case program.name
          when 'Expense'
            program.update_attribute(:non_personal_fund_transfer, true)
          when 'Reimbursement'
            program.update_attribute(:non_personal_fund_transfer, false)
        end
      end
    end
  end
end
