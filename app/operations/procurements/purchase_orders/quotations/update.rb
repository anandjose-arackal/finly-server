class Procurements::PurchaseOrders::Quotations::Update < Procurements::PurchaseOrders::Quotations::Base
	attr_accessor :quotation_params, :purchase_order, :quotation

	def init
		self.quotation_params = quotation_parameters
		po_id = quotation_params[:purchase_order_id]
		self.purchase_order = user.company.purchase_orders.find_by id: po_id
		self.quotation = self.purchase_order.quotations.find_by(id: self.quotation_params[:id])
	end

	def validate
		if self.purchase_order.blank?
			add_message :error, "Purchase Order not found."
			return
		end

		if self.quotation_params.blank?
			add_message :error, "No quotations parameters sent."
			return
		end

		if self.quotation.blank?
			add_message :error, "No quotations found."
			return
		end	

		unless self.purchase_order.open? || self.purchase_order.retracted?
	      add_message :error, "Quotations can not be updated if Purchase Order is submitted."
	      return
	    end
	
	end

	def process

		quotation.assign_attributes(self.quotation_params)
		if quotation.valid?
			quotation.save
			other_quotations = self.purchase_order.quotations.where.not(id: quotation.id)
      		other_quotations.update_all(selected: false)
		else
			add_message :error, quotation.errors.full_messages
      		return
		end

	end

	def post_process
		add_message :sucess, "Quotation successfully updated."
	end

end
