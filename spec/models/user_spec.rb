require 'rails_helper'

RSpec.describe User, type: :model do
  before(:all) do
    @user = create(:em_employee_user)
  end
  it "is subscribed to expense management" do
    expect(@user.user_panel_subscription.expense_management).to eq(true)
  end
end
