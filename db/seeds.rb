# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

def random(low, high)
  rand * (high - low) + low
end

def random_integer(low, high)
  random(low, high).to_i
end

def random_string_of_numbers(length)
  (0...length).map { (48 + rand(10)).chr }.join
end

def random_mobile_number
  pattern = '[789]\d{9}'
  StringRandom.random_regex(pattern)
end

if ExportField.count == 0
  ExportField.create(id: 1, name: 'Employee Name')
  ExportField.create(id: 2, name: 'Employee ID')
  ExportField.create(id: 3, name: 'Payroll ID')
  ExportField.create(id: 4, name: 'Report ID')
  ExportField.create(id: 5, name: 'Report name')
  ExportField.create(id: 6, name: 'Report Status')
  ExportField.create(id: 7, name: 'Expense ID')
  ExportField.create(id: 8, name: 'Expense Merchant')
  ExportField.create(id: 9, name: 'Expense Currency')
  ExportField.create(id: 10, name: 'Expense Amount')
  ExportField.create(id: 11, name: 'Expense Date')
  ExportField.create(id: 12, name: 'Expense Category Name')
end

if UserRole.count == 0
  UserRole.create id: 1, name: 'Admin'
  UserRole.create id: 2, name: 'Finance Manager'
  UserRole.create id: 3, name: 'Manager'
  UserRole.create id: 4, name: 'Employee'
  UserRole.create id: 5, name: 'Auditor'
end

if ReportStatus.count == 0
  ReportStatus.create(id: 1, name: 'Open', order: 1)
  ReportStatus.create(id: 2, name: 'Processing', order: 2)
  ReportStatus.create(id: 3, name: 'Retracted', order: 3)
  ReportStatus.create(id: 4, name: 'Rejected', order: 4)
  ReportStatus.create(id: 5, name: 'Approved', order: 5)
  ReportStatus.create(id: 6, name: 'Reimbursed', order: 6)
  ReportStatus.create(id: 7, name: 'Reimbursement Confirmed', order: 7)
  ReportStatus.create(id: 8, name: 'Closed', order: 8)
end

if ReportTrackingAction.count == 0
  ReportTrackingAction.create id: 1, name: 'Create'
  ReportTrackingAction.create id: 2, name: 'Retract'
  ReportTrackingAction.create id: 3, name: 'Submit'
  ReportTrackingAction.create id: 4, name: 'Approve'
  ReportTrackingAction.create id: 5, name: 'Auto Approve'
  ReportTrackingAction.create id: 6, name: 'Reject'
  ReportTrackingAction.create id: 7, name: 'Unapprove'
  ReportTrackingAction.create id: 8, name: 'Take Control'
  ReportTrackingAction.create id: 9, name: 'Reimbursed'
  ReportTrackingAction.create id: 10, name: 'Reimbursement Confirmed'
  ReportTrackingAction.create id: 11, name: 'Closed'
end

if ReportCommentAction.count == 0
  ReportCommentAction::ACTIONS.each do |key, value|
    ReportCommentAction.create id: value, name: key
  end
end

if MoneyRequestCommentAction.count == 0
  MoneyRequestCommentAction::ACTIONS.each do |key, value|
    MoneyRequestCommentAction.create id: value, name: key
  end
end

if MoneyRequestTrackingAction.count == 0
  MoneyRequestTrackingAction::ACTIONS.each do |key, value|
    MoneyRequestTrackingAction.create id: value, name: key
  end
end

if MoneyRequestStatus.count == 0
  MoneyRequestStatus::VALUES.each do |key, value|
    name = key.to_s
    name[0] = name[0].capitalize
    MoneyRequestStatus.create id: value, name: name
  end
end

if PaymentMode.count == 0
  PaymentMode::MODES.each do |key, value|
    PaymentMode.create id: value, name: key
  end
end

if State.count == 0
  State::VALUES.each do |item|
    State.create code: item[:code], name: item[:name]
  end
end

if Event.count == 0
  Event::ACTIONS.each do |item|
    Event.create id: (Event::ACTIONS.find_index(item) + 1), name: item[:key].to_s,
                 has_push_notification: item[:has_push_notification], has_mailer: item[:has_mailer],
                 configurable_push_notification: item[:configurable_push_notification],
                 configurable_mailer: item[:configurable_mailer]
  end
end

if Currency.count == 0
  Currency.create(id: 1, country: 'India', country_code: 'INR', symbol: '₹')
end

