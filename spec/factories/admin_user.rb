# require './company'
FactoryBot.define do

  sequence :user_email do |n|
    "user#{n}@example.com"
  end

  sequence :mobile_number do |n|
    if n > 9
      number = "98765432#{n}"
    elsif n > 99
      number = "9876543#{n}"
    else
      number = "987654320#{n}"
    end
    number
  end


  factory :admin_user do
    first_name {Faker::Name.first_name}
    last_name {Faker::Name.last_name}
    email {generate(:user_email)}
    password {'FW1g$18j0t!k2'}
    mothers_maiden_name {"XX"}
    mobile_number {generate(:mobile_number)}
    authorized_ip {Faker::Internet.ip_v4_address}
  end

end