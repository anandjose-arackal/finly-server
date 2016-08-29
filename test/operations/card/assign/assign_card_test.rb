require 'test_helper'

class AssignCardTest < ActiveSupport::TestCase

  def setup
    @company = Company.first
    @admin = User.first # admin
    @user = User.find(14) # first employee
    @other_user = User.find(15)
    @manager = User.find_by(email: 'manager0@finlytest.io')
    @other_manager = User.find_by(email: 'manager1@finlytest.io')

    # not really needed but hey!
    @unassigned_card = @company.cards.unassigned.first
  end

  test 'managers can assign and unassign a card to users under them' do
    assign_op = Card::Assign::AssignCard.new(@manager, employee_id: @user.id)
    assert_difference '@user.cards.active.count', 1 do
      @card = assign_op.run rescue nil
    end
    assert @card
    assert_equal @card.user_id, @user.id

    # unassign
    unassign_op = Card::Assign::AssignCard.new(@manager, employee_id: @user.id, card_id: @card.id, unassign: true)
    assert_difference '@user.cards.active.count', -1 do
      @card = unassign_op.run
    end
    assert @card
    assert_not @card.user_id
  end

  test 'managers cannot unassign cards that aren\'t assigned to some user' do
    unassign_op = Card::Assign::AssignCard.new(@manager, employee_id: @user.id, card_id: @unassigned_card.id, unassign: true)
    assert_no_difference '@user.cards.active.count' do
      @card = unassign_op.run
    end
    assert_not @card
    assert_not unassign_op.errors.empty?
  end

  test 'managers cannot unassign card with incomplete params' do
    # unassigning without employee id
    @card = @user.cards.first
    unassign_op = Card::Assign::AssignCard.new(@manager, card_id: @card.id, unassign: true)
    assert_no_difference '@user.cards.active.count' do
      @card = unassign_op.run
    end
    assert_not @card
    assert_not unassign_op.errors.empty?

    # unassigning without card id
    @card = @user.cards.first
    unassign_op = Card::Assign::AssignCard.new(@manager, employee_id: @user.id, unassign: true)
    assert_no_difference '@user.cards.active.count' do
      @card = unassign_op.run
    end
    assert_not @card
    assert_not unassign_op.errors.empty?
  end

  test 'users cannot assign a card for themselves' do
    assign_op = Card::Assign::AssignCard.new(@user, employee_id: @user.id)
    assert_no_difference '@user.cards.active.count' do
      @card = assign_op.run rescue nil # i.e. if it's an exception, rescue with nil
    end
    assert_not @card
  end

end