class Docs::UtilityBills::Subscriptions::Configs::Edit < Transactions::API
  step :init

  def init(options, params:, current_user:, **)
    result = {}
    result['types'] = ["DTH", "Cable", "Electricity", "Mobile Postpaid", "Water", "Landline Postpaid", "Broadband Prepaid", "Telephone", "Broadband Postpaid", "Mobile Prepaid"]
    result['departments'] = Company::Departments::Index.(current_user, params).policy_department_filter_mapping&.leaves
    result['locations'] = Company::Locations::Index.(current_user, params).policy_location_filter_mapping&.leaves
    result['cost_centers'] = current_user.company.cost_centers
    result['policies'] = ::Policy::VendorPayments::Index.(current_user, {filter_role_id: [UserRole.id_for(:utility_bill_master_initiator)]}).policies rescue Policy.none

    # [
    #     {name: "Broadband Prepaid", field_name: "Operator"},
    #     {name: "Broadband Postpaid", field_name: "Operator"},
    #     {name: "Cable",field_name: "Operator"},
    #     {name: "DTH", field_name: "Operator"},
    #     {name: "Electricity", field_name: "Board"},
    #     {name: "Landline Postpaid", field_name: "Operator"},
    #     {name: "Water", field_name: "Board"}
    #
    # ]

    options['result'] = result
  end
end