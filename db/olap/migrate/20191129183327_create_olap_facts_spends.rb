class CreateOlapFactsSpends < ActiveRecord::Migration[5.2]
  def change
    create_table :amounts do
      t.olap_references

      t.decimal :value, precision: 64, scale: 12, index: true
      t.string :currency, index: true
      t.decimal :INR, precision: 20, scale: 5, index: true
      t.decimal :USD, precision: 20, scale: 5, index: true
      t.decimal :GBP, precision: 20, scale: 5, index: true
      t.decimal :CAD, precision: 20, scale: 5, index: true
      t.decimal :EUR, precision: 20, scale: 5, index: true
      t.decimal :HRK, precision: 20, scale: 5, index: true
      t.decimal :RUB, precision: 20, scale: 5, index: true
      t.decimal :BGN, precision: 20, scale: 5, index: true
      t.decimal :BRL, precision: 20, scale: 5, index: true
      t.decimal :CHF, precision: 20, scale: 5, index: true
      t.decimal :CNY, precision: 20, scale: 5, index: true
      t.decimal :CZK, precision: 20, scale: 5, index: true
      t.decimal :DKK, precision: 20, scale: 5, index: true
      t.decimal :HKD, precision: 20, scale: 5, index: true
      t.decimal :HUF, precision: 20, scale: 5, index: true
      t.decimal :IDR, precision: 20, scale: 5, index: true
      t.decimal :ILS, precision: 20, scale: 5, index: true
      t.decimal :JPY, precision: 20, scale: 5, index: true
      t.decimal :KRW, precision: 20, scale: 5, index: true
      t.decimal :MXN, precision: 20, scale: 5, index: true
      t.decimal :NOK, precision: 20, scale: 5, index: true
      t.decimal :NZD, precision: 20, scale: 5, index: true
      t.decimal :PHP, precision: 20, scale: 5, index: true
      t.decimal :PLN, precision: 20, scale: 5, index: true
      t.decimal :RON, precision: 20, scale: 5, index: true
      t.decimal :SEK, precision: 20, scale: 5, index: true
      t.decimal :SGD, precision: 20, scale: 5, index: true
      t.decimal :THB, precision: 20, scale: 5, index: true
      t.decimal :TRY, precision: 20, scale: 5, index: true
      t.decimal :ZAR, precision: 20, scale: 5, index: true
      t.decimal :AUD, precision: 20, scale: 5, index: true
      t.decimal :AED, precision: 20, scale: 5, index: true
      t.decimal :AFN, precision: 20, scale: 5, index: true
      t.decimal :ALL, precision: 20, scale: 5, index: true
      t.decimal :AMD, precision: 20, scale: 5, index: true
      t.decimal :ANG, precision: 20, scale: 5, index: true
      t.decimal :AOA, precision: 20, scale: 5, index: true
      t.decimal :ARS, precision: 20, scale: 5, index: true
      t.decimal :AWG, precision: 20, scale: 5, index: true
      t.decimal :AZN, precision: 20, scale: 5, index: true
      t.decimal :BAM, precision: 20, scale: 5, index: true
      t.decimal :BBD, precision: 20, scale: 5, index: true
      t.decimal :BDT, precision: 20, scale: 5, index: true
      t.decimal :BHD, precision: 20, scale: 5, index: true
      t.decimal :BIF, precision: 20, scale: 5, index: true
      t.decimal :BMD, precision: 20, scale: 5, index: true
      t.decimal :BND, precision: 20, scale: 5, index: true
      t.decimal :BOB, precision: 20, scale: 5, index: true
      t.decimal :BSD, precision: 20, scale: 5, index: true
      t.decimal :BTC, precision: 20, scale: 5, index: true
      t.decimal :BTN, precision: 20, scale: 5, index: true
      t.decimal :BWP, precision: 20, scale: 5, index: true
      t.decimal :BYN, precision: 20, scale: 5, index: true
      t.decimal :BYR, precision: 20, scale: 5, index: true
      t.decimal :BZD, precision: 20, scale: 5, index: true
      t.decimal :CDF, precision: 20, scale: 5, index: true
      t.decimal :CLF, precision: 20, scale: 5, index: true
      t.decimal :CLP, precision: 20, scale: 5, index: true
      t.decimal :COP, precision: 20, scale: 5, index: true
      t.decimal :CRC, precision: 20, scale: 5, index: true
      t.decimal :CUC, precision: 20, scale: 5, index: true
      t.decimal :CUP, precision: 20, scale: 5, index: true
      t.decimal :CVE, precision: 20, scale: 5, index: true
      t.decimal :DJF, precision: 20, scale: 5, index: true
      t.decimal :DOP, precision: 20, scale: 5, index: true
      t.decimal :DZD, precision: 20, scale: 5, index: true
      t.decimal :EEK, precision: 20, scale: 5, index: true
      t.decimal :EGP, precision: 20, scale: 5, index: true
      t.decimal :ERN, precision: 20, scale: 5, index: true
      t.decimal :ETB, precision: 20, scale: 5, index: true
      t.decimal :FJD, precision: 20, scale: 5, index: true
      t.decimal :FKP, precision: 20, scale: 5, index: true
      t.decimal :GEL, precision: 20, scale: 5, index: true
      t.decimal :GGP, precision: 20, scale: 5, index: true
      t.decimal :GHS, precision: 20, scale: 5, index: true
      t.decimal :GIP, precision: 20, scale: 5, index: true
      t.decimal :GMD, precision: 20, scale: 5, index: true
      t.decimal :GNF, precision: 20, scale: 5, index: true
      t.decimal :GTQ, precision: 20, scale: 5, index: true
      t.decimal :GYD, precision: 20, scale: 5, index: true
      t.decimal :HNL, precision: 20, scale: 5, index: true
      t.decimal :HTG, precision: 20, scale: 5, index: true
      t.decimal :IMP, precision: 20, scale: 5, index: true
      t.decimal :IQD, precision: 20, scale: 5, index: true
      t.decimal :IRR, precision: 20, scale: 5, index: true
      t.decimal :ISK, precision: 20, scale: 5, index: true
      t.decimal :JEP, precision: 20, scale: 5, index: true
      t.decimal :JMD, precision: 20, scale: 5, index: true
      t.decimal :JOD, precision: 20, scale: 5, index: true
      t.decimal :KES, precision: 20, scale: 5, index: true
      t.decimal :KGS, precision: 20, scale: 5, index: true
      t.decimal :KHR, precision: 20, scale: 5, index: true
      t.decimal :KMF, precision: 20, scale: 5, index: true
      t.decimal :KPW, precision: 20, scale: 5, index: true
      t.decimal :KWD, precision: 20, scale: 5, index: true
      t.decimal :KYD, precision: 20, scale: 5, index: true
      t.decimal :KZT, precision: 20, scale: 5, index: true
      t.decimal :LAK, precision: 20, scale: 5, index: true
      t.decimal :LBP, precision: 20, scale: 5, index: true
      t.decimal :LKR, precision: 20, scale: 5, index: true
      t.decimal :LRD, precision: 20, scale: 5, index: true
      t.decimal :LSL, precision: 20, scale: 5, index: true
      t.decimal :LTL, precision: 20, scale: 5, index: true
      t.decimal :LVL, precision: 20, scale: 5, index: true
      t.decimal :LYD, precision: 20, scale: 5, index: true
      t.decimal :MAD, precision: 20, scale: 5, index: true
      t.decimal :MDL, precision: 20, scale: 5, index: true
      t.decimal :MGA, precision: 20, scale: 5, index: true
      t.decimal :MKD, precision: 20, scale: 5, index: true
      t.decimal :MMK, precision: 20, scale: 5, index: true
      t.decimal :MNT, precision: 20, scale: 5, index: true
      t.decimal :MOP, precision: 20, scale: 5, index: true
      t.decimal :MRO, precision: 20, scale: 5, index: true
      t.decimal :MUR, precision: 20, scale: 5, index: true
      t.decimal :MVR, precision: 20, scale: 5, index: true
      t.decimal :MWK, precision: 20, scale: 5, index: true
      t.decimal :MZN, precision: 20, scale: 5, index: true
      t.decimal :NAD, precision: 20, scale: 5, index: true
      t.decimal :NGN, precision: 20, scale: 5, index: true
      t.decimal :NIO, precision: 20, scale: 5, index: true
      t.decimal :NPR, precision: 20, scale: 5, index: true
      t.decimal :OMR, precision: 20, scale: 5, index: true
      t.decimal :PAB, precision: 20, scale: 5, index: true
      t.decimal :PEN, precision: 20, scale: 5, index: true
      t.decimal :PGK, precision: 20, scale: 5, index: true
      t.decimal :PKR, precision: 20, scale: 5, index: true
      t.decimal :PYG, precision: 20, scale: 5, index: true
      t.decimal :QAR, precision: 20, scale: 5, index: true
      t.decimal :RSD, precision: 20, scale: 5, index: true
      t.decimal :RWF, precision: 20, scale: 5, index: true
      t.decimal :SAR, precision: 20, scale: 5, index: true
      t.decimal :SBD, precision: 20, scale: 5, index: true
      t.decimal :SCR, precision: 20, scale: 5, index: true
      t.decimal :SDG, precision: 20, scale: 5, index: true
      t.decimal :SHP, precision: 20, scale: 5, index: true
      t.decimal :SLL, precision: 20, scale: 5, index: true
      t.decimal :SOS, precision: 20, scale: 5, index: true
      t.decimal :SRD, precision: 20, scale: 5, index: true
      t.decimal :STD, precision: 20, scale: 5, index: true
      t.decimal :SVC, precision: 20, scale: 5, index: true
      t.decimal :SYP, precision: 20, scale: 5, index: true
      t.decimal :SZL, precision: 20, scale: 5, index: true
      t.decimal :TJS, precision: 20, scale: 5, index: true
      t.decimal :TMT, precision: 20, scale: 5, index: true
      t.decimal :TND, precision: 20, scale: 5, index: true
      t.decimal :TOP, precision: 20, scale: 5, index: true
      t.decimal :TTD, precision: 20, scale: 5, index: true
      t.decimal :TWD, precision: 20, scale: 5, index: true
      t.decimal :TZS, precision: 20, scale: 5, index: true
      t.decimal :UAH, precision: 20, scale: 5, index: true
      t.decimal :UGX, precision: 20, scale: 5, index: true
      t.decimal :UYU, precision: 20, scale: 5, index: true
      t.decimal :UZS, precision: 20, scale: 5, index: true
      t.decimal :VEF, precision: 20, scale: 5, index: true
      t.decimal :VND, precision: 20, scale: 5, index: true
      t.decimal :VUV, precision: 20, scale: 5, index: true
      t.decimal :WST, precision: 20, scale: 5, index: true
      t.decimal :XAF, precision: 20, scale: 5, index: true
      t.decimal :XAG, precision: 20, scale: 5, index: true
      t.decimal :XAU, precision: 20, scale: 5, index: true
      t.decimal :XCD, precision: 20, scale: 5, index: true
      t.decimal :XDR, precision: 20, scale: 5, index: true
      t.decimal :XOF, precision: 20, scale: 5, index: true
      t.decimal :XPF, precision: 20, scale: 5, index: true
      t.decimal :YER, precision: 20, scale: 5, index: true
      t.decimal :ZMK, precision: 20, scale: 5, index: true
      t.decimal :ZMW, precision: 20, scale: 5, index: true
      t.decimal :ZWL, precision: 20, scale: 5, index: true
      t.boolean :is_deleted, default: false, index: true
      t.decimal :MYR, precision: 20, scale: 5, index: true
      t.datetime :deleted_at, index: true

      t.timestamps index: true
    end
    create_table :olap_facts_spends do |t|
      t.olap_references

      # Employee Expenses
      t.boolean :is_reimbursement, index: true
      t.integer :reimbursement_on_id, index: true

      # Header - General
      t.string :status, index: true
      t.string :description, index: true
      t.text :detailed_description
      t.integer :cost_center_id, index: true
      t.integer :location_id, index: true
      t.integer :department_id, index: true
      t.integer :category_id, index: true
      t.integer :policy_id, index: true
      t.integer :owner_id, index: true
      t.integer :service_period_start_id, index: true
      t.integer :service_period_end_id, index: true
      t.integer :date_id, index: true
      t.integer :payable_created_at_id, index: true
      t.integer :payable_submitted_at_id, index: true
      t.integer :payable_approved_at_id, index: true
      t.integer :rejection_count, index: true
      t.boolean :has_violation, index: true
      t.string :violation_description, index: true

      # Payee
      t.boolean :is_employee_expense, index: true
      t.boolean :is_vendor_payment, index: true
      t.integer :vendor_id, index: true
      t.integer :vendor_location_id, index: true
      t.string :vendor_name, index: true
      t.integer :shipping_location_id, index: true
      t.integer :billing_location_id, index: true
      t.boolean :is_gst_registered, index: true
      t.boolean :is_msme_registered, index: true
      t.boolean :is_composite_vendor, index: true
      t.integer :vendor_confirmed_at_id, index: true
      t.integer :days_for_confirmation, index: true
      t.integer :payment_mode, index: true

      # Item
      t.boolean :has_purchase_request, index: true
      t.boolean :has_purchase_order, index: true
      t.boolean :has_grn, index: true
      t.boolean :has_invoice, index: true
      t.boolean :has_agreement, index: true
      t.decimal :quantity_requested, index: true
      t.decimal :quantity_issued_from_inventory, index: true
      t.decimal :quantity_purchased, index: true
      t.decimal :quantity_cancelled, index: true
      t.decimal :quantity_received, index: true
      t.decimal :quantity_invoiced, index: true
      t.decimal :quantity_paid, index: true
      t.decimal :quantity_pending_purchase, index: true
      t.decimal :quantity_pending_receipt, index: true
      t.decimal :quantity_pending_invoice, index: true
      t.decimal :quantity_pending_payment, index: true
      t.integer :purchased_on_id, index: true
      t.integer :estimated_delivery_date_id, index: true
      t.integer :delivery_completed_on_id, index: true
      t.boolean :is_delivered_on_time, index: true
      t.boolean :has_on_time_delivery, index: true
      t.boolean :has_late_delivery, index: true
      t.integer :delivery_delayed_days, index: true
      t.decimal :quantity_delivered_on_time, index: true
      t.decimal :quantity_delivered_on_time_percentage, index: true
      t.decimal :quantity_delivered_late, index: true
      t.decimal :quantity_delivered_late_percentage, index: true
      t.decimal :quantity_purchased_percentage, index: true
      t.decimal :quantity_received_percentage, index: true
      t.decimal :quantity_invoiced_percentage, index: true
      t.decimal :quantity_cancelled_percentage, index: true
      t.decimal :quantity_paid_percentage, index: true
      t.boolean :is_exceeding_budget, index: true
      t.string :item_type, index: true

      # Spend
      t.integer :amount_id, index: true
      t.integer :basic_amount_id, index: true
      t.integer :tax_amount_id, index: true
      t.integer :tds_amount_id, index: true
      t.string :tax_type, index: true
      t.decimal :tax_percentage, index: true
      t.integer :cgst_amount_id, index: true
      t.integer :sgst_amount_id, index: true
      t.integer :igst_amount_id, index: true
      t.decimal :cgst_percentage, index: true
      t.decimal :sgst_percentage, index: true
      t.decimal :igst_percentage, index: true
      t.integer :amount_estimated_id, index: true
      t.integer :amount_purchased_id, index: true
      t.integer :amount_received_id, index: true
      t.integer :amount_invoiced_id, index: true
      t.integer :amount_paid_id, index: true
      t.integer :amount_pending_purchase_id, index: true
      t.integer :amount_pending_receipt_id, index: true
      t.integer :amount_pending_invoice_id, index: true
      t.integer :amount_pending_payment_id, index: true
      t.integer :advance_amount_requested_id, index: true
      t.integer :advance_amount_paid_id, index: true
      t.decimal :advance_percentage, index: true
      t.integer :credit_days, index: true
      t.integer :estimated_to_purchased_deviation_id, index: true
      t.decimal :estimated_to_purchased_deviation_percentage, index: true
      t.decimal :reimbursement_amount_id, index: true

      t.timestamps index: true
    end
  end
end
