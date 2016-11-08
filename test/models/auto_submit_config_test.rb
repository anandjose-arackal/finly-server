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
    User.find(1).auto_submit_config.update_attributes(period_id: Period.id_for(:day), enabled: true)
    User.find(2).auto_submit_config.update_attributes(period_id: Period.id_for(:week), enabled: true)
    User.find(3).auto_submit_config.update_attributes(period_id: Period.id_for(:month), enabled: true)
    User.find(4).auto_submit_config.update_attributes(period_id: Period.id_for(:quarter), enabled: true)
    User.find(5).auto_submit_config.update_attributes(period_id: Period.id_for(:year), enabled: true)
  end

  test 'Period ID, Submitable are required for a valid model' do
    # No period
    auto_submit_config = AutoSubmitConfig.new(submitable: User.first)
    assert_not auto_submit_config.valid?

    # No submitable
    auto_submit_config = AutoSubmitConfig.new(period_id: 1)
    assert_not auto_submit_config.valid?

    # Success
    auto_submit_config = AutoSubmitConfig.new(period_id: 1, submitable: User.first)
    assert auto_submit_config.valid?
  end

  test 'Daily scope should provide only daily configurations' do
    AutoSubmitConfig.daily.each do |config|
      assert config.period_id == Period.id_for(:day)
    end
  end

  test 'Weekly scope should provide daily, weekly configurations' do
    AutoSubmitConfig.weekly.each do |config|
      assert (config.period_id == Period.id_for(:day) or config.period_id == Period.id_for(:week))
    end
  end

  test 'Monthly scope should provide all daily, weekly, monthly configurations' do
    AutoSubmitConfig.monthly.each do |config|
      assert (config.period_id == Period.id_for(:day) or config.period_id == Period.id_for(:week) or
          config.period_id == Period.id_for(:month))
    end
  end

  test 'Quarterly scope should provide daily, weekly, monthly, quarterly, yearly configurations' do
    AutoSubmitConfig.quarterly.each do |config|
      assert (config.period_id == Period.id_for(:day) or config.period_id == Period.id_for(:week) or
          config.period_id == Period.id_for(:month) or config.period_id == Period.id_for(:quarter))
    end
  end

  test 'Yearly scope should provide all configurations - daily, weekly, monthly, quarterly, yearly' do
    AutoSubmitConfig.yearly.each do |config|
      assert (config.period_id == Period.id_for(:day) or config.period_id == Period.id_for(:week) or
          config.period_id == Period.id_for(:month) or config.period_id == Period.id_for(:quarter) or
          config.period_id == Period.id_for(:year))
    end
  end

end
