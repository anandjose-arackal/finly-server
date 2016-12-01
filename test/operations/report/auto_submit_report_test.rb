require 'test_helper'

class AutoSubmitReportTest < ActiveSupport::TestCase

  def setup
    @user = User.find_by(email: 'employee0@finlytest.io')
    @manager = User.find_by(email: 'manager0@finlytest.io')
    # @manual_expense = Expense.new(id: 1, user_id: @user.id, expense_type_id: ExpenseType.id_for(:manual), expense_status_id: ExpenseStatus.id_for(:unreported))
    # @card_expense = Expense.new(id: 2, user_id: @user.id, expense_type_id: ExpenseType.id_for(:card), expense_status_id: ExpenseStatus.id_for(:unreported))
    @manual_expense = Expense.only_manual_expenses.first
    @card_expense = Expense.only_card_expenses.first
    @expenses = Expense.with_id([@manual_expense.id, @card_expense.id])

    # Mocking
    # @expenses.stubs(:only_manual_expenses).returns([@manual_expense])
    # @expenses.stubs(:only_card_expenses).returns([@card_expense])
    Expense::Index.stubs(:call).returns(Expense::Index::ListPresenter.new(@user, {expenses: @expenses}))
    User::Team::Review::NextReviewer.stubs(:call).returns(User::Team::Review::NextReviewer::Presenter.new(@manager, role_id: UserRole.id_for(:manager)))
  end

  test 'Auto submit should fail if auto submit is not enabled for the user' do
    @user.auto_submit_config.stubs(:enabled).returns(false)
    assert_not @user.auto_submit_config.enabled
    result = Report::AutoSubmit.(nil, user: @user)
    assert result.failure?
  end

  test 'Auto submit should succeed, without creating reports if user has no unreported expenses' do
    @user.auto_submit_config.stubs(:enabled).returns(true)
    assert @user.auto_submit_config.enabled
    result = nil
    Expense::Index.stubs(:call).returns(Expense::Index::ListPresenter.new(@user, {expenses: Expense.none}))
    assert_no_difference 'Report.count' do
      result = Report::AutoSubmit.(nil, user: @user)
    end
    assert result.success?
  end

  test 'Successful submission' do
    @user.auto_submit_config.stubs(:enabled).returns(true)
    assert @user.auto_submit_config.enabled
    result = nil
    assert_difference 'Report.count', 1 do
      result = Report::AutoSubmit.(nil, user: @user)
    end
    assert result.success?
    report = result.params[:report]
    assert report.present?
    assert report.processing?
    assert_equal report.controlling_user, @manager
  end

  test 'if no manager is assigned, auto submitted report should be marked as approved if user has pending reimbursements' do
    User::Team::Review::NextReviewer.stubs(:call).returns(User::Team::Review::NextReviewer::Presenter.new(nil, role_id: nil))
    BalanceSheet.any_instance.stubs(:cash_in_hand).returns(Amount.new(value: 0))

    assert @user.balance_sheet.cash_in_hand.value < @expenses.with_amount.sum(:value)
    @user.auto_submit_config.stubs(:enabled).returns(true)
    assert @user.auto_submit_config.enabled
    result = nil
    assert_difference 'Report.count', 1 do
      result = Report::AutoSubmit.(nil, user: @user)
    end
    assert result.success?
    report = result.params[:report]
    assert report.present?
    assert report.approved?
    assert_equal report.controlling_user, nil
  end

  test 'if no manager is assigned, auto submitted report should be marked as closed if user has no pending reimbursements' do
    User::Team::Review::NextReviewer.stubs(:call).returns(User::Team::Review::NextReviewer::Presenter.new(nil, role_id: nil))
    BalanceSheet.any_instance.stubs(:cash_in_hand).returns(Amount.new(value: @expenses.with_amount.sum(:value) + 100))

    assert @user.balance_sheet.cash_in_hand.value > @expenses.with_amount.sum(:value)
    @user.auto_submit_config.stubs(:enabled).returns(true)
    assert @user.auto_submit_config.enabled
    result = nil
    assert_difference 'Report.count', 1 do
      result = Report::AutoSubmit.(nil, user: @user)
    end
    assert result.success?
    report = result.params[:report]
    assert report.present?
    assert report.closed?
    assert_equal report.controlling_user, nil
  end

  test 'Auto submit should submit all unreported expenses (Manual + Card) of the user if "Only Card Expenses" is not set' do
    @user.auto_submit_config.stubs(:enabled).returns(true)
    assert @user.auto_submit_config.enabled
    assert_not @user.auto_submit_config.limit_to_card_expenses
    result = nil
    assert_difference 'Report.count', 1 do
      result = Report::AutoSubmit.(nil, user: @user)
    end
    assert result.success?
    report = result.params[:report]
    assert report.present?
    assert report.processing?
    assert_equal report.controlling_user, @manager
    assert_equal report.expenses.count, 2
  end

  test 'If "Only card expense" configuration is set, auto submit should report only card expenses' do
    @user.auto_submit_config.stubs(:enabled).returns(true)
    @user.auto_submit_config.stubs(:limit_to_card_expenses).returns(true)
    assert @user.auto_submit_config.enabled
    assert @user.auto_submit_config.limit_to_card_expenses
    result = nil
    assert_difference 'Report.count', 1 do
      result = Report::AutoSubmit.(nil, user: @user)
    end
    assert result.success?
    report = result.params[:report]
    assert report.present?
    assert report.processing?
    assert_equal report.controlling_user, @manager
    assert_equal report.expenses.count, 1
    assert_equal report.expenses.first.id, @card_expense.id
  end

  test 'If a blocking violation exists, it should create the report but not submit it. Warning violations should be submitted' do
    @user.auto_submit_config.stubs(:enabled).returns(true)

    p = {}
    p[1] = {}
    p[1]['expense_blocking'] = 'Yes blocking'
    Report::Violation.stubs(:call).returns(p)

    assert @user.auto_submit_config.enabled
    result = nil
    assert_difference 'Report.count', 1 do
      result = Report::AutoSubmit.(nil, user: @user)
    end
    assert result.failure?
  end

  test 'If warning violation exists, it should still stubmit the report successfully' do
    @user.auto_submit_config.stubs(:enabled).returns(true)

    p = {}
    p[1] = {}
    p[1]['expense_warning'] = 'Yes warning'
    Report::Violation.stubs(:call).returns(p)

    assert @user.auto_submit_config.enabled
    result = nil
    assert_difference 'Report.count', 1 do
      result = Report::AutoSubmit.(nil, user: @user)
    end
    assert result.success?
    report = result.params[:report]
    assert report.present?
    assert report.processing?
    assert_equal report.controlling_user, @manager
  end

  test 'Reports should be submitted with the default notes and default policy id provided' do
    @user.auto_submit_config.stubs(:enabled).returns(true)
    @user.auto_submit_config.stubs(:default_policy_id).returns(1)
    default_memo_value = 'Default note value'
    @user.auto_submit_config.stubs(:default_memo).returns(default_memo_value)
    assert @user.auto_submit_config.enabled
    result = nil
    assert_difference 'Report.count', 1 do
      result = Report::AutoSubmit.(nil, user: @user)
    end
    assert result.success?
    report = result.params[:report]
    assert report.present?
    assert report.processing?
    assert_equal report.controlling_user, @manager
    assert_equal report.policy_id, 1
    assert_equal report.memo, default_memo_value
  end

end