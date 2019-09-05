class Admin::Implementations::Master::Lrms::Import < Admin::Implementations::Processor::Import

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'lrms.import'
  halt_on_failure!
  headers [

          ]
end
