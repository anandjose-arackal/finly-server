class BprTransferModeMigration
	def self.run
  	# migrate parent_type from payments to bpr
		# bank_payment_requests = BankPaymentRequest.where(company_id: 2).all
		# bank_payment_requests = BankPaymentRequest.all
		# puts "Ticket count - #{bank_payment_requests.count}"
		Company.all.each do |company|			
			BankPaymentRequest.find_each do |bpr|
				puts "#{bpr.id}."
				parent_type = bpr.payment_order.payments.first.parent_type rescue nil
				bpr.ticket_type = parent_type&.underscore if ['purchase_order', 'invoice', 'beneficiary_payment'].include?(parent_type&.underscore)

				tm = company.transfer_modes.fetch_modes
				pm = bpr.payment_mode
				bpr.transfer_mode_id = tm[pm&.downcase]
				bpr.payment_order.transfer_mode_id = tm[pm&.downcase]
				bpr.payment_order.payments.update_all(transfer_mode_id: tm[pm&.downcase])
				puts bpr.save!
				puts
			end;nil
		end
	end
end