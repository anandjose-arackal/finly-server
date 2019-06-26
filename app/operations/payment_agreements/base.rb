class PaymentAgreements::Base < BaseOperation

  attr_accessor :company, :workflow_output, :payment_agreement


  def pre_validate
    if user.blank? || params.blank?
      add_message :error, 'Invalid parameters, try again'
      return
    end
  end

  def payment_agreement_parameters
    params.require(:payment_agreement).permit(

      :id, :title, :policy_id, :agreement_date, :execution_date, :expiration_date, :renewal_date, :note, :no_expiration, :renewal_reminder_date , :reject_note, 

      general_invoices_attributes: [:id, :_destroy, :department_id, :location_id, :cost_center_id, :payment_term_id, :auto_pay, :billing_type_id, :bank_account_id, :note, :invoice_status_id, :discount_type_id, :tds_slab_id, :roundoff_amount, :vendor_id, :vendor_location_id,

        invoice_items_attributes: [
            :quantity, :unit_of_measurement, :department_id,
            :cost_center_id, :rate, :tax, :tax_rate_id, :discount,
            :category_id, :description, :id, :remove_line_item,
            :hsn_sac, :comment, :_destroy, :inventory_line_item_id, :tds_applicable,
            discount_amount_attributes: [:id, :currency_id, :value],
            tax_amount_attributes: [:id, :currency_id, :value],
            total_amount_attributes: [:id, :value, :currency_id],
            raw_amount_attributes: [:id, :value, :currency_id]
          ],
        discount_amount_attributes: [:id, :currency_id, :value],
        freight_amount_attributes: [:id, :currency_id, :value],
        tds_amount_attributes: [:id, :currency_id, :value],
        total_after_tax_attributes: [:id, :currency_id, :value],
        advance_amount_attributes: [:id, :currency_id, :value],
        balance_amount_attributes: [:id, :currency_id, :value],
        extra_charges_attributes: [:id, :currency_id, :value],
        notify_users_attributes: [:id, :_destroy, :user_id]
      ],
      rental_invoices_attributes: [:id, :_destroy, :department_id, :bank_account_id, :location_id, :cost_center_id, :payment_term_id, :auto_pay, :billing_type_id, :note, :invoice_status_id, :tds_slab_id, :discount_type_id, :roundoff_amount,

        invoice_items_attributes: [
            :quantity, :unit_of_measurement, :department_id,
            :cost_center_id, :rate, :tax, :tax_rate_id, :discount,
            :category_id, :description, :id, :remove_line_item,
            :hsn_sac, :comment, :_destroy, :inventory_line_item_id, :tds_applicable,
            discount_amount_attributes: [:id, :currency_id, :value], 
            tax_amount_attributes: [:id, :currency_id, :value],
            raw_amount_attributes: [:id, :value, :currency_id]
          ],
        discount_amount_attributes: [:id, :currency_id, :value],
        freight_amount_attributes: [:id, :currency_id, :value],
        tds_amount_attributes: [:id, :currency_id, :value],
        total_after_tax_attributes: [:id, :currency_id, :value],
        advance_amount_attributes: [:id, :currency_id, :value],
        balance_amount_attributes: [:id, :currency_id, :value],
        extra_charges_attributes: [:id, :currency_id, :value],
        notify_users_attributes: [:id, :_destroy, :user_id]
      ],
      beneficiary_payments_attributes: [:id, :_destroy, :vendor_id, :bank_account_id, :cost_center_id, :department_id, :location_id, :note, :vendor_location_id, :tax, :inclusive_of_taxes, :gst_type_id, :tds_slab_id, :renewal_date, :tax_rate_id, 
        tax_amount_attributes: [:id, :value, :currency_id],
        payable_amount_attributes: [:id, :currency_id, :value],
        original_amount_attributes: [:id, :currency_id, :value]

      ],
      security_deposits_attributes: [:id, :_destroy, :vendor_id, :note, :cost_center_id, :department_id, :location_id, :vendor_location_id, :bank_account_id, 
        original_amount_attributes: [:id, :currency_id, :value]
      ]
      
      )
  end

end