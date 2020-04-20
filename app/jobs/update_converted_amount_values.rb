# this class updates the amounts table with the converted values for all currencies - primarily for expenses created
# on the previous day (for which conversion rates are not yet retrieved)

class UpdateConvertedAmountValues

  def self.perform
    puts " ----------------------------- PERFORMING #{self.name} ------------------------------"

    Expense.all.where(date: DateUtils.yesterday_local_date).each do |expense|
      expense.update_other_currencies
    end

    puts " ----------------------------- FINISHED #{self.name} ------------------------------"
  end

end