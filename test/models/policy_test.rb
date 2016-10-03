# == Schema Information
#
# Table name: policies
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  company_id :integer
#  owner_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  default    :boolean          default(FALSE), not null
#  is_deleted :boolean          default(FALSE), not null
#

require 'test_helper'

class PolicyTest < ActiveSupport::TestCase

  def setup
    @p = Policy.last
    @u1 = User.find_by(email: 'user1@finlytest.io')
    @u2 = User.find_by(email: 'user2@finlytest.io')
  end

  test 'has_one version update' do
    @p.configuration.update_attribute(:require_category, true)
    @p.configuration.update_attribute(:require_category, false)
    assert_equal @p.configuration.require_category, false
    p2 = @p.versions.last.reify(has_one: true)
    assert_equal p2.configuration.require_category, true
    @p.reload
    assert_equal @p.configuration.require_category, false
  end

  test 'has_many version update' do
    last_mapping = @p.user_team_mapping.last
    original_manager_id = last_mapping.manager_id
    last_mapping.update_attribute(:manager_id, @u2.id)
    assert_equal @p.user_team_mapping.last.manager_id, @u2.id
    p2 = @p.versions.last.reify(has_one: true, has_many: true)
    assert_equal p2.user_team_mapping.last.manager_id, original_manager_id
    @p.reload
    assert_equal @p.user_team_mapping.last.manager_id, @u2.id
  end

  test 'has_many version create' do
    @p.user_team_mapping.create(user_id: 13, manager_id: 14, greater_than_amount_id: Amount.last.id)
    p2 = @p.versions.last.reify has_many: true, has_one: true
    assert_equal p2.user_team_mapping.size + 1, @p.user_team_mapping.size
  end

  test 'has_many version destroy' do
    @p.user_team_mapping.last.destroy
    p2 = @p.versions.last.reify(has_many: true, has_one: true)
    assert_equal p2.user_team_mapping.size - 1, @p.user_team_mapping.size
  end

end
