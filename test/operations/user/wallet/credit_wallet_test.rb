require 'test_helper'

class CreditWalletTest < ActiveSupport::TestCase

  def setup
    @admin = users(:admin)
    @manager = users(:manager)
    @finance_manager = users(:finance_manager)
    @employee = users(:employee)
    @card = @employee.cards.first

    @other_employee = users(:second_employee)
    # crediting some money to everyone's walet
    @admin.wallet.add_funds(1000)
    @manager.wallet.add_funds(1000)
    @finance_manager.wallet.add_funds(1000)
    @employee.wallet.add_funds(1000)

    @credit_params = {amount: 30,
                      to_user_id: @employee.id,
                      from_account: :wallet,
                      to_account: :wallet,
                      password: "hapitoe007"
                      }
  end

  test "successfully crediting money to a user's wallet by admin" do
    index_users = User.where(id: @employee.id)
    User::Team::Index.stubs(:call).returns(index_users)
    User::Team::Index.stubs(:success?).returns(true)
    User.any_instance.stubs(:valid_password?).returns(true)

    credit_op = User::Wallet::Credit.new(@admin, @credit_params)
    assert_difference '@admin.payments.initiated_by_user(@admin.id).count', 1 do
      assert_difference '@employee.payments.received_by_user(@employee.id).count', 1 do
        @result = credit_op.run
      end
    end

    assert @result.success?
    assert_equal 1030, @employee.reload.wallet.balance_value
    assert_equal 970, @admin.reload.wallet.balance_value
  end

  test "successful crediting of money to user's wallet by manager" do
    index_users = User.where(id: @employee.id)
    User::Team::Index.stubs(:call).returns(index_users)
    User::Team::Index.stubs(:success?).returns(true)
    User.any_instance.stubs(:valid_password?).returns(true)

    credit_op = User::Wallet::Credit.new(@manager, @credit_params)
    assert_difference '@manager.payments.initiated_by_user(@manager.id).count', 1 do
      assert_difference '@employee.payments.received_by_user(@employee.id).count', 1 do
        @result = credit_op.run
      end
    end

    assert @result.success?
    assert_equal 1030, @employee.reload.wallet.balance_value
    assert_equal 970, @manager.reload.wallet.balance_value
  end

  test "successful crediting of money to user's wallet by finance manager" do
    index_users = User.where(id: @employee.id)
    User::Team::Index.stubs(:call).returns(index_users)
    User::Team::Index.stubs(:success?).returns(true)
    User.any_instance.stubs(:valid_password?).returns(true)

    credit_op = User::Wallet::Credit.new(@finance_manager, @credit_params)
    assert_difference '@finance_manager.payments.initiated_by_user(@finance_manager.id).count', 1 do
      assert_difference '@employee.payments.received_by_user(@employee.id).count', 1 do
        @result = credit_op.run
      end
    end

    assert @result.success?
    assert_equal 1030, @employee.reload.wallet.balance_value
    assert_equal 970, @finance_manager.reload.wallet.balance_value
  end

  test "invalid parameters for crediting money" do
    # without password
    index_users = User.where(id: @employee.id)
    User::Team::Index.stubs(:call).returns(index_users)
    User::Team::Index.stubs(:success?).returns(true)

    credit_op = User::Wallet::Credit.new(@admin, @credit_params)
    assert_no_difference '@admin.payments.initiated_by_user(@admin.id).count' do
      assert_no_difference '@employee.payments.received_by_user(@employee.id).count' do
        @result = credit_op.run
      end
    end

    assert_not @result.success?
    assert_not @result.messages[:error].empty?
    assert_equal "Invalid Password!", @result.messages[:error].first
    assert_equal 1000, @employee.reload.wallet.balance_value
    assert_equal 1000, @admin.reload.wallet.balance_value

    # when crediting money more than what's available in initiating user's wallet
    User.any_instance.stubs(:valid_password?).returns(true)
    @credit_params[:amount] = 1100

    credit_op = User::Wallet::Credit.new(@admin, @credit_params)
    assert_no_difference '@admin.payments.initiated_by_user(@admin.id).count' do
      assert_no_difference '@employee.payments.received_by_user(@employee.id).count' do
        @result = credit_op.run
      end
    end

    assert_not @result.success?
    assert_not @result.messages[:error].empty?
    assert_equal 'Insufficient funds to initiate the transfer', @result.messages[:error].first

  end

  test "cannot add money to someone who's not in their team" do
    index_users = User.where(id: @other_employee.id)
    User::Team::Index.stubs(:call).returns(index_users)
    User::Team::Index.stubs(:success?).returns(true)
    User.any_instance.stubs(:valid_password?).returns(true)

    credit_op = User::Wallet::Credit.new(@admin, @credit_params)
    assert_no_difference '@admin.payments.initiated_by_user(@admin.id).count' do
      assert_no_difference '@employee.payments.received_by_user(@employee.id).count' do
        @result = credit_op.run
      end
    end

    assert_not @result.success?
    assert_equal 1000, @admin.wallet.balance_value
    assert_equal 1000, @employee.wallet.balance_value
  end


end