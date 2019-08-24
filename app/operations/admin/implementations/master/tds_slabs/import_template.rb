class Admin::Implementations::Master::TdsSlabs::ImportTemplates < Admin::Implementations::Processor::ImportTemplate

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'tds_slabs.import_template'
  headers ({
      :id => "ID",
      :name => "Name",
      :tds => "TDS Rate",
      :destroy => "Destroy"
  })

  def valid_request
  end


  def input
    []
  end

  def post_process
  end

end
