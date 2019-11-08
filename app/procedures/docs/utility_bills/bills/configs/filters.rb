class Docs::UtilityBills::Bills::Configs::Filters < Transactions::API

  step :init

  def init(options, params:, current_user:, model:, **)
    result = {}
    result['types'] = ["DTH", "Cable", "Electricity", "Mobile Postpaid", "Water", "Landline Postpaid", "Broadband Prepaid", "Telephone", "Broadband Postpaid", "Mobile Prepaid"]
    result['departments'] = Company::Departments::Index.(current_user, params).policy_department_filter_mapping&.leaves
    result['locations'] = Company::Locations::Index.(current_user, params).policy_location_filter_mapping&.leaves
    result['cost_centers'] = current_user.company.cost_centers
    result['policies'] = ::Policy::VendorPayments::Index.(current_user, {filler: 'filler'}).policies rescue Policy.none

    options['result'] = result
  end
end