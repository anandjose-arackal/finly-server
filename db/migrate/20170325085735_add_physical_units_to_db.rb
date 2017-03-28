class AddPhysicalUnitsToDb < ActiveRecord::Migration
  def change
    if PhysicalUnit.count == 0
      PhysicalUnit::VALUES.each do |k, v|
        PhysicalUnit.create(id: k, name: v[:name], symbol: v[:symbol])
      end
    end
  end
end