if Amount.count == 0
  Amount.create(id: 1, currency: Currency.first, value: 0)
end

if Company.count == 0
  c = Company.create(name: 'Finly', d_code: 'D000000360')
  c.reload
  Company.create(name: 'Dummy company')
else
  c = Company.first
end


if Period.count == 0
  Period::VALUES.each do |key, value|
    Period.create id: value, name: key
  end
end

if c.categories.count == 0
  10.times do |i|
    c.categories.create!(name: "Test category #{i+1}")
  end
end

if User.count == 0
  a = User.create(company: Company.first, first_name: "Finly", last_name: "Admin", email: "admin@finlytest.io",
                  password: "hapitoe007", password_confirmation: "hapitoe007", company_id: c.id, mobile_number: random_mobile_number,
                  role_mapping_attributes: [{user_role_id: UserRole.admin_id},
                                            {user_role_id: UserRole.employee_id}],
                  profile_attributes: {date_of_birth: Faker::Date.backward(365), gender: 'm', address_1: 'Dummy Address',
                                       address_2: 'Dummy Address Line 2', city: Faker::Address.city, state: State.first, pin_code: "123456"})

  User.create(company: Company.first, first_name: "Finly", last_name: "King", email: "king@finlytest.io",
              password: "hapitoe007", password_confirmation: "hapitoe007", company_id: c.id, mobile_number: random_mobile_number,
              role_mapping_attributes: [{user_role_id: UserRole.admin_id}, {user_role_id: UserRole.manager_id},
                                        {user_role_id: UserRole.finance_manager_id}, {user_role_id: UserRole.employee_id}],
              profile_attributes: {date_of_birth: Faker::Date.backward(365), gender: 'm', address_1: 'Dummy Address',
                                   address_2: 'Dummy Address Line 2', city: Faker::Address.city, state: State.first, pin_code: "123456"})

  fm = []
  # 4.times do |pos|
    fm << User.create(company: Company.first, first_name: "Finly", last_name: "FinanceManager#{}", email: "finance#{}@finlytest.io",
                      password: "hapitoe007", password_confirmation: "hapitoe007", company_id: c.id, mobile_number: random_mobile_number,
                      role_mapping_attributes: [{user_role_id: UserRole.finance_manager_id},
                                                {user_role_id: UserRole.employee_id}],
                      profile_attributes: {date_of_birth: Faker::Date.backward(365), gender: 'm', address_1: 'Dummy Address',
                                           address_2: 'Dummy Address Line 2', city: Faker::Address.city, state: State.first, pin_code: "123456"})

  # end
  m = []
  # 6.times do ||
    m << User.create(company: Company.first, first_name: "Finly", last_name: "Manager#{}", email: "manager#{}@finlytest.io",
                     password: "hapitoe007", password_confirmation: "hapitoe007", company_id: c.id, mobile_number: random_mobile_number,
                     role_mapping_attributes: [{user_role_id: 3},
                                               {user_role_id: UserRole.employee_id}],
                     profile_attributes: {date_of_birth: Faker::Date.backward(365), gender: 'm', address_1: 'Dummy Address',
                                          address_2: 'Dummy Address Line 2', city: Faker::Address.city, state: State.first, pin_code: "123456"})
  # end

  u = []

  u << User.create(company: Company.first, first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, email: "user0@finlytest.io",
                   password: "hapitoe007", password_confirmation: "hapitoe007", company_id: c.id, mobile_number: random_mobile_number,
                   role_mapping_attributes: [{user_role_id: 4},
                                             {user_role_id: UserRole.employee_id}],
                   team_mapping_attributes: [{default: true, manager: m[0], finance_manager: fm[0]}],
                   profile_attributes: {date_of_birth: Faker::Date.backward(365), gender: 'm', address_1: 'Dummy Address',
                                        address_2: 'Dummy Address Line 2', city: Faker::Address.city, state: State.first, pin_code: "123456"})

  # 10.times do ||
    u << User.create(company: Company.first, first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, email: "#{Faker::Internet.user_name}@finlytest.io",
                     password: "hapitoe007", password_confirmation: "hapitoe007", company_id: c.id, mobile_number: random_mobile_number,
                     role_mapping_attributes: [{user_role_id: 4},
                                               {user_role_id: UserRole.employee_id}],
                     team_mapping_attributes: [{default: true, manager: m[0], finance_manager: fm[0]}],
                     profile_attributes: {date_of_birth: Faker::Date.backward(365), gender: 'm', address_1: 'Dummy Address',
                                          address_2: 'Dummy Address Line 2', city: Faker::Address.city, state: State.first, pin_code: "123456"})
  # end

  m[0].team_mapping.default.first.update_attributes(approves_to: m[1])
  m[0].team_mapping.build(approves_to: m[2], greater_than_amount_attributes: {currency: Currency.first, value: 500}).save
  u[0].team_mapping.build(manager: m[3], greater_than_amount_attributes: {currency: Currency.first, value: 1000}).save

  fm[0].team_mapping.default.first.update_attributes(approves_finance_to: fm[1])
  fm[0].team_mapping.build(approves_finance_to: fm[2], greater_than_amount_attributes: {currency: Currency.first, value: 1000}).save
  u[0].team_mapping.build(finance_manager: fm[3], greater_than_amount_attributes: {currency: Currency.first, value: 2000}).save


  User.all.each do |user|
    user.confirm
  end

