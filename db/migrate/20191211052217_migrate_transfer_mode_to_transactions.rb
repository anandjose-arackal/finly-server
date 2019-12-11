class MigrateTransferModeToTransactions < ActiveRecord::Migration[5.2]
  def change
  	yes_all = YesBankTransaction.where(company_id: 2).all
  	objects = []
  	puts "YesBankTransaction count - #{yes_all.count}"
  	yes_all.each do |yes|
  		print "."
  		tm = yes.company.transfer_modes.fetch_modes
  		pm = yes.transfer_type
  		yes.transfer_mode_id = tm[pm&.downcase]
  		objects << yes
  	end;nil
  	YesBankTransaction.import objects, on_duplicate_key_update: [:transfer_mode_id], validate: false

  	icici_all = IciciBankTransaction.all
  	objects = []
  	puts "IciciBankTransaction count - #{yes_all.count}"
  	icici_all.each do |icici|
  		print "."
  		tm = icici.company.transfer_modes.fetch_modes
  		pm = icici.transfer_type
  		icici.transfer_mode_id = tm[pm&.downcase]
  		objects << icici
  	end;nil
  	IciciBankTransaction.import objects, on_duplicate_key_update: [:transfer_mode_id], validate: false

  end
end
