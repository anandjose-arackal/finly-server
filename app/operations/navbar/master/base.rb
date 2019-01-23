class Navbar::Master::Base
  cattr_accessor :data_map

  def self.type
    set_data_map[:type]
  end

  def self.structure
    set_data_map[:structure_def]
  end

  def self.register_type(type)
    set_data_map[:type] = type
  end

  def self.register_structure(structure)
    set_data_map[:structure_def] = structure
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