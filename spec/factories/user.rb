# require './company'
FactoryBot.define do

  sequence :user_email do |n|
    "user#{n}@example.com"
  end

  sequence :manager_name do |n|
    "Manager#{n}"
  end

  sequence :finance_name do |n|
    "Finance#{n}"
  end

  sequence :creditor_name do |n|
    "Creditor#{n}"
  end

  sequence :admin_name do |n|
    "Admin#{n}"
  end

  sequence :travel_name do |n|
    "Travel#{n}"
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


  factory :user do
    first_name {"User"}
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
        last_name {generate(:manager_name)}
        role_mapping_attributes {[
            {user_role_id: 4, purpose_id: 1},
            {user_role_id: 3, purpose_id: 1}
        ]}
      end

      factory :em_finance_user do
        last_name {generate(:finance_name)}
        role_mapping_attributes {[
            {user_role_id: 4, purpose_id: 1},
            {user_role_id: 2, purpose_id: 1}
        ]}
      end

      factory :em_admin_user do
        last_name {generate(:admin_name)}
        role_mapping_attributes {[
            {user_role_id: 4, purpose_id: 1},
            {user_role_id: 1, purpose_id: 1}
        ]}
      end

      factory :em_travel_user do
        last_name {generate(:travel_name)}
        role_mapping_attributes {[
            {user_role_id: 4, purpose_id: 1},
            {user_role_id: 6, purpose_id: 1}
        ]}
      end
    end
    factory :vp_user do
      user_panel_subscription_attributes {{yes_bank_account_transfer: true}}

      factory :vp_initiator_user do
        role_mapping_attributes { [{user_role_id: 4, purpose_id: 2}] }
      end

      factory :vp_reviewer_user do
        role_mapping_attributes {[
            {user_role_id: 4, purpose_id: 2},
            {user_role_id: 3, purpose_id: 2}
        ]}
      end

      factory :vp_creditor_user do
        role_mapping_attributes {[
            {user_role_id: 4, purpose_id: 2},
            {user_role_id: 2, purpose_id: 2}
        ]}
      end

      factory :vp_admin_user do
        role_mapping_attributes {[
            {user_role_id: 4, purpose_id: 2},
            {user_role_id: 1, purpose_id: 2}
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
