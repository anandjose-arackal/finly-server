class Documents::Invoices::Form < Forms::API

  # model Invoice
  # section :header do
  #   # reference :purchase_order
  #   sequence :invoice_id, key: :non_po_invoice_initiator
  #   string :invoice_number, required: true
  #   date :date, required: true
  #   date :due_date, required: true
  #   lookup :policy_id, model: 'Policy', filters: {role_ids_in: [UserRole.id_for(:non_po_invoice_initiator)]} # todo handle policies specific to a user
  #   lookup :cost_center_id, model: 'CostCenter', required: true # todo lookup reference
  #   lookup :department_id, model: 'Department', required: true # todo lookup reference
  #   date :transaction_period_start, required: true
  #   date :transaction_period_end, required: true
  #   dropdown :cost_allocation_type, enum: ['Invoice', :cost_allocation_types] # todo: handle enum for dropdown
  #   text :narration # todo allow type to be modified in database to formula if required
  # end
  #
  # section :vendor_details do
  #   lookup :vendor_id, model: 'YesBankVendor' # todo model reference
  #   dropdown :vendor_account_id, choices: [], editable: false
  #   string :vendor_account_number, editable: false, options: {can_editable_be_changed: false} # todo handle editable false to not be send in requests to backend
  #   string :vendor_account_ifsc, editable: false, options: {can_editable_be_changed: false}
  #   string :beneficiary_type, editable: false, options: {can_editable_be_changed: false}
  #   dropdown :vendor_location, choices: []
  #   string :vendor_gstin, editable: false
  #   string :email, regex: {value: Constants::VALID_EMAIL_FORMAT, message: "Invalid Email ID"}
  #   string :mobile_number, regex: {value: Constants::VALID_MOBILE_NUMBER, message: "Invalid Mobile Number"} # todo handle regex
  # end
  #
  # section :buyer_details do
  #   lookup :billing_address_id, model: BranchLocation, filters: {billable_location: {value: true}, policy_mappings_policy_id_eq: {reference_field: :policy_id, required: true}}
  #   lookup :shipping_address_id, model: BranchLocation, filters: {billable_location: {value: true}, policy_mappings_policy_id_eq: {reference_field: :policy_id, required: true}}
  # end
  #
  # section :line_items do
  #   collection :line_items do
  #     lookup :description, model: Item, filters: {supply_item_type_id_in: SupplyItemType.ids_for(:po_non_po_item, :non_po_item)}, value: :description
  #   end
  # end
  #
  # section :summary do
  #   amount :discount_amount
  #   amount :gross_amount
  #   amount :net_amount
  #   amount :tds_amount
  #   amount :tax_amount
  #   amount :taxable_amount
  #   amount :amount
  # end
  #
  # functions do
  #
  # end

end