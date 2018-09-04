class Procurements::Configs::DocumentNumberConfigs::Index < Procurements::Configs::DocumentNumberConfigs::Base
  attr_accessor :configs

  class Procurements::Configs::DocumentNumberConfigs::Index::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :configs

    def init
      self.configs = params[:configs]
    end
  end

  def init
    self.configs = user.company.document_number_configs.with_purpose_id(Purpose.id_for(:vendor_payments))
  end

  def success
    params[:configs] = self.configs
    Procurements::Configs::DocumentNumberConfigs::Index::IndexPresenter.new(user, params, messages)
  end
end