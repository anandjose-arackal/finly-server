# require './company'
FactoryBot.define do

  factory :admin_user do
    first_name {Faker::Name.first_name}
    last_name {Faker::Name.last_name}
    email {generate(:user_email)}
    password {'FW1g$18j0t!k2'}
    mobile_number {generate(:mobile_number)}
    authorized_ip {Faker::Internet.ip_v4_address}

    factory :admin_user_admin do
      admin_user_role_mappings_attributes {[
          {admin_user_role_id: AdminUserRole.id_for(:admin)}
      ]}
    end

  end

end