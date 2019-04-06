# == Schema Information
#
# Table name: users
#
#  id                        :integer          not null, primary key
#  email                     :string(255)      default("")
#  encrypted_password        :string(255)      default(""), not null
#  reset_password_token      :string(255)
#  reset_password_sent_at    :datetime
#  remember_created_at       :datetime
#  sign_in_count             :integer          default(0), not null
#  current_sign_in_at        :datetime
#  last_sign_in_at           :datetime
#  current_sign_in_ip        :string(255)
#  last_sign_in_ip           :string(255)
#  confirmation_token        :string(255)
#  confirmed_at              :datetime
#  confirmation_sent_at      :datetime
#  unconfirmed_email         :string(255)
#  failed_attempts           :integer          default(0), not null
#  unlock_token              :string(255)
#  locked_at                 :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  company_id                :integer          not null
#  mobile_number             :string(255)
#  active                    :boolean          default(TRUE), not null
#  invitation_token          :string(255)
#  invitation_created_at     :datetime
#  invitation_sent_at        :datetime
#  invitation_accepted_at    :datetime
#  invitation_limit          :integer
#  invited_by_id             :integer
#  invited_by_type           :string(255)
#  invitations_count         :integer          default(0)
#  otp                       :string(255)
#  otp_sent_at               :datetime
#  otp_verified_at           :datetime
#  otp_verified              :boolean          default(FALSE), not null
#  otp_count                 :integer          default(0), not null
#  first_name                :string(255)
#  last_name                 :string(255)
#  mobile_only_invite        :boolean          default(FALSE)
#  mothers_maiden_name       :string(255)
#  verified                  :boolean          default(FALSE)
#  otp_request_type_id       :integer
#  default_password          :boolean          default(FALSE)
#  point_of_contact          :boolean          default(FALSE)
#  otp_attempts              :integer          default(0)
#  user_delegate_id          :integer
#  delegation_enabled        :boolean
#  gl_config                 :text(65535)
#  vacation_delegate_enabled :boolean
#  password_changed_at       :datetime
#  last_activity_at          :datetime
#  expired_at                :datetime
#

require 'rails_helper'