end

if Policy.non_default.count == 0
  a = User.first
  p = Policy::Create.(a, {name: 'Test Policy'})
  p = Policy.find_by(name: "Test Policy")
  p.configuration.update_attribute(:require_category, true) if p.present?
  Policy::Users::AddUser.(a, {view: 'admin', policy_id: p.id, user_id: "#{u[0].id}"})
  # PolicyUserService.new(p).add_user(u[0], false)
  u[0].team_mapping.policy(p).default.first.update_attribute(:manager_id, m[0].id)
  p2 = Policy::Create.(a, {name: 'Another test Policy'})
  p2 = Policy.find_by(name: 'Another test Policy')
  u.each do |user|
    Policy::Users::AddUser.(a, {view: 'admin', policy_id: p2.id, :user_id => "#{user.id}"})
    # PolicyUserService.new(p2).add_user(user, false)
  end
end

if ExpenseType.count ==0
  ExpenseType.create(id: 1, name: "Manual")
  ExpenseType.create(id: 2, name: "Card")
  ExpenseType.create(id: 3, name: "Distance")
  ExpenseType.create(id: 4, name: "Time")
  ExpenseType.create(id: 5, name: "Per Diem")
end

if ExpenseStatus.count ==0
  ExpenseStatus.create(id: 1, name: "Unreported", order: 1)
  ExpenseStatus.create(id: 2, name: "Unsubmitted", order: 2)
  ExpenseStatus.create(id: 3, name: "Submitted", order: 3)
  ExpenseStatus.create(id: 4, name: "Rejected", order: 4)
  ExpenseStatus.create(id: 5, name: "Cancelled", order: 5)
end

if Expense.count == 0
  # junk manual expenses
  10.times do |i|
    Expense.create(amount_attributes: {value: random(100, 1000), currency_id: 1},
                   expense_status_id: 1,
                   expense_type_id: 1,
                   note: "#{Faker::Lorem.sentence}",
                   date: Faker::Date.between(20.days.ago, DateUtils.local_date),
                   user_id: random_integer(1, 5),
                   category_id: random_integer(1, 5),
                   manual_expense_attributes: {merchant: "#{Faker::Company.name}"})
  end


end

if Receipt.count == 0
  receipt = Receipt.create(image: File.open(Rails.root + "app/assets/images/1363397.png", "r"),
                           user_id: 1)
  receipt.parent = Expense.where(user_id: 1).where(expense_type_id: 1).first
  receipt.save
end

if ExpenseRuleType.count == 0
  e = ExpenseRuleType.create!(name: "Require Receipt")
  e = ExpenseRuleType.create!(name: "Require Note")
  e = ExpenseRuleType.create!(name: "Disallow Expense")
end

if RuleType.count == 0
  e = RuleType.create!(name: "Warning")
  e = RuleType.create!(name: "Blocking")
end

if Period.count == 0
  b = Period.create!(name: "Day")
  b = Period.create!(name: "Week")
  b = Period.create!(name: "Month")
  b = Period.create!(name: "Quarter")
  b = Period.create!(name: "Year")
end

p = Policy.find(3)
if p.rules_count == 0
  # warning rule that requires a receipt for expenses above 50
  r = p.expense_rules.create!(greater_than_amount_attributes: {value: 50, currency_id: 1},
                              category_id: 1,
                              rule_type_id: 1,
                              expense_rule_type_id: 1)
  # warning rule that requires a note for expense above 50
  r = p.expense_rules.create!(greater_than_amount_attributes: {value: 50, currency_id: 1},
                              category_id: 1,
                              rule_type_id: 1,
                              expense_rule_type_id: 2)

  # setting monthly budget for category 1 as 100 in INR
  b = p.budget_rules.create!(amount_attributes: {value: 100, currency_id: 1},
                             category_id: 1,
                             period_id: 3,
                             rule_type_id: 1)
  # set monthly budget for all expenses as 150 INR
  b = p.budget_rules.create!(amount_attributes: {value: 150, currency_id: 1},
                             period_id: 3,
                             rule_type_id: 2)
