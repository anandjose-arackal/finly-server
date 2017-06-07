# == Schema Information
#
# Table name: email_authorizations
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  authorizable_id   :integer          not null
#  authorizable_type :string(255)      not null
#  token             :string(255)
#  valid             :boolean          default(TRUE)
#

class EmailAuthorization < ActiveRecord::Base
  belongs_to :authorizable, polymorphic: true
end