RSpec.describe User, type: :model do
  before(:all) do
    @company = create :company
    @user = create(:em_user, company: @company)
    @user2 = create(:em_user, company: @company)
    @user_emp = create(:em_employee_user, company: @company)
    @user_reviewer = create(:em_reviewer_user, company: @company)
    @user_admin = create(:em_admin_user, company: @company)
  end

  it 'should have a minimum length of 8 characters' do
    @error_message = 'Password is too short (minimum is 8 characters)'
    @user.assign_attributes(password: 'FW1g$18', password_confirmation: 'FW1g$18')
    expect(@user.valid?).to_not be_truthy
    expect(@user.errors.full_messages.include?(@error_message)).to be_truthy

    @user.assign_attributes(password: 'FW1g$18pY681', password_confirmation: 'FW1g$18pY681')
    expect(@user.valid?).to be_truthy
  end

  it 'should have a minimum password complexity of 1 for employees' do
    # @user.role_mapping.first.update(user_role_id: UserRole.id_for(:admin))
    expect(@user_emp.min_password_score).to eq(1)
  end

  it 'should have a minimum password complexity of 2 for reviewers' do
    # @user.role_mapping.first.update(user_role_id: UserRole.id_for(:admin))
    expect(@user_reviewer.min_password_score).to eq(2)
  end

  it 'should have a minimum password complexity of 3 for admins/creditors' do
    expect(@user_admin.min_password_score).to eq(3)
  end

  it "should not allow weak passwords to be save" do
    @min_password_score = 3
    allow(@user).to receive(:min_password_score).and_return(@min_password_score)
    @user.assign_attributes(password: '123456789', password_confirmation: '123456789')
    expect(@user.valid?).to_not be_truthy
    expect(@user.errors.full_messages.include?('Password not strong enough. It scored 0. It must score at least 3.')).to be_truthy

    @user.assign_attributes(password: 'FW1g$18j0t!k19T', password_confirmation: 'FW1g$18j0t!k19T')
    expect(@user.valid?).to be_truthy
  end

  it 'should have minimum password character complexity' do
    @error_message = 'Password Complexity requirement not met. Please use: 1 uppercase, 1 lowercase, 1 digit and 1 special character'

    # No uppercase
    @user_admin.assign_attributes(password: 'FW1g$18j0t!k19T'.downcase, password_confirmation: 'FW1g$18j0t!k19T'.downcase)
    expect(@user_admin.valid?).to_not be_truthy
    expect(@user_admin.errors.full_messages.include?(@error_message)).to be_truthy

    # No lowercase
    @user_admin.assign_attributes(password: 'FW1g$18j0t!k19T'.upcase, password_confirmation: 'FW1g$18j0t!k19T'.upcase)
    expect(@user_admin.valid?).to_not be_truthy
    expect(@user_admin.errors.full_messages.include?(@error_message)).to be_truthy

    # No digits
    @user_admin.assign_attributes(password: 'FWg$aLjrt!klOT', password_confirmation: 'FWg$aLjrt!klOT')
    expect(@user_admin.valid?).to_not be_truthy
    expect(@user_admin.errors.full_messages.include?(@error_message)).to be_truthy

    # No special characters
    @user_admin.assign_attributes(password: 'FW1gSaLjrtEklOR', password_confirmation: 'FW1gSaLjrtEklOR')
    expect(@user_admin.valid?).to_not be_truthy
    expect(@user_admin.errors.full_messages.include?(@error_message)).to be_truthy

    # Valid
    @user_admin.assign_attributes(password: 'FW1g$18j0t!k19T', password_confirmation: 'FW1g$18j0t!k19T')
    expect(@user_admin.valid?).to be_truthy
    expect(@user_admin.errors.full_messages.include?(@error_message)).to_not be_truthy
  end

  it 'should not allow user to reuse last 10 passwords' do
    @passwords = []
    10.times.each do |i|
      pass = "FW1g$18j0t!k19TJ#{i}"
      @passwords << pass
      expect(@user.update(password: pass, password_confirmation: pass)).to be_truthy
    end

    @error_message = 'Password was used previously.'
    @passwords.each do |pass|
      expect(@user.update(password: pass, password_confirmation: pass)).to_not be_truthy
      expect(@user.errors.full_messages.include?(@error_message)).to be_truthy
    end

    pass = 'FW1g$18j0t!k19TJ&'
    expect(@user.update(password: pass, password_confirmation: pass)).to be_truthy
  end

  it 'should expire user password after 3 months' do
    @user.update(password_changed_at: DateTime.now)
    expect(@user.password_expired?).to_not be_truthy

    @user.update(password_changed_at: 91.days.ago)
    expect(@user.password_expired?).to be_truthy
  end

  it 'should expire user after 3 months of inactivity' do
    @user.update(last_activity_at: DateTime.now)
    expect(@user.expired?).to_not be_truthy

    @user.update(last_activity_at: 91.days.ago)
    expect(@user.expired?).to be_truthy
  end

  describe '> Expire user if weak passwords, inactivity, no recent password change' do

    before :all do
      @user2.update(expired_at: nil, last_activity_at: DateTime.now, password_changed_at: DateTime.now)
    end

    it 'should not be expired' do
      expect(@user2.expired?).to_not be_truthy
    end

    it 'should expire if user is having weak password' do
      @user2.verify_expiration!('123456789')
      expect(@user2.expired?).to be_truthy
    end

    it 'should expire if user is inactive for more than 90 days' do
      @user2.update(last_activity_at: 91.days.ago)
      @user2.verify_expiration!
      expect(@user2.expired?).to be_truthy
    end

    it 'should expire if user password has not been changed for more than 90 days' do
      @user2.update(password_changed_at: 91.days.ago)
      @user2.verify_expiration!
      expect(@user2.expired?).to be_truthy
    end

    it 'should succeed' do
      @user2.update(password_changed_at: DateTime.now, last_activity_at: DateTime.now, expired_at: nil)
      @user2.verify_expiration!
      expect(@user2.expired?).to_not be_truthy
    end

  end

end
