class Team
  attr_accessor :name, :players

  def initialize(name)
    @name = name
    @players = []

    @results = {
      played: 0,
      won:    0,
      lost:   0,
      draw:   0
    }

    @points = 0
  end

  def add_player(player)
    @players << player
  end

  def available_to_play(championship_size)
    @players.length >= championship_size
  end

  def to_s
    "#{name} (#{players.length} jugadores)"
  end

  def add_match_win
    @results[:played] += 1
    @results[:won] += 1
    @points += 3
  end

  def add_match_lost
    @results[:played] += 1
    @results[:lost] += 1
  end

  def add_match_draw
    @results[:played] += 1
    @results[:draw] += 1
    @points += 1
  end

  def table_data
    @results.merge(points: @points)
  end

  def points
    @points
  end
end
