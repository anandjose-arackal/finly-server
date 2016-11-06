# == Schema Information
#
# Table name: auto_submit_configs
#
#  id                     :integer          not null, primary key
#  enabled                :boolean          default(FALSE), not null
#  limit_to_card_expenses :boolean          default(FALSE), not null
#  period_id              :integer          not null
#  default_memo           :text(65535)
#  default_policy_id      :integer
#  submitable_id          :integer          not null
#  submitable_type        :string(255)      not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

require 'test_helper'

class AutoSubmitConfigTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  def setup

  end

  test 'Period ID, Submitable, default_category_id, enabled are required for a valid model' do
    auto_submit_config = AutoSubmitConfig.new(submitable: User.first, default_category_id: Category.first.id, enabled: true)
    assert_not auto_submit_config.valid?

    auto_submit_config = AutoSubmitConfig.new(period_id: 1, default_category_id: Category.first.id, enabled: true)
    assert_not auto_submit_config.valid?

    auto_submit_config = AutoSubmitConfig.new(period_id: 1, submitable: User.first, enabled: true)
    assert_not auto_submit_config.valid?

    auto_submit_config = AutoSubmitConfig.new(period_id: 1, submitable: User.first, default_category_id: Category.first.id)
    assert_not auto_submit_config.valid?

    auto_submit_config = AutoSubmitConfig.new(period_id: 1, submitable: User.first, enabled: true,default_category_id: Category.first.id)
    assert auto_submit_config.valid?
  end

end
