class SetupTransferModeAsCompanyConfiguration < ActiveRecord::Migration[5.2]
  def change
  	columns = [:company_id, :mode_id]
	values = []
	Company.all.each do |company|
	TransferMode.all.each do |tm|
	values << [company.id, tm.id]
	end
	end
	TransferModeCompanyMapping.import columns, values
  end
end
