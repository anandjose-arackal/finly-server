class Policy < ActiveRecord::Base
  belongs_to :company
  has_one :user_manager_mapping
end
