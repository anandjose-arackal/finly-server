class FinlyMacrosRecord < ActiveRecord::Base
  self.abstract_class = true
  establish_connection :"finly_macros_#{Rails.env}"
end
