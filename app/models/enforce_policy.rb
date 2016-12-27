class EnforcePolicy < ActiveRecord::Base

  belongs_to :enforceable, polymorphic: true
end
