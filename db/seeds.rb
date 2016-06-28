# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# UserManagerMapping.delete_all
# User.delete_all
# UserType.delete_all
# CompanyConfiguration.delete_all
# Company.delete_all

if UserType.count == 0
  UserType.create!(id: 1, name: "Admin")
  UserType.create!(id: 2, name: "Finance Manager")
  UserType.create!(id: 3, name: "Manager")
  UserType.create!(id: 4, name: "Employee")
  UserType.create!(id: 5, name: "Auditor")
end

if Currency.count == 0
  Currency.create!(country: "India", country_code: "INR")
end

if Amount.count == 0
  Amount.create!(id: 1, currency: Currency.first, value: 0)
end

if Company.count == 0
  c = Company.create!(name: 'Finly')
  c.reload
else
  c = Company.first
end

if User.count == 0
  admin = User.create!(name: "Finly Admin", email: "admin@finlytest.io", user_type_id: 1,
                       password: "hapitoe007", password_confirmation: "hapitoe007", company_id: c.id)
  finance_manager = User.create!(name: "Finly Finance Manager", email: "finance@finlytest.io", user_type_id: 2,
                                 password: "hapitoe007", password_confirmation: "hapitoe007", company_id: c.id)
  finance_manager_2 = User.create!(name: "Finly Finance Manager 2", email: "finance2@finlytest.io", user_type_id: 2,
                                   password: "hapitoe007", password_confirmation: "hapitoe007", company_id: c.id)
  manager = User.create!(name: "Finly Manager", email: "manager@finlytest.io", user_type_id: 3,
                         password: "hapitoe007", password_confirmation: "hapitoe007", company_id: c.id)
  manager_2 = User.create!(name: "Finly Manager 2", email: "manager2@finlytest.io", user_type_id: 3,
                           password: "hapitoe007", password_confirmation: "hapitoe007", company_id: c.id)
  user = User.create!(name: "Finly Employee", email: "user@finlytest.io", user_type_id: 4,
                      password: "hapitoe007", password_confirmation: "hapitoe007", company_id: c.id)
  user.reload

  user.team_mapping.default.update_attributes(manager: manager_2, finance_manager: finance_manager_2)
  a1 = Amount.create!(currency: Currency.first, value: 500)
  UserManagerMapping.create!(user: user, manager: manager, greater_than_amount: a1)
  a2 = Amount.create!(currency: Currency.first, value: 1000)
  UserManagerMapping.create!(user: user, finance_manager: finance_manager, greater_than_amount: a2)

end