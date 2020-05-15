class FormEntityComputationType < ApplicationRecord
  include Seedable

  set_values :form, :lookup

end
