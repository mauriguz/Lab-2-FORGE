require_relative 'match'

class Championship
  attr_accessor :name, :players, :teams, :teams_size

  def initialize(name)
    @name = name
    @players = []
    @teams = []
    @started = false
    @ended = false
    @fixture = []

    @current_round = 0
    @current_match = 0
  end

  def started?
    @started
  end

  def ended?
    @ended
  end

  def can_be_played
    if !started?
      if @teams.empty?
        return 'No hay equipos para disputar el campeonato'
      elsif @teams.length % 2 != 0
        return 'La cantidad de equipos disponibles debe ser par'
      elsif !@teams.all? { |t| t.available_to_play(teams_size) }
        return 'Hay equipos que tienen menos de la cantidad de jugadores requeridos'
      end
    end
  end

  def start
    unless started?
      @started = true

      generate_fixture
    end
  end

  def can_add_player(new_player)
    player_with_same_ci = @players.find{ |player| player.id == new_player.id }
    if player_with_same_ci
      return 'Ya hay un jugador con la ci indicada'
    end
  end

  def add_player(player)
    @players << player
  end

  def can_add_team(new_team)
    team_with_same_name = @teams.find{ |team| team.name == new_team.name }
    if team_with_same_name
      return 'Ya hay un equipo con el nombre indicado'
    end
  end

  def add_team(team)
    @teams << team
  end

  def add_player_to_team(player, team)
    team.add_player(player)
    player.available = false
  end
  
  def available_players
    @players.select{ |player| player.available }
  end

  def generate_fixture
    @fixture = @teams.combination(2).to_a.shuffle.map do |match_teams|
      Match.new(match_teams[0], match_teams[1])
    end

    true
  end

  def next_match
    @current_match ||= 0

    match = @fixture.at(@current_match)

    if match
      @current_match += 1
      @ended = true if @fixture.at(@current_match).nil?
      match
    else
      'No hay mas partidos'
    end
  end

  def set_match_result(match, score_team_a, score_team_b)
    match.set_result(score_team_a, score_team_b)
  end

  def print_table
    puts 'Equipo     | PJ | PG | PE | PP | Puntos'

    @teams.each do |team|
      data = team.table_data

      print "#{team.name}         |"
      puts "  #{data[:played]} |  #{data[:won]} |  #{data[:draw]} |  #{data[:lost] } |  #{data[:points]}"
    end
  end

  def print_fixture
    @fixture.each do |match|
      puts match
    end
  end

  def winner_team
    return nil unless @ended

    @teams.sort_by{ |team| -team.points }.first
  end

  private

  def rotate_teams(teams)
    team = teams.slice!(1, 1)
    teams.push(team.first)
  end
end
