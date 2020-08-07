class Masters::RecordsController < BaseControllers::WebBase

  def import

  end

  def import_template
    endpoint Masters::Schema::Records::Import::Template
  end

end
