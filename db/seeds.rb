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
  random(low, 5).to_i
end

def random_string_of_numbers(length)
  (0...length).map { (48 + rand(10)).chr }.join
end

ballzy_employees = [{"name"=>"Rajesh","email"=>"rajesh@abc.com"},
                    {"name"=>"Sachin","email"=>"sachin@abc.com"},
                    {"name"=>"Rinju","email"=>"rinju@abc.com"},
                    {"name"=>"Prateek","email"=>"prateek@abc.com"},
                    {"name"=>"Jothi","email"=>"jothi@abc.com"},
                    {"name"=>"Angeline","email"=>"angeline@abc.com"},
                    {"name"=>"Dipti","email"=>"Dipti@abc.com"},
                    {"name"=>"Ani","email"=>"Ani@abc.com"},
                    {"name"=>"Telecaller 1 ","email"=>"tele1@abc.com"},
                    {"name"=>"Telecaller 2","email"=>"tele2@abc.com"},
                    {"name"=>"Telecaller 3","email"=>"tele3@abc.com"},
                    {"name"=>"Telecaller 4","email"=>"tele4@abc.com"},
                    {"name"=>"Zonal1","email"=>"zonal1@abc.com"},
                    {"name"=>"Zonal2","email"=>"zonal2@abc.com"},
                    {"name"=>"MumTl1","email"=>"mumtl1@abc.com"},
                    {"name"=>"MumTl2","email"=>"mumtl2@abc.com"},
                    {"name"=>"DelTl","email"=>"deltl@abc.com"},
                    {"name"=>"HydTl","email"=>"hydtl@abc.com"},
                    {"name"=>"BlrTl","email"=>"blrtl@abc.com"},
                    {"name"=>"F1","email"=>"f1@abc.com"},
                    {"name"=>"F2","email"=>"f2@abc.com"},
                    {"name"=>"F3","email"=>"f3@abc.com"},
                    {"name"=>"F4","email"=>"f4@abc.com"},
                    {"name"=>"F5","email"=>"f5@abc.com"},
                    {"name"=>"F6","email"=>"f6@abc.com"},
                    {"name"=>"F7","email"=>"f7@abc.com"},
                    {"name"=>"F8","email"=>"f8@abc.com"},
                    {"name"=>"F9","email"=>"f9@abc.com"},
                    {"name"=>"F10","email"=>"f10@abc.com"},
                    {"name"=>"Nav","email"=>"nav@abc.com"},
                    {"name"=>"Rupali","email"=>"rupali@abc.com"},
                    {"name"=>"Jaya","email"=>"jaya@abc.com"},
                    {"name"=>"Malavika","email"=>"mala@abc.com"},
                    {"name"=>"csr1","email"=>"csr1@abc.com"},
                    {"name"=>"csr2","email"=>"csr2@abc.com"},
                    {"name"=>"csr3","email"=>"csr3@abc.com"}]

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
  c = Company.create(name: 'Finly')
  c.reload

  ballzy = Company.create(name: 'Ballzy Co.')
  ballzy.reload
else
  c = Company.first
end

if c.categories.count ==
    10.times do |i|
      c.categories.create!(name: "Test category #{i+1}")
    end
end

