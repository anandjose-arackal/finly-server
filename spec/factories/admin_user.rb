# require './company'
FactoryBot.define do

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