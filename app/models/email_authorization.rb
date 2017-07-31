# == Schema Information
#
# Table name: email_authorizations
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  authorizable_id   :integer          not null
#  authorizable_type :string(255)      not null
#  token             :string(255)
#  is_valid          :boolean          default(TRUE)
#  view_role_id      :integer
#

class EmailAuthorization < ActiveRecord::Base
  belongs_to :authorizable, polymorphic: true
  belongs_to :user


  scope :with_authorizable, -> (authorizable) { where authorizable: authorizable }
  scope :with_token, -> (token) { where token: token }
  scope :with_view_role_id, -> (id) { where view_role_id: id }
  scope :with_valid, -> { where is_valid: true }
  scope :with_user_id, -> (user_id) { where user_id: user_id }
  scope :with_id, ->(id) { where id: id }
end
