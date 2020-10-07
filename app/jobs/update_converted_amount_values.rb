# this class updates the amounts table with the converted values for all currencies - primarily for expenses created
# on the previous day (for which conversion rates are not yet retrieved)

class UpdateConvertedAmountValues < BaseJob

  def self.perform_job
    puts " ----------------------------- PERFORMING #{self.name} at #{Time.now.strftime("%d-%B-%Y %H:%M:%S")}------------------------------"

    Expense.all.where(date: DateUtils.yesterday_local_date).each do |expense|
      expense.update_other_currencies
    end

    puts " ----------------------------- FINISHED #{self.name}  at #{Time.now.strftime("%d-%B-%Y %H:%M:%S")}------------------------------"
  end

end