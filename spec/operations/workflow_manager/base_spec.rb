require 'rails_helper'

# Employee
# Manager1, Manager2, Manager3
# Finance Manager

# Create policy
# Create Levels
# Create Workflow


# Create Expenses
# Create Report

# Pass through output with action

# Create

RSpec.describe WorkflowManager::Base do
  describe "Workflow Manager Do" do
    before(:all) do
      # Create Users
      @em_employee_user1 = create(:em_employee_user)
      @em_reviewer_user1 = create(:em_reviewer_user)
      @em_reviewer_user2 = create(:em_reviewer_user)
      @em_reviewer_user3 = create(:em_reviewer_user)
      @em_finance_user1 = create(:em_finance_user)




    end
    it 'user is defined' do
      expect(@user1).to be_valid
    end
  end
end
