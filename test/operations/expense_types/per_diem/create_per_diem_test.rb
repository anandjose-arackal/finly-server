require 'test_helper'

class CreatePerDiemTest < ActiveSupport::TestCase

  def setup
    @company = Company.first
    @admin = User.first
    @finance_manager = User.second
    @manager = User.third
    @policy = @company.policies.first

    @valid_per_diem_params = {per_diem: {name: "Something",
                                         rate_attributes: {value: "500",
                                                           currency_id: 1}

                                        },
                              level_id: '1',
                              per_diem_level: 'company'
                             }
    @invalid_per_diem_params = {per_diem: {name: "",
                                           rate_attributes: {value: "500",
                                                           currency_id: 1}

                                          },
                                level_id: 2,
                                per_diem_level: 'policy'
                               }
  end

  test "company admins can create per diems for companies" do
    # mocking the fact that this user is the admin
    @admin.stubs(:company_admin?).returns(true)
    operation = ExpenseTypes::PerDiem::Create.new(@admin, @valid_per_diem_params)
    assert_difference '@company.per_diems.count', 1 do
      @result = operation.run
    end

    assert_equal true, @result.success?
    assert_equal 500, @result.per_diem.rate_value
    assert_equal "Something", @result.per_diem.name
    assert_equal @admin.company, @result.per_diem.configurable
  end

  test "Company admins can create per diems for policies" do
    @manager.stubs(:policy_admin?).returns(true)
    @manager.stubs(:policy_admin?).with(@policy).returns(true)
    # change the parameters to make it a policy level per diem creation
    @valid_per_diem_params[:level_id] = @policy.id
    @valid_per_diem_params[:per_diem_level] = 'policy'
    operation = ExpenseTypes::PerDiem::Create.new(@manager, @valid_per_diem_params)
    assert_difference '@policy.per_diems.count', 1 do
      @result = operation.run
    end

    assert_equal true, @result.success?
    assert_equal 500, @result.per_diem.rate_value
    assert_equal "Something", @result.per_diem.name
    assert_equal @policy, @result.per_diem.configurable
  end

  test "non admins cannot create per diems at the company or policy level" do

    # first checking for company level per diems
    @manager.stubs(:company_admin?).returns(false)
    # using the valid parameters for creating a per diem
    operation = ExpenseTypes::PerDiem::Create.new(@manager, @valid_per_diem_params)
    assert_no_difference '@company.per_diems.count' do
      begin
        @result = operation.run
      rescue NotAuthorizedException
        @rescued = true
      end
    end
    assert_equal true, @rescued

    # now checking for policy level per diems
    @manager.stubs(:policy_admin?).returns(true)
    @manager.stubs(:policy_admin?).with(@policy).returns(false)

    @valid_per_diem_params[:level_id] = @policy.id
    @valid_per_diem_params[:per_diem_level] = 'policy'
    operation = ExpenseTypes::PerDiem::Create.new(@manager, @valid_per_diem_params)
    assert_no_difference '@policy.per_diems.count' do
      begin
        @result = operation.run
      rescue NotAuthorizedException
        @rescued = true
      end
    end
    assert_equal true, @rescued
  end

  test "admins cannot create a per diem with invalid parameters" do
    # first test without a name
    @admin.stubs(:company_admin?).returns(true)
    operation = ExpenseTypes::PerDiem::Create.new(@admin, @invalid_per_diem_params)
    assert_no_difference '@company.per_diems.count' do
      @result = operation.run
    end

    assert_equal false, @result.success?
    assert_not_empty @result.messages[:error]
    assert_empty @result.messages[:success]
    puts @result.messages[:error].to_sentence

    # now test with a negative amount
    @invalid_per_diem_params[:per_diem][:name] = "Something"
    @invalid_per_diem_params[:per_diem][:rate_attributes][:value] = "-500"
    operation = ExpenseTypes::PerDiem::Create.new(@admin, @invalid_per_diem_params)
    assert_no_difference '@company.per_diems.count' do
      @result = operation.run
    end

    assert_equal false, @result.success?
    assert_not_empty @result.messages[:error]
    assert_empty @result.messages[:success]
    puts @result.messages[:error].to_sentence

  end

end