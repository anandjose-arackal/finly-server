# == Schema Information
#
# Table name: admin_user_roles
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class AdminUserRole < ActiveRecord::Base
  include Seedable

  validates :name, presence: true

  def self.values
    [:admin, :transcriber, :verifier, :itzcash_verifier, :itzcash_operations]
  end

end
