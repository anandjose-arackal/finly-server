module ExportManager::DSL::DataProvider
  extend ActiveSupport::Concern

  def data
    return @data if @loaded

    @data = input
    if @data.respond_to?(:each)
      update total_records: @data.count
    elsif @data.present?
      update total_records: 1
    end
    @loaded = true
    @data
  end

  def input
    nil
  end

end