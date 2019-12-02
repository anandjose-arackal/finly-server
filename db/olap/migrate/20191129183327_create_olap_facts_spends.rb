class CreateOlapFactsSpends < ActiveRecord::Migration[5.2]
  def change
    create_table :amounts do |t|
      t.olap_references

      t.decimal :value, precision: 64, scale: 12, index: true
      t.string :currency, index: true
      t.decimal :INR, precision: 20, scale: 5
      t.decimal :USD, precision: 20, scale: 5
      t.decimal :GBP, precision: 20, scale: 5
      t.decimal :CAD, precision: 20, scale: 5
      t.decimal :EUR, precision: 20, scale: 5
      t.decimal :HRK, precision: 20, scale: 5
      t.decimal :RUB, precision: 20, scale: 5
      t.decimal :BGN, precision: 20, scale: 5
      t.decimal :BRL, precision: 20, scale: 5
      t.decimal :CHF, precision: 20, scale: 5
      t.decimal :CNY, precision: 20, scale: 5
      t.decimal :CZK, precision: 20, scale: 5
      t.decimal :DKK, precision: 20, scale: 5
      t.decimal :HKD, precision: 20, scale: 5
      t.decimal :HUF, precision: 20, scale: 5
      t.decimal :IDR, precision: 20, scale: 5
      t.decimal :ILS, precision: 20, scale: 5
      t.decimal :JPY, precision: 20, scale: 5
      t.decimal :KRW, precision: 20, scale: 5
      t.decimal :MXN, precision: 20, scale: 5
      t.decimal :NOK, precision: 20, scale: 5
      t.decimal :NZD, precision: 20, scale: 5
      t.decimal :PHP, precision: 20, scale: 5
      t.decimal :PLN, precision: 20, scale: 5
      t.decimal :RON, precision: 20, scale: 5
      t.decimal :SEK, precision: 20, scale: 5
      t.decimal :SGD, precision: 20, scale: 5
      t.decimal :THB, precision: 20, scale: 5
      t.decimal :TRY, precision: 20, scale: 5
      t.decimal :ZAR, precision: 20, scale: 5
      t.decimal :AUD, precision: 20, scale: 5
      t.decimal :AED, precision: 20, scale: 5
      t.decimal :AFN, precision: 20, scale: 5
      t.decimal :ALL, precision: 20, scale: 5
      t.decimal :AMD, precision: 20, scale: 5
      t.decimal :ANG, precision: 20, scale: 5
      t.decimal :AOA, precision: 20, scale: 5
      t.decimal :ARS, precision: 20, scale: 5
      t.decimal :AWG, precision: 20, scale: 5
      t.decimal :AZN, precision: 20, scale: 5
      t.decimal :BAM, precision: 20, scale: 5
      t.decimal :BBD, precision: 20, scale: 5
      t.decimal :BDT, precision: 20, scale: 5
      t.decimal :BHD, precision: 20, scale: 5
      t.decimal :BIF, precision: 20, scale: 5
      t.decimal :BMD, precision: 20, scale: 5
      t.decimal :BND, precision: 20, scale: 5
      t.decimal :BOB, precision: 20, scale: 5
      t.decimal :BSD, precision: 20, scale: 5
      t.decimal :BTC, precision: 20, scale: 5
      t.decimal :BTN, precision: 20, scale: 5
      t.decimal :BWP, precision: 20, scale: 5
      t.decimal :BYN, precision: 20, scale: 5
      t.decimal :BYR, precision: 20, scale: 5
      t.decimal :BZD, precision: 20, scale: 5
      t.decimal :CDF, precision: 20, scale: 5
      t.decimal :CLF, precision: 20, scale: 5
      t.decimal :CLP, precision: 20, scale: 5
      t.decimal :COP, precision: 20, scale: 5
      t.decimal :CRC, precision: 20, scale: 5
      t.decimal :CUC, precision: 20, scale: 5
      t.decimal :CUP, precision: 20, scale: 5
      t.decimal :CVE, precision: 20, scale: 5
      t.decimal :DJF, precision: 20, scale: 5
      t.decimal :DOP, precision: 20, scale: 5
      t.decimal :DZD, precision: 20, scale: 5
      t.decimal :EEK, precision: 20, scale: 5
      t.decimal :EGP, precision: 20, scale: 5
      t.decimal :ERN, precision: 20, scale: 5
      t.decimal :ETB, precision: 20, scale: 5
      t.decimal :FJD, precision: 20, scale: 5
      t.decimal :FKP, precision: 20, scale: 5
      t.decimal :GEL, precision: 20, scale: 5
      t.decimal :GGP, precision: 20, scale: 5
      t.decimal :GHS, precision: 20, scale: 5
      t.decimal :GIP, precision: 20, scale: 5
      t.decimal :GMD, precision: 20, scale: 5
      t.decimal :GNF, precision: 20, scale: 5
      t.decimal :GTQ, precision: 20, scale: 5
      t.decimal :GYD, precision: 20, scale: 5
      t.decimal :HNL, precision: 20, scale: 5
      t.decimal :HTG, precision: 20, scale: 5
      t.decimal :IMP, precision: 20, scale: 5
      t.decimal :IQD, precision: 20, scale: 5
      t.decimal :IRR, precision: 20, scale: 5
      t.decimal :ISK, precision: 20, scale: 5
      t.decimal :JEP, precision: 20, scale: 5
      t.decimal :JMD, precision: 20, scale: 5
      t.decimal :JOD, precision: 20, scale: 5
      t.decimal :KES, precision: 20, scale: 5
      t.decimal :KGS, precision: 20, scale: 5
      t.decimal :KHR, precision: 20, scale: 5
      t.decimal :KMF, precision: 20, scale: 5
      t.decimal :KPW, precision: 20, scale: 5
      t.decimal :KWD, precision: 20, scale: 5
      t.decimal :KYD, precision: 20, scale: 5
      t.decimal :KZT, precision: 20, scale: 5
      t.decimal :LAK, precision: 20, scale: 5
      t.decimal :LBP, precision: 20, scale: 5
      t.decimal :LKR, precision: 20, scale: 5
      t.decimal :LRD, precision: 20, scale: 5
      t.decimal :LSL, precision: 20, scale: 5
      t.decimal :LTL, precision: 20, scale: 5
      t.decimal :LVL, precision: 20, scale: 5
      t.decimal :LYD, precision: 20, scale: 5
      t.decimal :MAD, precision: 20, scale: 5
      t.decimal :MDL, precision: 20, scale: 5
      t.decimal :MGA, precision: 20, scale: 5
      t.decimal :MKD, precision: 20, scale: 5
      t.decimal :MMK, precision: 20, scale: 5
      t.decimal :MNT, precision: 20, scale: 5
      t.decimal :MOP, precision: 20, scale: 5
      t.decimal :MRO, precision: 20, scale: 5
      t.decimal :MUR, precision: 20, scale: 5
      t.decimal :MVR, precision: 20, scale: 5
      t.decimal :MWK, precision: 20, scale: 5
      t.decimal :MZN, precision: 20, scale: 5
      t.decimal :NAD, precision: 20, scale: 5
      t.decimal :NGN, precision: 20, scale: 5
      t.decimal :NIO, precision: 20, scale: 5
      t.decimal :NPR, precision: 20, scale: 5
      t.decimal :OMR, precision: 20, scale: 5
      t.decimal :PAB, precision: 20, scale: 5
      t.decimal :PEN, precision: 20, scale: 5
      t.decimal :PGK, precision: 20, scale: 5
      t.decimal :PKR, precision: 20, scale: 5
      t.decimal :PYG, precision: 20, scale: 5
      t.decimal :QAR, precision: 20, scale: 5
      t.decimal :RSD, precision: 20, scale: 5
      t.decimal :RWF, precision: 20, scale: 5
      t.decimal :SAR, precision: 20, scale: 5
      t.decimal :SBD, precision: 20, scale: 5
      t.decimal :SCR, precision: 20, scale: 5
      t.decimal :SDG, precision: 20, scale: 5
      t.decimal :SHP, precision: 20, scale: 5
      t.decimal :SLL, precision: 20, scale: 5
      t.decimal :SOS, precision: 20, scale: 5
      t.decimal :SRD, precision: 20, scale: 5
      t.decimal :STD, precision: 20, scale: 5
      t.decimal :SVC, precision: 20, scale: 5
      t.decimal :SYP, precision: 20, scale: 5
      t.decimal :SZL, precision: 20, scale: 5
      t.decimal :TJS, precision: 20, scale: 5
      t.decimal :TMT, precision: 20, scale: 5
      t.decimal :TND, precision: 20, scale: 5
      t.decimal :TOP, precision: 20, scale: 5
      t.decimal :TTD, precision: 20, scale: 5
      t.decimal :TWD, precision: 20, scale: 5
      t.decimal :TZS, precision: 20, scale: 5
      t.decimal :UAH, precision: 20, scale: 5
      t.decimal :UGX, precision: 20, scale: 5
      t.decimal :UYU, precision: 20, scale: 5
      t.decimal :UZS, precision: 20, scale: 5
      t.decimal :VEF, precision: 20, scale: 5
      t.decimal :VND, precision: 20, scale: 5
      t.decimal :VUV, precision: 20, scale: 5
      t.decimal :WST, precision: 20, scale: 5
      t.decimal :XAF, precision: 20, scale: 5
      t.decimal :XAG, precision: 20, scale: 5
      t.decimal :XAU, precision: 20, scale: 5
      t.decimal :XCD, precision: 20, scale: 5
      t.decimal :XDR, precision: 20, scale: 5
      t.decimal :XOF, precision: 20, scale: 5
      t.decimal :XPF, precision: 20, scale: 5
      t.decimal :YER, precision: 20, scale: 5
      t.decimal :ZMK, precision: 20, scale: 5
      t.decimal :ZMW, precision: 20, scale: 5
      t.decimal :ZWL, precision: 20, scale: 5
      t.boolean :is_deleted, default: false, index: true
      t.decimal :MYR, precision: 20, scale: 5
      t.datetime :deleted_at, index: true

      t.timestamps index: true
    end

    create_table :olap_facts_spends do |t|
      t.olap_references

      # Employee Expenses
      t.boolean :is_reimbursement, index: true
      t.integer :reimbursement_on_id

      # Header - General
      t.string :description, index: true
      t.text :detailed_description
      t.integer :parent_cost_center_id
      t.integer :cost_center_id
      t.integer :parent_location_id
      t.integer :location_id
      t.integer :parent_department_id
      t.integer :department_id
      t.integer :parent_category_id
      t.integer :category_id
      t.integer :policy_id
      t.integer :owner_id
      t.integer :service_period_start_id
      t.integer :service_period_end_id
      t.integer :date_id

      # Payee
      t.boolean :is_employee_expense, index: true
      t.boolean :is_vendor_payment, index: true
      t.integer :vendor_id
      t.integer :vendor_location_id
      t.string :vendor_name, index: true
      t.integer :shipping_location_id
      t.integer :billing_location_id
      t.boolean :is_gst_registered, index: true
      t.boolean :is_msme_registered, index: true
      t.boolean :is_composite_vendor, index: true
      t.integer :vendor_confirmed_at_id
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
      t.integer :purchased_on_id
      t.integer :estimated_delivery_date_id
      t.integer :delivery_completed_on_id
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
      t.integer :item_id
      t.string :asset_type, index: true

      # Spend
      t.integer :amount_id
      t.integer :basic_amount_id
      t.integer :tax_amount_id
      t.integer :tds_amount_id
      t.string :tax_type, index: true
      t.decimal :tax_percentage, index: true
      t.integer :cgst_amount_id
      t.integer :sgst_amount_id
      t.integer :igst_amount_id
      t.decimal :cgst_percentage, index: true
      t.decimal :sgst_percentage, index: true
      t.decimal :igst_percentage, index: true
      t.integer :amount_estimated_id
      t.integer :amount_purchased_id
      t.integer :amount_received_id
      t.integer :amount_invoiced_id
      t.integer :amount_paid_id
      t.integer :amount_pending_purchase_id
      t.integer :amount_pending_receipt_id
      t.integer :amount_pending_invoice_id
      t.integer :amount_pending_payment_id
      t.integer :advance_amount_requested_id
      t.integer :advance_amount_paid_id
      t.decimal :advance_percentage, index: true
      t.integer :credit_days, index: true
      t.integer :estimated_deviation_id
      t.decimal :estimated_deviation_percentage, index: {name: 'olap_facts_spends_est_deviation_percentage'}
      t.decimal :reimbursement_amount_id

      t.timestamps index: true
    end
  end
end
