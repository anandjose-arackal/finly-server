class Docs::UtilityBills::Subscriptions::Configs::Filters < Transactions::API

  step :init

  def init(options, params:, current_user:, **)
    result = {}
    # result['types'] = ["DTH", "Cable", "Electricity", "Mobile Postpaid", "Water", "Landline Postpaid", "Broadband Prepaid", "Telephone", "Broadband Postpaid", "Mobile Prepaid", "Gas", "Mobile"]
    result['types'] = BbpsBiller.all.pluck(:biller_category_name).uniq.compact
    result['departments'] = Company::Departments::Index.(current_user, params).policy_department_filter_mapping&.leaves
    result['locations'] = Company::Locations::Index.(current_user, params).policy_location_filter_mapping&.leaves
    result['cost_centers'] = current_user.company.cost_centers.non_deleted
    result['policies'] = ::Policy::VendorPayments::Index.(current_user, {filler: 'filler'}).policies rescue Policy.none

    options['result'] = result
  end
end