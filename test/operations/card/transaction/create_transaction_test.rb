require 'test_helper'

# requires a user with an associated card

class CreateTransactionTest < ActiveSupport::TestCase

  def setup
    @user = User.first
    @card = @user.cards.first
  end

  test "creating a POS transaction from message queue entries with surcharge" do
    # sample message queue entry for POS transaction with surcharge
    sample_msg_queue_entry = "321744RUPP00035088860000001306,28 Jun 2016 17:32:44,23.2,25.3,173244,POS,OLCDCB_POSOFFUS,+EYYATTINKARA          THIRUVANANTHA  IN,91,Debit,#{@card.proxy},RBLRUP"

    data = sample_msg_queue_entry.split(",")
    # for the split between merchant city and merchant name
    name_city = data[7].split("\t") # splits the sixth field after the comma into name and city
    merchant_name = name_city[0]
    merchant_city = name_city[1]

    trans_params = {reference_id: data[0],
                    transaction_timestamp: data[1],
                    transaction_amount_attributes: {value: data[2], currency_id: 1},
                    billing_amount_attributes: {value: data[3], currency_id: 1},
                    auth_transaction_id: data[4],
                    transaction_mode: data[5],
                    itzcash_merchant_key: data[6],
                    merchant_name: merchant_name,
                    merchant_city: merchant_city,
                    response_code: data[8],
                    transaction_type: data[9],
                    serial_id: data[10],
                    product_code: data[11]
    }
    assert_difference 'CardTransaction.count', 1 do
      assert_difference '@user.expenses.count', 1 do
        @result = Card::Transaction::Create.(trans_params)
      end
    end

    assert @result.success?
    assert @result.messages[:error].empty?
    assert @result.transaction.expensed
    assert_not @result.transaction.error_message
    assert_equal 23.2, @result.transaction.transaction_amount_value
    assert_equal 25.3, @result.transaction.billing_amount_value
    assert_equal @user.id, @result.transaction.user.id

    # checking the expense created out of the transaction
    @c_expense = @user.expenses.order(created_at: :desc).first
    assert_equal 25.3, @c_expense.amount_value
    assert_equal 2.1, @c_expense.surcharge_value
    assert_equal "Other", @c_expense.category_name
    assert_equal ExpenseType.card_expense_id, @c_expense.expense_type_id

  end

  test "creating a POS transaction from message queue entry without surcharge" do

    # sample message queue entry for POS transaction without surcharge
    sample_msg_queue_entry = "321744RUPP00035088860000001306,28 Jun 2016 17:32:44,23.2,23.2,173244,POS,OLCDCB_POSOFFUS,+EYYATTINKARA          THIRUVANANTHA  IN,91,Debit,#{@card.proxy},RBLRUP"

    data = sample_msg_queue_entry.split(",")

    # for the split between merchant city and merchant name
    name_city = data[7].split("\t") # splits the sixth field after the comma into name and city
    merchant_name = name_city[0]
    merchant_city = name_city[1]

    trans_params = {reference_id: data[0],
                    transaction_timestamp: data[1],
                    transaction_amount_attributes: {value: data[2], currency_id: 1},
                    billing_amount_attributes: {value: data[3], currency_id: 1},
                    auth_transaction_id: data[4],
                    transaction_mode: data[5],
                    itzcash_merchant_key: data[6],
                    merchant_name: merchant_name,
                    merchant_city: merchant_city,
                    response_code: data[8],
                    transaction_type: data[9],
                    serial_id: data[10],
                    product_code: data[11]
    }
    assert_difference 'CardTransaction.count', 1 do
      assert_difference '@user.expenses.count', 1 do
        @result = Card::Transaction::Create.(trans_params)
      end
    end

    assert @result.success?
    assert @result.messages[:error].empty?
    assert @result.transaction.expensed
    assert_not @result.transaction.error_message
    assert_equal 23.2, @result.transaction.transaction_amount_value
    assert_equal 23.2, @result.transaction.billing_amount_value
    assert_equal @user.id, @result.transaction.user.id

    # checking the expense created out of the transaction
    @c_expense = @user.expenses.order(created_at: :desc).first
    assert_equal 23.2, @c_expense.amount_value
    assert_equal 0, @c_expense.surcharge_value
    assert_equal "Other", @c_expense.category_name
    assert_equal ExpenseType.card_expense_id, @c_expense.expense_type_id

  end

  test "creating an ATM transaction from the message queue entries" do
    sample_msg_queue_entry = "321744RUPP00035088860000001306,28 Jun 2016 17:32:44,123.0,124.0,173244,ATM,OLCDCB_POSOFFUS,+EYYATTINKARA          THIRUVANANTHA  IN,91,Debit,#{@card.proxy},RBLRUP"

    data = sample_msg_queue_entry.split(",")

    # for the split between merchant city and merchant name
    name_city = data[7].split("\t") # splits the sixth field after the comma into name and city
    merchant_name = name_city[0]
    merchant_city = name_city[1]

    trans_params = {reference_id: data[0],
                    transaction_timestamp: data[1],
                    transaction_amount_attributes: {value: data[2], currency_id: 1},
                    billing_amount_attributes: {value: data[3], currency_id: 1},
                    auth_transaction_id: data[4],
                    transaction_mode: data[5],
                    itzcash_merchant_key: data[6],
                    merchant_name: merchant_name,
                    merchant_city: merchant_city,
                    response_code: data[8],
                    transaction_type: data[9],
                    serial_id: data[10],
                    product_code: data[11]
    }

    cih = @user.cash_in_hand.value
    assert_difference 'CardTransaction.count', 1 do
      assert_no_difference '@user.expenses.count' do
        @result = Card::Transaction::Create.(trans_params)
      end
    end

    assert @result.success?
    assert @result.messages[:error].empty?
    assert @result.transaction.expensed
    assert_not @result.transaction.error_message
    assert_equal 123.0, @result.transaction.transaction_amount_value
    assert_equal 124.0, @result.transaction.billing_amount_value
    assert_equal @user.id, @result.transaction.user.id

    @user.reload
    assert_equal cih + 124.0, @user.cash_in_hand.value
  end

  test "creating a transaction out of a credit entry in the message queue" do

    sample_msg_queue_entry = "321744RUPP00035088860000001306,28 Jun 2016 17:32:44,123.0,124.0,173244,,OLCDCB_POSOFFUS,+EYYATTINKARA          THIRUVANANTHA  IN,91,Credit,#{@card.proxy},RBLRUP"

    data = sample_msg_queue_entry.split(",")

    # for the split between merchant city and merchant name
    name_city = data[7].split("\t") # splits the sixth field after the comma into name and city
    merchant_name = name_city[0]
    merchant_city = name_city[1]

    trans_params = {reference_id: data[0],
                    transaction_timestamp: data[1],
                    transaction_amount_attributes: {value: data[2], currency_id: 1},
                    billing_amount_attributes: {value: data[3], currency_id: 1},
                    auth_transaction_id: data[4],
                    transaction_mode: data[5],
                    itzcash_merchant_key: data[6],
                    merchant_name: merchant_name,
                    merchant_city: merchant_city,
                    response_code: data[8],
                    transaction_type: data[9],
                    serial_id: data[10],
                    product_code: data[11]
    }

    assert_difference 'CardTransaction.count', 1 do
      assert_no_difference '@user.expenses.count' do
        assert_no_difference '@user.cash_in_hand.value' do
          @result = Card::Transaction::Create.(trans_params)
        end
      end
    end

    assert @result.success?
    assert @result.messages[:error].empty?
    assert @result.transaction.expensed
    assert_not @result.transaction.error_message
    assert_equal 123.0, @result.transaction.transaction_amount_value
    assert_equal 124.0, @result.transaction.billing_amount_value
    assert_equal "Credit", @result.transaction.transaction_type
    assert_equal @user.id, @result.transaction.user.id
  end

  test "if the expense creation fails, the transaction is marked as not expensed" do
    # mocking the return value of the expense creation op
    messages = {error: ["Some shit."], failure: [], success: [], message: [], notice: []}
    Expense::ExCard::Create.stubs(:call).returns(BaseOperation::BasePresenter::FailurePresenter.new(nil, nil, messages))

    # sample message queue entry for POS transaction without surcharge
    sample_msg_queue_entry = "321744RUPP00035088860000001306,28 Jun 2016 17:32:44,26.2,28.6,173244,POS,OLCDCB_POSOFFUS,+EYYATTINKARA          THIRUVANANTHA  IN,91,Debit,#{@card.proxy},RBLRUP"

    data = sample_msg_queue_entry.split(",")

    # for the split between merchant city and merchant name
    name_city = data[7].split("\t") # splits the sixth field after the comma into name and city
    merchant_name = name_city[0]
    merchant_city = name_city[1]

    trans_params = {reference_id: data[0],
                    transaction_timestamp: data[1],
                    transaction_amount_attributes: {value: data[2], currency_id: 1},
                    billing_amount_attributes: {value: data[3], currency_id: 1},
                    auth_transaction_id: data[4],
                    transaction_mode: data[5],
                    itzcash_merchant_key: data[6],
                    merchant_name: merchant_name,
                    merchant_city: merchant_city,
                    response_code: data[8],
                    transaction_type: data[9],
                    serial_id: data[10],
                    product_code: data[11]
    }
    assert_difference 'CardTransaction.count', 1 do
      assert_no_difference '@user.expenses.count' do
        @result = Card::Transaction::Create.(trans_params)
      end
    end

    assert_not @result.success?
    # extracting the latest transaction
    latest_trans = CardTransaction.order(created_at: :desc).first
    assert_equal 26.2, latest_trans.transaction_amount_value
    assert_equal 28.6, latest_trans.billing_amount_value
    assert_not latest_trans.expensed
    assert latest_trans.error_message.present?
  end

  test "if the card number doesn't exist in the database, the card transaction creation fails" do
    # sample message queue entry for POS transaction without surcharge
    sample_msg_queue_entry = "321744RUPP00035088860000001306,28 Jun 2016 17:32:44,26.2,28.6,173244,POS,OLCDCB_POSOFFUS,+EYYATTINKARA          THIRUVANANTHA  IN,91,Debit,12323654823,RBLRUP"

    data = sample_msg_queue_entry.split(",")

    # for the split between merchant city and merchant name
    name_city = data[7].split("\t") # splits the sixth field after the comma into name and city
    merchant_name = name_city[0]
    merchant_city = name_city[1]

    trans_params = {reference_id: data[0],
                    transaction_timestamp: data[1],
                    transaction_amount_attributes: {value: data[2], currency_id: 1},
                    billing_amount_attributes: {value: data[3], currency_id: 1},
                    auth_transaction_id: data[4],
                    transaction_mode: data[5],
                    itzcash_merchant_key: data[6],
                    merchant_name: merchant_name,
                    merchant_city: merchant_city,
                    response_code: data[8],
                    transaction_type: data[9],
                    serial_id: data[10],
                    product_code: data[11]
    }
    assert_no_difference 'CardTransaction.count' do
      begin
        @result = Card::Transaction::Create.(trans_params)
      rescue
        @rescued = true
      end
    end
    assert @rescued
  end

  test "" do

  end

end