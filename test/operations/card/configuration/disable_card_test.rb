# includes tests for disable and enable

require 'test_helper'

class DisableCardTest < ActiveSupport::TestCase

  def setup
    @admin = User.first
    @user = User.find(14) # first employee
    @other_user = User.find(15)
    @card = @user.cards.first
    @manager = User.find_by(email: 'manager0@finlytest.io')
    @other_manager = User.find_by(email: 'manager1@finlytest.io')
  end


  test 'manager can disable cards of users within his team' do
    disable_op = Card::Configuration::DisableCard.new(@manager, {card_id: @card.id, employee_id: @user.id})
    assert_difference '@user.cards.active.count', -1 do
      @card = disable_op.run
    end
    assert_not @card.active
    assert UserRole.manager_id, @card.disabled_by_role_id
  end


  test 'after manager deactivates, user cannot reactivate card' do

    @card.update_attributes(active: false, disabled_by_role_id: 3)

    enable_op = Card::Configuration::EnableCard.new(@user, {card_id: @card.id, self: true})
    assert_no_difference '@user.cards.active.count' do
      @card = enable_op.run
    end
    assert_not @card
    assert_not enable_op.errors.empty?
  end


  test 'only manager can re-enable a card disabled by manager' do
    @card.update_attributes(active: false, disabled_by_role_id: 3)

    @card = @user.cards.first
    enable_op = Card::Configuration::EnableCard.new(@manager, {card_id: @card.id, employee_id: @user.id})
    assert_difference '@user.cards.active.count', 1 do
      @card = enable_op.run
    end
    assert @card.active
  end


  test 'manager cannot re-enable card disabled by admin' do
    # first disabling card by admin
    disable_op = Card::Configuration::DisableCard.new(@admin, {card_id: @card.id, employee_id: @user.id})
    @card = disable_op.run

    # now trying to re-enable it by manager
    enable_op = Card::Configuration::EnableCard.new(@manager, {card_id: @card.id, employee_id: @user.id})
    assert_no_difference '@user.cards.active.count' do
      @card = enable_op.run
    end
    assert_not @card
    assert_not enable_op.errors.empty?
  end


  test 'user cannot disable another user\'s card' do
    disable_op = Card::Configuration::DisableCard.new(@other_user, {card_id: @card.id, self: true})
    assert_no_difference '@user.cards.active.count' do
      @card = disable_op.run
    end
    assert_not @card
  end

  test 'manager cannot disable cards of users not in his team' do
    @card = @admin.cards.first
    disable_op = Card::Configuration::DisableCard.new(@manager, {card_id: @card.id, employee_id: @admin.id})
    assert_no_difference '@user.cards.active.count' do
      @card = disable_op.run
    end
    assert_not @card
    assert_not disable_op.errors.empty?
  end

  test 'user can re-enable his own disabled card, disabled by him' do
    @card.update_attributes(active: false, disabled_by_role_id: 4)

    enable_op = Card::Configuration::EnableCard.new(@user, {card_id: @card.id, self: true})
    assert_difference '@user.cards.active.count', 1 do
      @card = enable_op.run
    end

    assert @card.active
    assert enable_op.errors.empty?

  end

end