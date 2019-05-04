class AddIndexToSystemMessages < ActiveRecord::Migration[5.2]
  def change
    # add_index :system_messages, [:messagable_type, :messagable_id]
    # add_index :system_messages, :message_type
    models = ApplicationRecord.descendants
    models.each do |model|
      next unless model <= SoftDeletable
      next if ActiveRecord::Base.connection.index_exists?(model.table_name, :deleted_at)
      add_index model.table_name, :deleted_at
    end
    add_index :receipts, :created_at
    add_index :receipts, :parent_id
    add_index :payments, [ :reference_resource_type, :reference_resource_id], name: 'index_payments_on_reference_resource'
    add_index :payments, :created_at
    add_index :payments, :date

    add_index :bank_payment_requests, :created_at
    add_index :budget_trails, [:entity_type, :entity_id]
    add_index :expenses, :created_at

    add_index :bank_accounts, :created_at
    add_index :procurements, :procurement_type
    add_index :procurement_attachments, [:procurement_document_id, :procurement_document_type], name: "index_procurement_attachments_on_procurement_document"
    add_index :invoices, :controlling_level_id

    add_index :categories, :name
    add_index :categories, :active

    add_index :yes_bank_vendors, :vendor_id
    add_index :bank_transactions, :unique_request_number

    add_index :artifacts, :company_id
    add_index :artifacts, :creator_id
    add_index :artifacts, [:resource_id, :resource_type]
    add_index :attachments, :company_id
    add_index :attachments, :creator_id
    add_index :attachments, [:resource_id, :resource_type]
    add_index :bank_payment_requests, :company_id
    add_index :beneficiary_payments, :balance_due_id
    add_index :beneficiary_payments, :gross_amount_id
    add_index :beneficiary_payments, :net_amount_id
    add_index :beneficiary_payments, :tds_amount_id
    add_index :budget_modification_trails, :budget_modification_action_id, name: 'index_budget_modification_trails_on_action_id'
    add_index :company_configurations, :default_card_expense_category_id
    add_index :company_kyc_trails, :action_id
    add_index :company_kyc_trails, [:action_resource_id, :action_resource_type], name: 'index_company_kyc_trails_on_action_resource'
    add_index :company_kycs, :company_type_id
    add_index :company_kycs, :kyc_status_id
    add_index :contacts, [:contactable_id, :contactable_type]
    add_index :custom_export_configurations, [:configurable_id, :configurable_type], name: 'index_custom_export_configurations_on_configurable'
    add_index :custom_fields, [:value_id, :value_type]
    add_index :customers, :company_id
    add_index :customers, :created_by_id
    add_index :distance_expense_configs, :default_category_id
    add_index :distance_expense_configs, :policy_id
    add_index :distance_expense_configs, :rate_id
    add_index :distance_expenses, :distance_id
    add_index :distance_expenses, :distance_rate_id
    add_index :distance_expenses, :distance_unit_id
    add_index :distance_expenses, :maps_distance_id
    add_index :distance_expenses, :odometer_reading_receipt_end_id
    add_index :distance_expenses, :odometer_reading_receipt_start_id
    add_index :distance_expenses, :type_id
    add_index :distance_expenses, :vehicle_rate_id
    add_index :document_level_reviewer_mappings, :action_id
    add_index :document_level_reviewer_mappings, :action_taken_by_id
    add_index :document_level_reviewer_mappings, :forwarded_by_id
    add_index :document_level_reviewer_mappings, :forwarded_to_id
    add_index :document_level_reviewer_mappings, :taken_control_by_id
    add_index :duplicate_expense_mappings, :duplicate_expense_id
    add_index :expense_data_extracts, :expense_data_extract_source_id
    add_index :expense_data_extracts, :status_id
    add_index :expense_data_extracts, [:extractable_id, :extractable_type], name: 'index_expense_data_extracts_on_extractable'
    add_index :expenses, :created_by_id
    add_index :expenses, :gst_amount_id
    add_index :expenses, :gst_type_id
    add_index :expenses, :modified_by_id
    add_index :expenses, :rejecting_manager_id
    add_index :expenses, :spent_from_id
    add_index :expenses, :tds_amount_id
    add_index :expenses, :tds_slab_id
    add_index :field_configurations, [:default_value_id, :default_value_type], name: 'index_field_configurations_on_default_value'
    add_index :field_configurations, [:external_reference_id, :external_reference_type], name: 'index_field_configurations_on_external_reference'
    add_index :field_configurations, [:parent_id, :parent_type]
    add_index :field_multiselect_items, :field_configuration_id
    add_index :field_multiselect_selection_items, :field_multiselect_selection_id, name: 'index_field_multiselect_selection_items_on_selection_id'
    add_index :gstin_locations, :gstin_id
    add_index :gstin_locations, :state_id
    add_index :individual_kycs, :kyc_status_id
    add_index :individual_kycs, :type_id
    add_index :individual_kycs, :upgraded_by_resource_id
    add_index :invoice_attachments, :company_id
    add_index :invoice_line_items, :amount_id
    add_index :invoice_line_items, :cost_center_id
    add_index :invoice_line_items, :inventory_line_item_id
    add_index :invoice_line_items, :net_amount_id
    add_index :invoice_line_items, :tax_rate_id
    add_index :invoice_line_items, :taxable_amount_id
    add_index :invoice_line_items, [:parent_id, :parent_type]
    add_index :invoice_number_configs, :company_id
    add_index :invoice_reminders, :company_id
    add_index :invoices, :advance_amount_id
    add_index :invoices, :amount_id
    add_index :invoices, :balance_due_id
    add_index :invoices, :category_id
    add_index :invoices, :company_id
    add_index :invoices, :controlling_for_user_id
    add_index :invoices, :controlling_for_user_role_id
    add_index :invoices, :controlling_user_id
    add_index :invoices, :controlling_user_role_id
    add_index :invoices, :cost_center_id
    add_index :invoices, :created_by_user_id
    add_index :invoices, :delivery_location_id
    add_index :invoices, :department_id
    add_index :invoices, :discount_amount_id
    add_index :invoices, :freight_amount_id
    add_index :invoices, :gross_amount_id
    add_index :invoices, :gst_type_id
    add_index :invoices, :location_id
    add_index :invoices, :net_amount_id
    add_index :invoices, :original_amount_id
    add_index :invoices, :po_adjusted_advance
    add_index :invoices, :policy_id
    add_index :invoices, :procurement_id
    add_index :invoices, :proforma_advance
    add_index :invoices, :remaining_amount_id
    add_index :invoices, :resource_template_id
    add_index :invoices, :sub_department_id
    add_index :invoices, :tax_amount_id
    add_index :invoices, :taxable_amount_id
    add_index :invoices, :tds_amount_id
    add_index :invoices, :tds_slab_id
    add_index :invoices, :vendor_id
    add_index :invoices, [:receiving_account_id, :receiving_account_type], name: 'index_invoices_on_receiving_account'
    add_index :itz_cash_company_accounts, :balance_id
    add_index :itz_cash_company_accounts, :wallet_balance_id
    add_index :itz_cash_dmt_senders, :status_id
    add_index :money_request_comments, :delegated_action_user_id
    add_index :money_request_items, :money_request_item_category_id
    add_index :money_request_processor_mappings, [:processor_accountable_id, :processor_accountable_type], name: 'index_money_request_processor_mappings_on_processor_accountable'
    add_index :money_request_tracks, :action_user_role_id
    add_index :money_request_tracks, :delegated_action_user_id
    add_index :money_requests, :controlling_level_id
    add_index :money_requests, :created_by_id
    add_index :money_requests, :destination_pocket_id
    add_index :money_requests, :modified_by_id
    add_index :money_requests, :money_request_processor_mapping_id
    add_index :money_requests, :processed_amount_id
    add_index :money_requests, :submitted_amount_id
    add_index :parent_dependent_field_configuration_mappings, :dependent_field_configuration_id, name: 'index_parent_dependent_field_configuration_mappings_on_config_id'
    add_index :parent_dependent_field_configuration_mappings, [:parent_id, :parent_type], name: 'index_parent_dependent_field_configuration_mappings_parent'
    add_index :payment_trails, [:initiating_account_id, :initiating_account_type], name: 'index_payment_trails_on_initiating_account'
    add_index :payment_trails, [:initiating_user_id, :initiating_user_type], name: 'index_payment_trails_on_initiating_user'
    add_index :payment_trails, [:receiving_account_id, :receiving_account_type], name: 'index_payment_trails_on_receiving_account'
    add_index :payment_trails, [:receiving_user_id, :receiving_user_type], name: 'index_payment_trails_on_receiving_user'
    add_index :payments, :department_id
    add_index :payments, :destination_pocket_id
    add_index :payments, :invoice_id
    add_index :payments, :original_payment_for_refund_id
    add_index :payments, :payment_purpose_id
    add_index :payments, :payment_status_id
    add_index :payments, [:initiating_account_id, :initiating_account_type], name: 'index_payments_on_initiating_account'
    add_index :payments, [:initiating_user_id, :initiating_user_type], name: 'index_payments_on_initiating_user'
    add_index :payments, [:receiving_account_id, :receiving_account_type], name: 'index_payments_on_receiving_account'
    add_index :payments, [:receiving_user_id, :receiving_user_type], name: 'index_payments_on_receiving_user'
    add_index :payments, [:parent_id, :parent_type]
    add_index :per_diem_expense_configs, :policy_id
    add_index :per_diems, [:configurable_id, :configurable_type]
    add_index :policies, :base_currency_id
    add_index :policies, :settlement_currency_id
    add_index :policy_department_mappings, :department_id
    add_index :policy_department_mappings, :policy_id
    add_index :policy_location_department_mappings, :company_id
    add_index :policy_location_department_mappings, :department_id
    add_index :policy_location_department_mappings, :location_id
    add_index :policy_location_department_mappings, :policy_id
    add_index :policy_location_mappings, :location_id
    add_index :policy_location_mappings, :policy_id
    add_index :procurement_attachments, :company_id
    add_index :purchase_order_items, :category_id
    add_index :purchase_order_items, :cost_center_id
    add_index :purchase_order_items, :purchase_request_item_id
    add_index :purchase_order_items, :tax_rate_id
    add_index :purchase_orders, :advance_tds_amount_id
    add_index :purchase_orders, :advance_tds_slab_id
    add_index :purchase_orders, :controlling_for_user_id
    add_index :purchase_orders, :controlling_for_user_role_id
    add_index :purchase_orders, :controlling_level_id
    add_index :purchase_orders, :controlling_user_id
    add_index :purchase_orders, :controlling_user_role_id
    add_index :purchase_orders, :cost_center_id
    add_index :purchase_orders, :department_id
    add_index :purchase_orders, :requested_advance_amount_id
    add_index :purchase_orders, :resource_template_id
    add_index :purchase_orders, :sub_department_id
    add_index :purchase_request_items, :purchase_order_id
    add_index :purchase_request_items, :status_id
    add_index :purchase_requests, :company_id
    add_index :purchase_requests, :controlling_level_id
    add_index :purchase_requests, :cost_center_id
    add_index :purchase_requests, :creator_id
    add_index :purchase_requests, :department_id
    add_index :purchase_requests, :location_id
    add_index :purchase_requests, :policy_id
    add_index :rate_contract_line_items, :amount_id
    add_index :rate_contract_line_items, :item_id
    add_index :rate_contract_line_items, :location_id
    add_index :rate_contract_line_items, :rate_contract_id
    add_index :rate_contracts, :company_id
    add_index :rate_contracts, :creator_id
    add_index :rate_contracts, :item_id
    add_index :rate_contracts, :renewal_alert_period_id
    add_index :rate_contracts, :vendor_id
    add_index :receipts, :created_by_id
    add_index :receipts, :modified_by_id
    add_index :receipts, [:sourcable_id, :sourcable_type]
    add_index :report_comments, :delegated_action_user_id
    add_index :report_comments, :payment_id
    add_index :report_processor_group_mappings, [:processor_accountable_id, :processor_accountable_type], name: 'index_report_processor_group_mappings_on_processor_accountable'
    add_index :report_tracks, :action_user_role_id
    add_index :report_tracks, :cash_in_hand_deduction_id
    add_index :report_tracks, :delegated_action_user_id
    add_index :report_tracks, :payment_id
    add_index :reports, :card_expenses_total_id
    add_index :reports, :cash_in_hand_deduction_id
    add_index :reports, :controlling_level_id
    add_index :reports, :created_by_id
    add_index :reports, :department_id
    add_index :reports, :modified_by_id
    add_index :reports, :non_reimbursable_expenses_total_id
    add_index :reports, :reimbursable_expenses_total_id
    add_index :reports, :reimbursement_id
    add_index :reports, :sub_department_id
    add_index :reports, :submitted_amount_id
    add_index :reports, :sync_status_id
    add_index :reports, :sync_type_id
    add_index :reports, :travel_request_id
    add_index :time_expense_configs, :default_category_id
    add_index :time_expense_configs, :period_id
    add_index :time_expense_configs, :policy_id
    add_index :time_expense_configs, :rate_id
    add_index :time_expenses, :time_object_id
    add_index :trails, :cash_on_hand_deduction_id
    add_index :trails, :payment_id
    add_index :trails, [:original_track_id, :original_track_type]
    add_index :transaction_details, :closing_balance_id
    add_index :transaction_details, :opening_balance_id
    add_index :travel_request_comments, :action_id
    add_index :travel_request_comments, :booking_id
    add_index :travel_request_comments, :booking_request_id
    add_index :travel_request_comments, :delegated_action_user_id
    add_index :travel_request_destinations, :location_id
    add_index :travel_request_trails, :delegated_action_user_id
    add_index :travel_requests, :controlling_level_id
    add_index :user_balance_histories, :card_atm_withdrawal_id
    add_index :user_manager_mappings, :purpose_id
    add_index :user_manager_mappings, :travel_approves_to_id
    add_index :user_manager_mappings, :travel_booking_approves_to_id
    add_index :user_manager_mappings, :travel_booking_selector_id
    add_index :user_manager_mappings, :travel_manager_id
    add_index :user_pockets, :base_currency_id
    add_index :user_pockets, :company_pocket_template_id
    add_index :user_pockets, :user_id
    add_index :user_role_mappings, :branch_location_id
    add_index :user_role_mappings, :company_department_id
    add_index :user_role_mappings, :purpose_id
    add_index :users, :otp_request_type_id
    add_index :users, :user_delegate_id
    add_index :users, [:invited_by_id, :invited_by_type]
    add_index :vendor_tds_rates, :tds_rates_list_id
    add_index :virtual_account_transactions, :virtual_account_id
    add_index :virtual_bank_accounts, :company_id
    add_index :virtual_bank_accounts, :customer_id
    add_index :virtual_bank_accounts, :exact_transaction_amount_id
    add_index :virtual_bank_accounts, :initiating_user_id
    add_index :virtual_bank_accounts, :maximum_amount_id
    add_index :virtual_bank_accounts, :maximum_transaction_amount_id
    add_index :virtual_bank_accounts, :minimum_transaction_amount_id
    add_index :virtual_bank_accounts, :purpose_id
    add_index :virtual_bank_accounts, [:parent_id, :parent_type]
    add_index :virtual_bank_accounts, [:receiving_account_id, :receiving_account_type], name: 'index_virtual_bank_accounts_on_receiving_account'
    add_index :whitelisted_ips, :whitelisted_ip_type_id
    add_index :yes_bank_company_accounts, :balance_id
    add_index :yes_bank_company_accounts, :wallet_balance_id
    add_index :yes_bank_vendors, :controlling_level_id
    add_index :yes_bank_vendors, :created_by_id
    add_index :yes_bank_vendors, :currency_id
    add_index :yes_bank_vendors, :payment_term_id
    add_index :yes_bank_vendors, :policy_id
    add_index :yes_bank_vendors, :state_code_id
    add_index :yes_bank_vendors, :status_id

    add_index :yes_bank_vendors, :authorized
    add_index :bank_accounts, [:account_owner_type, :account_owner_id]
  end
end
