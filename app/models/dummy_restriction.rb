class DummyRestriction < ActiveRecord::Base
  belongs_to :user

  belongs_to :product_code, class_name: "ProductCombination"
end
