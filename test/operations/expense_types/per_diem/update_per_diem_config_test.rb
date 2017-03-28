require 'test_helper'

class UpdatePerDiemConfigTest < ActiveSupport::TestCase

  def setup
    @company = Company.first
    @admin = User.first
    @finance_manager = User.second
    @manager = User.third

    @update_params = {per_diem_expense_config: {enabled: "true"

                                               }
                     }
  end

  test "admins can update the per diem config on the company level" do

  end

  test "policy admins can update per diem config on the policy level" do

  end
end