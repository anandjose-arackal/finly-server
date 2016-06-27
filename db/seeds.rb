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
end

if Company.count == 0
  c = Company.create!(name: 'Finly')
  c.reload
else
  c = Company.first
end

if User.count == 0
  User.create!(name: "Finly Admin", email: "admin@finly.io", user_type_id: 1, password: "hapitoe007", password_confirmation: "hapitoe007", company_id: c.id)
end