end

if PaymentType.count == 0
  PaymentType::TYPES.each do |key, value|
    PaymentType.create id: value, name: key
  end
end

if Report.count == 0
  c.users.all.each do |user|

    # creating open reports
    # 3.times.each do
      report = Report::Create.(user, {name: Faker::Commerce.product_name}).report

      expenses = []
      expenses_ids = []
      2.times.each do
        e = user.expenses.create(amount_attributes: {value: Faker::Commerce.price, currency_id: 1},
                                 manual_expense_attributes: {merchant: Faker::Company.name},
                                 category_id: random_integer(1, 8), expense_status_id: 1, expense_type_id: 1, date: DateUtils.local_date,
                                 receipts_attributes: [])
        expenses << e
        expenses_ids << e.id
      end
      Report::Expenses::Add.(user, {expense_ids: expenses_ids, report_id: report.id})
    # end

    # creating submitted reports
    # 3.times.each do
      report = Report::Create.(user, {name: Faker::Commerce.product_name}).report

      expenses = []
      expenses_ids = []
      2.times.each do
        e = user.expenses.create(amount_attributes: {value: Faker::Commerce.price, currency_id: 1},
                                 manual_expense_attributes: {merchant: Faker::Company.name},
                                 category_id: random_integer(1, 8), expense_status_id: 1, expense_type_id: 1, date: DateUtils.local_date,
                                 receipts_attributes: [])
        expenses << e
        expenses_ids << e.id
      end
      Report::Expenses::Add.(user, {expense_ids: expenses_ids, report_id: report.id})
      Report::Submit.(user, {report_id: report.id})
    # end

    # creating approved reports
    # 3.times.each do
      report = Report::Create.(user, {name: Faker::Commerce.product_name}).report

      expenses = []
      expenses_ids = []
      2.times.each do
        e = user.expenses.create(amount_attributes: {value: Faker::Commerce.price, currency_id: 1},
                                 manual_expense_attributes: {merchant: Faker::Company.name},
                                 category_id: random_integer(1, 8), expense_status_id: 1, expense_type_id: 1, date: DateUtils.local_date,
                                 receipts_attributes: [])
        expenses << e
        expenses_ids << e.id
      end
      Report::Expenses::Add.(user, {expense_ids: expenses_ids, report_id: report.id})
      Report::Submit.(user, {report_id: report.id})
      report.reload
      while report.controlling_user.present?
        Report::Approve.(report.controlling_user, {report_id: report.id})
        report.reload
      end
    end
  # end
end

if CardType.count == 0
  CardType.create(id: 1, name: 'Physical')
  CardType.create(id: 2, name: 'Virtual')
end

if Card.count == 0
  # Company.all.each do |company|
  #   5.times do
  #     number = random_mobile_number
  #     company.cards.create(proxy: number, ending_number: '1234', description: 'Unassigned company card',
  #                          product_code: 'NGPRHD',
  #                          card_type_id: random_integer(1, 3))
  #   end
  # end

  User.all.each do |user|
    if user.id < 6
      number = "S0001774009#{(user.id - 1)}"
      user.cards.create(proxy: number, description: "Test physical card for user #{user.id}", product_code: 'NGPRHD',
                        card_type_id: 1, company_id: user.company.id, ending_number: random(1000, 9999).to_i, active: true)
    end
  end
end

