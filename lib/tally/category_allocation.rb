class Tally::CategoryAllocation < NonPersistentModel
  attr_accessor :name

  validates_presence_of :name, :cost_centers
  validate :cost_center_name_presence

  def cost_centers
    @cost_centers ||= []
  end

  def add(cc, value)
    cost_center = cost_centers.find {|c| c[:name] == cc}
    if cost_center.nil?
      cost_center = {name: cc, amount: 0}
      self.cost_centers << cost_center
    end
    cost_center[:amount] += value&.to_f&.round(2)
  end

  def as_json(options = {})
    Tally::Utils.format(
        {
            "category": self.name,
            "isdeemedpositive": 'Yes',
            "costcentreallocations.list": cost_centers
        }
    )
  end

  protected

  def cost_center_name_presence
    cost_centers.each do |cost_center|
      if cost_center[:name].nil?
        errors.add :cost_center, 'name cannot be blank'
      end
    end
  end

end