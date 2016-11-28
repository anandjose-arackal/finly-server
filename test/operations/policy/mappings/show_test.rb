require 'test_helper'
require 'sidekiq/testing'

class ShowTest < ActiveSupport::TestCase

  def setup
    @user = User.first
    @requesting_user = User.second
    @policy = Policy.first
    @mapping = UserManagerMapping.first

    @default_manager = User.find(3)
    @default_finance_manager = User.find(4)
    @default_approves_to = User.find(5)
    @default_approves_finance_to = User.find(6)
    @conditional_manager = User.find(7)
    @conditional_finance_manager = User.find(8)
    @conditional_approves_to = User.find(9)
    @conditional_approves_finance_to = User.find(10)

    @requesting_user .stubs(:admin?).returns(true)
    @mapping.stubs(:default => {manager: @default_manager,
                                finance_manager: @default_finance_manager,
                                approves_to: @default_approves_to,
                                approves_finance_to: @default_approves_finance_to},
                   :non_default => stub(:manager => @conditional_manager,
                                        :finance_manager => @conditional_finance_manager,
                                        :approves_to => @conditional_approves_to,
                                        :approves_finance_to => @conditional_approves_finance_to))
    @user.stubs(:team_mapping => stub(:policy => @mapping))
  end

  test 'policy mapping show should give users default manager mapping' do
    response = Policy::Mappings::Show.(@requesting_user, user: @user, policy: @policy)
    assert response.success?
    map = response.map
    assert map.present?
    assert_equal map[:default][:manager], @default_manager
    assert_equal map[:default][:finance_manager], @default_finance_manager
    assert_equal map[:default][:approves_to], @default_approves_to
    assert_equal map[:default][:approves_finance_to], @default_approves_finance_to

    assert map.present?
    assert_equal map[:conditional_manager], @conditional_manager
    assert_equal map[:conditional_finance_manager], @conditional_finance_manager
    assert_equal map[:conditional_approves_to], @conditional_approves_to
    assert_equal map[:conditional_approves_finance_to], @conditional_approves_finance_to
  end

  test 'user is required for retreiving mapping' do
    response = Policy::Mappings::Show.(@requesting_user, policy: @policy)
    assert response.failure?
  end

  test 'policy is not required for retreiving mapping' do
    response = Policy::Mappings::Show.(@requesting_user, user: @user, policy: @policy)
    assert response.success?
  end

end
