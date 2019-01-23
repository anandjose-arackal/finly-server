class Navbar::Config < BaseOperation
  attr_accessor :user, :params, :config_data

  MASTERS = [
      Navbar::Master::Collect::NavConfig,
      Navbar::Master::ExpenseManagement::NavConfig,
      Navbar::Master::FundDisbursement::NavConfig,
      Navbar::Master::VendorPayment::NavProcurement,
      Navbar::Master::VendorPayment::NavPayment
  ]

  def pre_validate
    return unless user_present? and params_present?

    unless params[:type].present?
      add_message :error, 'Type not defined'
      return
    end

    ## Ensure this is being called on the web
    # unless current_device&.to_s == 'web'
    #   add_message :error, 'Navbar config is only available for the web'
    #   return
    # end
  end

  def process
    MASTERS.each do |klass|
      # Skip unless the master extends Navbar::Master::Base
      next unless klass<= Navbar::Master::Base
      # Verify if the current app is the same as the registed app in the master
      next unless klass&.type&.to_s == params[:type]
      next unless klass.accept?
      self.config_data = process_master(klass)
      break
    end
    self.config_data
  end

  def process_master(klass)
    menu_data = []
    structure = klass.structure
    master = klass.new
    structure.each do |item|
      menu_key = nil
      sub_menu_keys = nil
      if item.is_a?(Hash)
        menu_key = item.keys.first&.to_sym
        sub_menu_keys = item[menu_key]
      elsif item.is_a?(Symbol)
        menu_key = item
      else
        raise "Invalid type item"
      end

      conf = master.send menu_key
      next if conf.nil?

      if sub_menu_keys.present?
        conf[:sub_menu] = []
        sub_menu_keys.each do |sub_menu_key|
          sub_conf = master.send sub_menu_key
          conf[:sub_menu] << sub_conf unless sub_conf.nil?
        end
      end
      menu_data << conf
    end
    menu_data
  end

  def success
    Navbar::Config::SuccessPresenter.new(user, {config_data: config_data}, messages)
  end

  class Navbar::Config::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :config_data

    def init
      self.config_data = params[:config_data]
    end

  end

end