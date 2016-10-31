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
