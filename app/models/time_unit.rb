class TimeUnit < ActiveRecord::Base
  belongs_to :physical_unit

  VALUES = {hour: 1, minute: 2, second: 3}
end
