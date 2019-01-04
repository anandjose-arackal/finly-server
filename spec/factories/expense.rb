# require './company'
FactoryBot.define do
  # sequence : do |n|
  #   "Policy - #{n}"
  # end

  factory :expense do

    expense_status_id {1}
    note {Faker::Lorem.sentence}
    category_id {Category.last.id}
    date { "02-Jan-2019"}
    amount_attributes {{value: "230", currency_id: "1"}}
    manual_expense_attributes {{merchant: "Merchant 3"}}
    expense_type_id {1}
    spent_from_id {nil}
    reimbursable {true}
    user_id {nil}

  end
end

