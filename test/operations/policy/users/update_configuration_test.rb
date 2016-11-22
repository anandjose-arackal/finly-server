# require 'test_helper'
# require "#{Rails.root}/app/operations/user/team/mappings/update"
#
# class UpdateConfigurationTest < ActiveSupport::TestCase
#
#   def setup
#     @admin = User.first
#     @policy = Policy::Create.new(@admin, name: "Test").run
#     @employee = User.find_by(email: 'user0@finlytest.io')
#     @manager = User.find_by(email: 'manager0@finlytest.io')
#     @second_manager = User.find_by(email: 'manager1@finlytest.io')
#     @random_employee = User.find_by(email: 'user1@finlytest.io')
#     add_user_op = Policy::Users::AddUser.new(@admin, {policy_id: @policy.id, added_user_id: @employee.id, admin: true})
#     @policy = add_user_op.run
#     @policy = Policy::Users::AddUser.new(@admin, {policy_id: @policy.id, added_user_id: @random_employee.id}).run
#     @policy = Policy::Users::AddUser.new(@admin, {policy_id: @policy.id, added_user_id: @manager.id}).run
#
#     @update_params = {policy_id: @policy.id,
#                       user_id: @random_employee.id,
#                       view: 'admin',
#                       default: {manager_id: 6,
#                                 finance_manager_id: 4,
#                                 team_mapping_id: @random_employee.team_mapping.policy(@policy.id).default.first.id},
#                       conditional_manager: {amount: 200,
#                                             currency_id: 1,
#                                             manager_id: 7},
#                       conditional_finance_manager: {amount: 200,
#                                             currency_id: 1,
#                                             finance_manager_id: 5},
#                       }
#     @manager_update_params = {policy_id: @policy.id,
#                               user_id: @manager.id,
#                               view: 'admin',
#                               default: {manager_id: 6,
#                                         finance_manager_id: 4,
#                                         approves_to_id: 8,
#                                         team_mapping_id: @manager.team_mapping.policy(@policy.id).default.first.id},
#                               conditional_manager: {amount: 200,
#                                                     currency_id: 1,
#                                                     manager_id: 7},
#                               conditional_finance_manager: {amount: 200,
#                                                             currency_id: 1,
#                                                             finance_manager_id: 5},
#                               conditional_approves_to: {amount: 200,
#                                                         currency_id: 1,
#                                                         approves_to_user_id: 9}
#                               }
#   end
#
#   test "successfully updating a user's configuration within the policy" do
#
#     update_config_op = Policy::Users::UpdateConfiguration.new(@admin, @update_params)
#     @result = update_config_op.run
#     mappings = @random_employee.team_mapping.policy(@policy.id)
#
#     assert_equal 6, mappings.default.first.manager_id
#     assert_equal 4, mappings.default.first.finance_manager_id
#     assert mappings.non_default.manager.present?
#     assert_equal 7, mappings.non_default.manager.first.manager_id
#     assert_equal 200, mappings.non_default.manager.first.greater_than_amount_value
#     assert mappings.non_default.finance_manager.present?
#     assert_equal 5, mappings.non_default.finance_manager.first.finance_manager_id
#
#     # updating the policy configuration by a policy admin
#     @update_params[:default][:manager_id] = 5
#     @update_params[:default][:finance_manager_id] = 3
#     @update_params[:conditional_manager][:amount] = 150
#     @update_params[:conditional_manager][:team_mapping_id] = mappings.non_default.manager.first.id
#     @update_params[:conditional_finance_manager][:amount] = 150
#     @update_params[:conditional_finance_manager][:team_mapping_id] = mappings.non_default.finance_manager.first.id
#     update_config_op = Policy::Users::UpdateConfiguration.new(@employee, @update_params)
#     @result = update_config_op.run
#     mappings = @random_employee.team_mapping.policy(@policy.id)
#
#     assert_equal 5, mappings.default.first.manager_id
#     assert_equal 3, mappings.default.first.finance_manager_id
#     assert mappings.non_default.manager.present?
#     assert_equal 7, mappings.non_default.manager.first.manager_id
#     assert_equal 150, mappings.non_default.manager.first.greater_than_amount_value
#     assert mappings.non_default.finance_manager.present?
#     assert_equal 5, mappings.non_default.finance_manager.first.finance_manager_id
#
#     # updating approves to for manager by admin
#     update_config_op = Policy::Users::UpdateConfiguration.new(@admin, @manager_update_params)
#     @result = update_config_op.run
#     mappings = @manager.team_mapping.policy(@policy.id)
#
#     assert_equal 6, mappings.default.first.manager_id
#     assert_equal 4, mappings.default.first.finance_manager_id
#     assert_equal 8, mappings.default.first.approves_to_id
#     assert mappings.non_default.manager.present?
#     assert_equal 7, mappings.non_default.manager.first.manager_id
#     assert mappings.non_default.finance_manager.present?
#     assert_equal 5, mappings.non_default.finance_manager.first.finance_manager_id
#     assert mappings.non_default.approves_to.present?
#     assert_equal 9, mappings.non_default.approves_to.first.approves_to_id
#   end
#
#   test "non policy admins cannot update configuration" do
#     update_config_op = Policy::Users::UpdateConfiguration.new(@manager, @update_params)
#     begin
#       @result = update_config_op.run
#     rescue
#       @rescued = true
#     end
#     assert @rescued
#
#     update_config_op = Policy::Users::UpdateConfiguration.new(@second_manager, @update_params)
#     begin
#       @result = update_config_op.run
#     rescue
#       @rescued = true
#     end
#     assert @rescued
#   end
#
#   test "trying to update configuration with invalid params" do
#     @update_params[:conditional_manager][:amount] = -100
#     update_config_op = Policy::Users::UpdateConfiguration.new(@admin, @update_params)
#     @result = update_config_op.run
#     assert_not @result
#     assert_not update_config_op.errors.blank?
#   end
# end