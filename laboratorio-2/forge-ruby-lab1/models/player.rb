class Player
  attr_accessor :name, :id, :available

  def initialize(name, id)
    @name = name
    @id = id
    @available = true
  end

  def to_s
    "#{@name} (#{@id})"
  end
end
