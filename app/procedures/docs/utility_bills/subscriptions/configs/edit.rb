class Docs::UtilityBills::Subscriptions::Configs::Edit < Transactions::API
  step :init

  def init(options)
    # types = ["Utility Bill Payment", "Registration Fees", "Insurance", "Bill Payment", "DTH", "Recharge", "Muncipal Taxes", "Cable", "Electricity", "Educational Fees", "LPG GAS", "Test", "Gas", "Mobile Postpaid", "Government Taxes", "Mobile", "Water", "Landline Postpaid", "Broadband Prepaid", "Telephone", "Broadband Postpaid", "Registration Fee", "Ops1", "Mobile Prepaid"]
    options[:output] = {}
    options[:output][:types] = ["DTH", "Cable", "Electricity", "Mobile Postpaid", "Water", "Landline Postpaid", "Broadband Prepaid", "Telephone", "Broadband Postpaid", "Mobile Prepaid"]


    [
        {name: "Broadband Prepaid", field_name: "Operator"},
        {name: "Broadband Postpaid", field_name: "Operator"},
        {name: "Cable",field_name: "Operator"},
        {name: "DTH", field_name: "Operator"},
        {name: "Electricity", field_name: "Board"},
        {name: "Landline Postpaid", field_name: "Operator"},
        {name: "Water", field_name: "Board"}

    ]
  end
end