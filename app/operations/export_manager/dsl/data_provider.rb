module ExportManager::DSL::DataProvider
  extend ActiveSupport::Concern

  def data
    return @data if @loaded

    @data = input
    if @data.is_a?(Hash)
      update total_records: @data.map{|k,v| v.count}.inject(:+)
    elsif @data.respond_to?(:each)
      update total_records: @data.count
    elsif @data.present?
      update total_records: 1
    end
    @loaded = true
    @data
  end

  def input
    if self.class.resolver
      Resolver::Router.dispatch(self.class.resolver, params: params.merge(filter: true, paginate: false), current_user: user)
    else
      nil
    end
  end

end