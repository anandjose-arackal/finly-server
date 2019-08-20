class Admin::Implementations::Master::TdsSlabs::ImportTemplates < Admin::Implementations::Processor::ImportTemplate

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'tds_slabs.import_template'
  headers [
              :id,
              :name,
              :tds,
              :destroy
          ]
  def valid_request
  end

  def input
    []
  end

  def post_process
  end

end
