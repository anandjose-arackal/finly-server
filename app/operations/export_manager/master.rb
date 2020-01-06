class ExportManager::Master
  include EventBus::Bus

  subscribers_path "#{Rails.root}/app/operations/export_manager/master"

  def self.fetch(user, params, scope: nil)
    handlers = []
    subscribers.each do |_, list|
      list.each do |master|
        screen = master.screen
        screen = [master.screen] unless screen.respond_to?(:each)
        screen = screen.map(&:to_s)
        next unless params[:screen].blank? or screen.include?(params[:screen].to_s)
        next unless params[:handle].blank? or master.handle_name.to_s == params[:handle].to_s
        next unless params[:system].blank? or master.system.to_s == params[:system].to_s
        next unless master.valid_company?(user, params)
        next unless master.accept?(user, params)

        handlers << master.config
      end
    end
    handlers
  end
end