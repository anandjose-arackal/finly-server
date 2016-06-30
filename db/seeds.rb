# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

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

if ExpenseType.count ==0

end

if ExpenseStatus.count ==0

end

if Expense.count == 0
  e = Expense.create(amount_attributes: {value: 100, currency_id: 1}, expense_status_attributes: {name: "Unsubmitted", order: 1}, expense_type_attributes: {name: "Manual Expense"}, note: "Sup", date: Date.today, user_id: 1)
end

