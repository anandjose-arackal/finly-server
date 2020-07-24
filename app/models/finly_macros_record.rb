class FinlyMacrosRecord < ActiveRecord::Base
  include Exposures::Model::Exposable
  include SoftDeletable
  include Ransacker

  self.abstract_class = true
  establish_connection :"finly_macros_#{Rails.env}"
end
