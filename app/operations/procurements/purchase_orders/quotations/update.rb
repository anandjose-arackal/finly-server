# This operation updates an existing quotation for a purchase order

class Procurements::PurchaseOrders::Quotations::Update < Procurements::PurchaseOrders::Quotations::Base
	attr_accessor :quotation_params, :purchase_order, :quotation, :q_current_attachments, :q_old_attachments

	def pre_validate
	    if params[:purchase_order_id].blank?
	      add_message :error, "Purchase Order ID not sent."
	      return
	    end

	    if params[:id].blank?
	      add_message :error, "Quotation ID not sent."
	      return
	    end

	    if params[:quotation].blank?
	      add_message :error, "Please supply quotation parameters."
	      return
	    end
	end

	def init
		self.quotation_params = quotation_parameters
		# po_id = quotation_params[:purchase_order_id]
		po_id = params[:purchase_order_id]
		self.purchase_order = user.company.purchase_orders.find_by id: po_id
		self.quotation = self.purchase_order.quotations.find_by(id: params[:id])
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

		if self.quotation_params[:selected].blank?
	      add_message :error, "Please select, \"Yes\" or \"No\", whether or not if you are moving forward with this Quotation."
	      return
	    end

		if StringUtils.to_bool(self.quotation_params[:selected].strip)
	      if self.quotation_params[:note].blank? || (self.quotation_params[:note].length < 5)
	        add_message :error, "Please supply a note as to why you are moving forward with this Quotation (Min 5 characters)."
	        return
	      end
	    end

		unless self.purchase_order.open? || self.purchase_order.retracted? || self.purchase_order.rejected?
	      add_message :error, "Quotations cannot be updated if Purchase Order is submitted."
	      return
	    end

	    if self.quotation_params[:total_amount].blank?
	      add_message :error, "Please enter the total amount for this Quotation."
	      return
	    end

	    unless validate_amount(self.quotation_params[:total_amount])
	      add_message :error, "Invalid amount entered."
	      return
	    end 

	    if self.quotation_params[:advance_amount].present?
	      unless validate_amount(self.quotation_params[:advance_amount])
	        add_message :error, "Invalid advance amount entered."
	        return
	      end
	    end
	
	end

	def pre_process
	    self.q_current_attachments = user.company.procurement_attachments.with_id(params[:quotation][:attachments])

	    self.quotation_params.delete(:attachments)

	    #old attachments
	    self.q_old_attachments = self.quotation.attachments
	end

	def process
		self.quotation_params[:purchase_order_id] = self.purchase_order.id

		self.quotation_params[:selected] = StringUtils.to_bool(self.quotation_params[:selected].strip)

		quotation.assign_attributes(self.quotation_params)
		if quotation.valid?
			quotation.save
			if quotation.selected
				other_quotations = self.purchase_order.quotations.where.not(id: quotation.id)
      			other_quotations.update_all(selected: false)
      		end

      		self.q_old_attachments&.update_all(procurement_document_id: nil, procurement_document_type: nil)

    		self.q_current_attachments&.update_all(procurement_document_id: self.quotation.id, procurement_document_type: self.quotation.class.name)

		else
			add_message :error, quotation.errors.full_messages
      		return
		end

	end

	def post_process
		add_message :success, "Quotation successfully updated."
	end

	private

	def validate_amount(amount)
	    if amount.blank? || (!/\A\d+\.\d+\z/.match(amount) && !/\A\d+\z/.match(amount)) # check if blank or not a positive float or not a positive integer
	      return false
	    end
	    true
	end

end



