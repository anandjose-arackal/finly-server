class Admin::Implementations::Master::TdsSlabs::Export < Admin::Implementations::Processor::Export

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'tds_slabs.export'

  headers ({
              :id => "ID",
              :name => "Name",
              :tds => "TDS Rate",
              :destroy => "Destroy"
          })

  def valid_request

  end

  def input
    company.tds_slabs
  end

  def id(tds_slab)
    tds_slab.id
  end

  def tds(tds_slab)
    tds_slab.tds
  end

  def name(tds_slab)
    tds_slab.name
  end

  def destroy(tds_slab)
    ''
  end

  def post_process
  end

end