if User.count == 0
  a = User.create(company: Company.first, name: "Finly Admin", email: "admin@finlytest.io",
                  password: "hapitoe007", password_confirmation: "hapitoe007", company_id: c.id, mobile_number: random_string_of_numbers(10),
                  role_mapping_attributes: [{user_role_id: UserRole.admin_id},
                                            {user_role_id: UserRole.employee_id}])

  User.create(company: Company.first, name: "Finly King", email: "king@finlytest.io",
              password: "hapitoe007", password_confirmation: "hapitoe007", company_id: c.id, mobile_number: random_string_of_numbers(10),
              role_mapping_attributes: [{user_role_id: UserRole.admin_id}, {user_role_id: UserRole.manager_id},
                                        {user_role_id: UserRole.finance_manager_id}, {user_role_id: UserRole.employee_id}])

  User.create(company: Company.first, name: "Vivek", email: "vivek.a@finly.io", mobile_number: random_string_of_numbers(10),
              password: "hapitoe007", password_confirmation: "hapitoe007", company_id: c.id,
              role_mapping_attributes: [{user_role_id: UserRole.admin_id},{user_role_id: UserRole.manager_id},
                                        {user_role_id: UserRole.finance_manager_id},{user_role_id: UserRole.employee_id}])


  fm = []
  4.times do |pos|
    fm << User.create(company: Company.first, name: "Finly Finance Manager #{pos}", email: "finance#{pos}@finlytest.io",
                      password: "hapitoe007", password_confirmation: "hapitoe007", company_id: c.id, mobile_number: random_string_of_numbers(10),
                      role_mapping_attributes: [{user_role_id: UserRole.finance_manager_id},
                                                {user_role_id: UserRole.employee_id}])

  end
  m = []
  6.times do |pos|
    m << User.create(company: Company.first, name: "Finly Manager #{pos}", email: "manager#{pos}@finlytest.io",
                     password: "hapitoe007", password_confirmation: "hapitoe007", company_id: c.id, mobile_number: random_string_of_numbers(10),
                     role_mapping_attributes: [{user_role_id: 3},
                                               {user_role_id: UserRole.employee_id}])
  end

  u = []
  10.times do |pos|
    u << User.create(company: Company.first, name: Faker::Name.name, email: "#{Faker::Internet.user_name}@finlytest.io",
                     password: "hapitoe007", password_confirmation: "hapitoe007", company_id: c.id, mobile_number: random_string_of_numbers(10),
                     role_mapping_attributes: [{user_role_id: 4},
                                               {user_role_id: UserRole.employee_id}],
                     team_mapping_attributes: [{default: true, manager: m[0], finance_manager: fm[0]}])
  end

  m[0].team_mapping.default.first.update_attributes(approves_to: m[1])
  m[0].team_mapping.build(approves_to: m[2], greater_than_amount_attributes: {currency: Currency.first, value: 500}).save
  u[0].team_mapping.build(manager: m[3], greater_than_amount_attributes: {currency: Currency.first, value: 1000}).save

  fm[0].team_mapping.default.first.update_attributes(approves_finance_to: fm[1])
  fm[0].team_mapping.build(approves_finance_to: fm[2], greater_than_amount_attributes: {currency: Currency.first, value: 1000}).save
  u[0].team_mapping.build(finance_manager: fm[3], greater_than_amount_attributes: {currency: Currency.first, value: 2000}).save

  # creating ballzy admin
  bala = User.create(name: "Balakumar Rajaraman", email: "balakumar.rajaram@gmail.com",
                     password: "hapitoe007", password_confirmation: "hapitoe007", company_id: ballzy.id, mobile_number: random_string_of_numbers(10),
                     role_mapping_attributes: [{user_role_id: UserRole.admin_id},
                                               {user_role_id: UserRole.employee_id}])


  # creating ballzy employees
  ballzy_users = []
  ballzy_employees.each do |employee|
    employee[:password] = employee[:password_confirmation] = "hapitoe007"
    employee[:company_id] = ballzy.id
    employee[:mobile_number] = random_string_of_numbers(10)
    employee[:role_mapping_attributes] = [{user_role_id: UserRole.employee_id}]

    ballzy_users << User.create(employee)
  end


  User.all.each do |user|
    user.confirm
  end
end

if Policy.non_default.count == 0
  p = PolicyCreateService.new(a).create_policy('Test Policy')
  p.configuration.update_attribute(:require_category, true) if p.present?
  PolicyUserService.new(p).add_user(u[0], false)
  u[0].team_mapping.policy(p).default.first.update_attribute(:manager_id, m[4].id)

  p2 = PolicyCreateService.new(a).create_policy('Another test Policy')
  u.each do |user|
    PolicyUserService.new(p2).add_user(user, false)
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
end

if Expense.count == 0
  200.times do |i|
    Expense.create(amount_attributes: {value: random(100, 1000), currency_id: 1},
                   expense_status_id: 1,
                   expense_type_id: 1,
                   note: "#{Faker::Lorem.sentence}",
                   date: Faker::Date.between(20.days.ago, Date.today),
                   user_id: random_integer(1, 10),
                   category_id: random_integer(1, 10),
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

if BudgetPeriod.count == 0
  b = BudgetPeriod.create!(name: "Day")
  b = BudgetPeriod.create!(name: "Week")
  b = BudgetPeriod.create!(name: "Month")
  b = BudgetPeriod.create!(name: "Year")
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
                             budget_period_id: 3,
                             rule_type_id: 1)
  # set monthly budget for all expenses as 150 INR
  b = p.budget_rules.create!(amount_attributes: {value: 150, currency_id: 1},
                             budget_period_id: 3,
                             rule_type_id: 2)
