# == Schema Information
#
# Table name: single_sign_on_types
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

class SingleSignOnType < ApplicationRecord
  include Seedable

  def self.values
    [
        :saml,
        :oauth2,
        :darwinbox
    ]
  end
end
