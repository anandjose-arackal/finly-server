class OlapRecord < ActiveRecord::Base
  self.abstract_class = true
  establish_connection :"olap_#{Rails.env}"
end
