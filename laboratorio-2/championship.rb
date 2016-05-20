class Championship

attr_accessor :name, :players, :teams, :teams_size, :news

  def initialize(name)
    @name = name
    @players = []
    @teams = []
    @started = false
    @ended = false
    @news= []
  end
  
  def started?
    @started
  end

  def start
    unless started?
      @started = true
    end
  end


end