# creating some junk transactions and card expenses for testing
if CardTransaction.count == 0
  User.all.each do |user|
    next unless user.cards.present?
    card = user.cards.first
    20.times do

      trans_types = ["POS", "ATM", "Ecom"]
      trans_modes = ["Debit", "Credit"]
      from_date = Date.parse("01-01-2016 12:00:00")
      to_date = DateTime.now
      random_amount = random_integer(50,200) + 0.1234
      sample_msg_queue_entry = "321744RUPP00035088860000001306,#{from_date + (to_date - from_date)*rand},#{random_amount},#{random_amount + random(5,10)},173244,#{trans_types[random_integer(0, 2000)%3]},OLCDCB_POSOFFUS,#{Faker::Space.moon},91,#{trans_modes[random_integer(0,2000)%2]},#{card.proxy},RBLRUP"

      data = sample_msg_queue_entry.split(",")

      # for the split between merchant city and merchant name
      name_city = data[7].split("\t") # splits the sixth field after the comma into name and city
      merchant_name = name_city[0]
      merchant_city = name_city[1]

      trans_params = {reference_id: data[0],
                      transaction_timestamp: data[1],
                      transaction_amount_attributes: {value: data[2], currency_id: 1},
                      billing_amount_attributes: {value: data[3], currency_id: 1},
                      auth_transaction_id: data[4],
                      transaction_mode: data[5],
                      itzcash_merchant_key: data[6],
                      merchant_name: merchant_name,
                      merchant_city: merchant_city,
                      response_code: data[8],
                      transaction_type: data[9],
                      serial_id: data[10],
                      product_code: data[11]
      }

      trans = Card::Transaction::Create.(trans_params).transaction

      # random_amount = random(10, 1000)
      #
      # trans = CardTransaction.create(user_id: user.id,
      #                                transaction_amount_attributes: {value: random_amount, currency_id: 1},
      #                                transaction_timestamp: DateUtils.local_date_time,
      #                                merchant_name: 'Randomness',
      #                                serial_id: card.proxy)
      # junk card expense
      # Expense.create(amount_attributes: {value: trans.transaction_amount.value, currency_id: 1},
      #                expense_status_id: 1,
      #                expense_type_id: 2,
      #                note: "This is a card expense, hello! #{trans.id}",
      #                date: trans.transaction_timestamp.to_date,
      #                user_id: user.id,
      #                category_id: random_integer(1, 5),
      #                card_expense_attributes: {editable_merchant: "#{Faker::Company.name}",
      #                                          card_transaction_id: trans.id})
    end
  end
end

# temporary otp verification all numbers in db
User.all.each do |user|
  user.update_attributes(otp: nil, otp_verified_at: DateTime.now, otp_verified: true)
end

# if AdminUser.count == 0
#   # creating admin panel users who can access admin panel
#   AdminUser.create!(email: 'admin@finly.io', password: 'hapitoe007', password_confirmation: 'hapitoe007')
#   AdminUser.create!(email: 'sreeram@finly.io', password: 'hapitoe007', password_confirmation: 'hapitoe007')
#   AdminUser.create!(email: 'vivek@finly.io', password: 'hapitoe007', password_confirmation: 'hapitoe007')
#   AdminUser.create!(email: 'veekshith@finly.io', password: 'hapitoe007', password_confirmation: 'hapitoe007')
#   AdminUser.create!(email: 'bala@finly.io', password: 'hapitoe007', password_confirmation: 'hapitoe007')
# end
# User.all.each do |user|
#     next unless user.cards.present?
#     card = user.cards.first
#     20.times do
#
#       trans_types = ["POS", "ATM", "Ecom"]
#       trans_modes = ["Debit", "Credit"]
#       from_date = Date.parse("01-01-2016 12:00:00")
#       to_date = DateTime.now
#       random_amount = random_integer(50,200) + 0.1234
#       sample_msg_queue_entry = "321744RUPP00035088860000001306,#{from_date + (to_date - from_date)*rand},#{random_amount},#{random_amount + random(5,10)},173244,#{trans_types[random_integer(0, 2000)%3]},OLCDCB_POSOFFUS,#{Faker::Space.moon},91,#{trans_modes[random_integer(0,2000)%2]},#{card.proxy},RBLRUP"
#
#       data = sample_msg_queue_entry.split(",")
#
#       # for the split between merchant city and merchant name
#       name_city = data[7].split("\t") # splits the sixth field after the comma into name and city
#       merchant_name = name_city[0]
#       merchant_city = name_city[1]
#
#       trans_params = {reference_id: data[0],
#                       transaction_timestamp: data[1],
#                       transaction_amount_attributes: {value: data[2], currency_id: 1},
#                       billing_amount_attributes: {value: data[3], currency_id: 1},
#                       auth_transaction_id: data[4],
#                       transaction_mode: data[5],
#                       itzcash_merchant_key: data[6],
#                       merchant_name: merchant_name,
#                       merchant_city: merchant_city,
#                       response_code: data[8],
#                       transaction_type: data[9],
#                       serial_id: data[10],
#                       product_code: data[11]
#       }
#
#       trans = Card::Transaction::Create.(trans_params).transaction
#     end
# end