end

if PaymentType.count == 0
  PaymentType.create(id: 1, name: 'Advance')
  PaymentType.create(id: 2, name: 'Debt Clearance')
  PaymentType.create(id: 3, name: 'Reimbursement')
  PaymentType.create(id: 4, name: 'Settlement')
end

if Report.count == 0
  c.users.all.each do |user|
    3.times.each do
      report = ReportService.new(user: user).create
      report_service = ReportService.new(user: user, report: report)

      expenses = []
      expenses_ids = []
      5.times.each do
        e = user.expenses.create(amount_attributes: {value: Faker::Commerce.price, currency_id: 1},
                                 manual_expense_attributes: {merchant: Faker::Company.name},
                                 category_id: random_integer(1,8), expense_status_id: 1, expense_type_id: 1, date: Date.today,
                                 receipts_attributes: [])
        expenses << e
        expenses_ids << e.id
      end
      report_service.add_expense(expenses_ids)
    end
    3.times.each do
      report = ReportService.new(user: user).create
      report_service = ReportService.new(user: user, report: report)

      expenses = []
      expenses_ids = []
      5.times.each do
        e = user.expenses.create(amount_attributes: {value: Faker::Commerce.price, currency_id: 1},
                                 manual_expense_attributes: {merchant: Faker::Company.name},
                                 category_id: random_integer(1,8), expense_status_id: 1, expense_type_id: 1, date: Date.today,
                                 receipts_attributes: [])
        expenses << e
        expenses_ids << e.id
      end
      report_service.add_expense(expenses_ids)
      report_service.submit
    end
    3.times.each do
      report = ReportService.new(user: user).create
      report_service = ReportService.new(user: user, report: report)

      expenses = []
      expenses_ids = []
      5.times.each do
        e = user.expenses.create(amount_attributes: {value: Faker::Commerce.price, currency_id: 1},
                                 manual_expense_attributes: {merchant: Faker::Company.name},
                                 category_id: random_integer(1,8), expense_status_id: 1, expense_type_id: 1, date: Date.today,
                                 receipts_attributes: [])
        expenses << e
        expenses_ids << e.id
      end
      report_service.add_expense(expenses_ids)
      report_service.submit
      while report.controlling_user.present?
        ReportService.new(user: report.controlling_user, report: report).approve
      end
    end
  end
end

if CardType.count == 0
  CardType.create(name: "Physical")
  CardType.create(name: "Virtual")
  CardType.create(name: "Reimbursement")
end

if Card.count == 0
  Company.all.each do |company|
    5.times do
      number = random_string_of_numbers(10)
      c = company.cards.create(proxy: number, ending_number: number[6..9], description: "Unassigned company card.",
                               card_type_id: random_integer(1, 3))
    end
  end

  User.all.each do |user|
    number = random_string_of_numbers(10)
    c = user.cards.create(proxy: number, ending_number: number[6..9], description: "Test physical card for user #{user.id}",
                          card_type_id: 1, company_id: user.company.id, active: true)
    number = random_string_of_numbers(10)
    c = user.cards.create(proxy: number, ending_number: number[6..9], description: "Test virtual card for user #{user.id}",
                          card_type_id: 2, company_id: user.company.id, active: true)
    number = random_string_of_numbers(10)
    c = user.cards.create(proxy: number, ending_number: number[6..9], description: "Test reimbursement card for user #{user.id}",
                          card_type_id: 3, company_id: user.company.id, active: true)
  end
end

# creating some junk transactions for testing
if CardTransaction.count == 0
  User.all.each do |user|
    card = user.cards.first
    c = CardTransaction.create(card_id: card.id, user_id: user.id,
                               transaction_amount_attributes: {value: 100, currency_id: 1},
                               date: Date.today,
                               merchant_name: "Randomness.",
                               transaction_currency_code: "INR")
  end
end