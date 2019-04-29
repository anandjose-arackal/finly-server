class ApiToken < ApplicationRecord
  scope :with_name, -> (name) {where name: name}
end
