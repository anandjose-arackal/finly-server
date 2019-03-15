class Navbar::Master::Base
  cattr_accessor :data_map

  def self.app
    set_data_map[:app]
  end

  def self.tabs
    set_data_map[:tabs]
  end

  def self.default_cog
    [
        :cog_users,
        :cog_statements,
        :cog_organization_account,
        :cog_load_company_balance,
        :cog_fund_disbursement,
        :cog_expense_management,
        :cog_vendor_payments,
        :cog_finly_collect,
        :cog_finly_insights
    ]
  end

  def self.cog
    default_cog + set_data_map[:cog]
  end

  def self.structure(type)
    set_data_map[type]
  end

  def self.register_app(app)
    set_data_map[:app] = app
  end

  def self.register_structure(type, structure)
    set_data_map[type] = structure
  end

  def self.set_data_map
    if self.data_map.nil?
      self.data_map = {}
    end
    if self.data_map[self.name].nil?
      self.data_map[self.name] = {}
    end
    self.data_map[self.name]
  end

  def self.accept?
    false
  end



end