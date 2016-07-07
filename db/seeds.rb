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
  random(low, high+1).to_i
end


if UserRole.count == 0
  UserRole.create(id: 1, name: "Admin")
  UserRole.create(id: 2, name: "Finance Manager")
  UserRole.create(id: 3, name: "Manager")
  UserRole.create(id: 4, name: "Employee")
  UserRole.create(id: 5, name: "Auditor")
end

if Currency.count == 0
  Currency.create(country: "India", country_code: "INR")
end

if Amount.count == 0
  Amount.create(id: 1, currency: Currency.first, value: 0)
end

if Company.count == 0
  c = Company.create(name: 'Finly')
  c.reload
else
  c = Company.first
end

if c.categories.count == 0
  cat = c.categories.create!(name: "Test category")
end

if User.count == 0
  a = User.create(company: Company.first, name: "Finly Admin", email: "admin@finlytest.io",
                  password: "hapitoe007", password_confirmation: "hapitoe007", company_id: c.id, role_mapping_attributes: [{user_role_id: 1}])
  fm = []
  4.times do |pos|
    fm << User.create(company: Company.first, name: "Finly Finance Manager #{pos}", email: "finance#{pos}@finlytest.io",
                      password: "hapitoe007", password_confirmation: "hapitoe007", company_id: c.id, role_mapping_attributes: [{user_role_id: 2}])
  end
  m = []
  6.times do |pos|
    m << User.create(company: Company.first, name: "Finly Manager #{pos}", email: "manager#{pos}@finlytest.io",
                     password: "hapitoe007", password_confirmation: "hapitoe007", company_id: c.id, role_mapping_attributes: [{user_role_id: 3}])
  end
  u = []
  10.times do |pos|
    u << User.create(company: Company.first, name: "Finly Employee #{pos}", email: "user#{pos}@finlytest.io",
                     password: "hapitoe007", password_confirmation: "hapitoe007", company_id: c.id, role_mapping_attributes: [{user_role_id: 4}],
                     team_mapping_attributes: [{default: true, manager: m[0], finance_manager: fm[0]}])
  end

  m[0].team_mapping.default.update_attributes(approves_to_user: m[1])
  m[0].team_mapping.build(approves_to_user: m[2], greater_than_amount_attributes: {currency: Currency.first, value: 500}).save
  u[0].team_mapping.build(manager: m[3], greater_than_amount_attributes: {currency: Currency.first, value: 1000}).save

  fm[0].team_mapping.default.update_attributes(approves_finance_to_user: fm[1])
  fm[0].team_mapping.build(approves_finance_to_user: fm[2], greater_than_amount_attributes: {currency: Currency.first, value: 1000}).save
  u[0].team_mapping.build(finance_manager: fm[3], greater_than_amount_attributes: {currency: Currency.first, value: 2000}).save
end

if Policy.non_default.count == 0
  p = PolicyCreateService.new.create_policy(c,a, 'Test Policy')
  p.configuration.update_attribute(:require_category, true) if p.present?
  PolicyUserService.new(p).add_user(u[0])
  u[0].team_mapping.policy(p).default.update_attribute(:manager_id, m[4].id)

  p = PolicyCreateService.new.create_policy(c,a, 'Another test Policy')
end

if ExpenseType.count ==0
  ExpenseType.create(name: "Manual")
  ExpenseType.create(name: "Card")
  ExpenseType.create(name: "Distance")
  ExpenseType.create(name: "Time")
  ExpenseType.create(name: "Per Diem")
end

if ExpenseStatus.count ==0
  ExpenseStatus.create(name: "Unsubmitted", order: 1)
  ExpenseStatus.create(name: "Submitted", order: 2)
  ExpenseStatus.create(name: "Rejected", order: 3)
end

if Expense.count == 0
  200.times do |i|
    e = Expense.create(amount_attributes: {value: random(0, 100), currency_id: 1},
                       expense_status_id: random_integer(1, 3),
                       expense_type_id: 1,
                       note: "test note #{i}",
                       date: Date.today,
                       user_id: random_integer(1, 10),
                       manual_expense_attributes: {merchant: "Test merchant #{i}"})
  end
end

if Receipt.count == 0
  receipt = Receipt.create(image: File.open(Rails.root + "app/assets/images/1363397.jpg", "r"),
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

if p.rules_count ==0
  r = p.expense_rules.create!(greater_than_amount_attributes: {value: 100, currency_id: 1},
                              category_id: 1,
                              days_after: 20,
                              rule_type_id: 1,
                              expense_rule_type_id: 2)
  b = p.budget_rules.create!(amount_attributes: {value: 100, currency_id: 1},
                             category_id: 1,
                             budget_period_id: 3,
                             rule_type_id: 1)
end

