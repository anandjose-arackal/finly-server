# require './company'
FactoryBot.define do

  sequence :user_email do |n|
    "user#{n}@example.com"
  end

  sequence :mobile_number do |n|
    "987654321#{n}"
  end


  factory :user do
    company_id {nil}
    first_name {"Joe"}
    last_name {"Doe"}
    email {generate(:user_email)}
    password {"password"}
    mothers_maiden_name {"XX"}
    mobile_number {generate(:mobile_number)}

    # user_panel_subscription_attributes {{expense_management: true}}
    # role_mapping_attributes { {user_role_id: 4, purpose_id: 1} }
    # user_panel_subscription_attributes { {expense_management: true} }
    # role_mapping_attributes { [] }

    # before(:create) { |user|
    #   user.role_mapping.build( [attributes_for( :user_role_mapping )] )
    # }

    factory :em_user do
      user_panel_subscription_attributes {{expense_management: true}}

      factory :em_employee_user do
        role_mapping_attributes { [{user_role_id: 4, purpose_id: 1}] }
      end

      factory :em_reviewer_user do
        role_mapping_attributes {[
            {user_role_id: 4, purpose_id: 1},
            {user_role_id: 3, purpose_id: 1}
        ]}
      end

      factory :em_finance_user do
        role_mapping_attributes {[
            {user_role_id: 4, purpose_id: 1},
            {user_role_id: 2, purpose_id: 1}
        ]}
      end

      factory :em_admin_user do
        role_mapping_attributes {[
            {user_role_id: 4, purpose_id: 1},
            {user_role_id: 1, purpose_id: 1}
        ]}
      end

      factory :em_travel_user do
        role_mapping_attributes {[
            {user_role_id: 4, purpose_id: 1},
            {user_role_id: 6, purpose_id: 1}
        ]}
      end
    end
  end

  # factory :user_panel_subscription do
  #   expense_management {true}
  # end
  #
  # factory :user_role_mapping do
  #   user
  #   user_role_id {4} #employee
  #   purpose_id {1} # Expense Management
  # end


end



# This will use the User class (otherwise Admin would have been guessed)
# factory :admin, class: User

# Passing a block to any of the methods above will yield the return object
# create(:user) do |user|
#   user.posts.create(attributes_for(:post))
# end