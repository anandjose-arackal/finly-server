class BankTransactionModeMigration
	def self.run
  	# yes_all = YesBankTransaction.all
  	# puts "YesBankTransaction count - #{yes_all.count}"

    Company.all.each do |company|      
    	objects = []
    	YesBankTransaction.find_each do |yes|
    		print "#{yes.id}...//..."
    		tm = company.transfer_modes.fetch_modes
    		pm = yes.transfer_type
    		yes.transfer_mode_id = tm[pm&.downcase]
    		objects << yes
    	end;nil
    	YesBankTransaction.import objects, on_duplicate_key_update: [:transfer_mode_id], validate: false

    	# icici_all = IciciBankTransaction.all
    	objects = []
    	# puts "IciciBankTransaction count - #{icici_all.count}"
    	IciciBankTransaction.find_each do |icici|
    		print "#{icici.id}...//..."
    		tm = company.transfer_modes.fetch_modes
    		pm = icici.transfer_type
    		icici.transfer_mode_id = tm[pm&.downcase]
    		objects << icici
    	end;nil
    	IciciBankTransaction.import objects, on_duplicate_key_update: [:transfer_mode_id], validate: false
    end
  end
end
