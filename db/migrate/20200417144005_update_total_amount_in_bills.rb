class UpdateTotalAmountInBills < ActiveRecord::Migration[5.2]
  def change
    total = BbpsBill.all.count
    BbpsBill.all.each_with_index do |bill, index|
      bill.save
      print "Updating Bills => #{index + 1}/#{total}\r"
    end
  end
end
