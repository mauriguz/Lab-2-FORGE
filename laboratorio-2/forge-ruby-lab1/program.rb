require_relative 'utils/form'
require_relative 'models/player'
require_relative 'models/team'
require_relative 'models/championship'
require_relative 'test_data'


class Program
  include IOTools

  def initialize
    championship_form = Form.new('Ingresa la información del campeonato',
      name: 'Nombre del campeonato')

    championship_form.ask_for(:name)
    teams_size = championship_form.select_from_list(
      'Ingresa de cuantos jugadores quieres que sean los equipos: ', [5, 7, 11])

    @championship = Championship.new(*championship_form.get_data)
    @championship.teams_size = teams_size

    #TestData.load(@championship)
  end

  def championship_can_be_played
    @championship.can_be_played
  end

  def championship_start
    @championship.start unless @championship.started?
  end

  def championship_name
    @championship.name
  end

  def add_team
    team = nil

    while !team
      form = Form.new('Ingrese nuevo equipo', name: 'Nombre: ')
      form.ask_for(:name)

      team = Team.new(*form.get_data)
      if error = @championship.can_add_team(team)
        team = nil
        show_error(error)
      end
    end

    @championship.add_team(team)
  end

  def add_player
    player = nil

    while !player
      form = Form.new('Ingrese nuevo jugador', name: 'Nombre: ', ci: 'Cédula de Identidad: ')
      form.ask_for(:name, :ci)

      player = Player.new(*form.get_data)
      if error = @championship.can_add_player(player)
        player = nil
        show_error(error)
      end
    end

    @championship.add_player(player)
  end

  def add_player_to_team
    form = Form.new

    if @championship.teams.empty?
      show_error('No hay equipos creados aun')
      return
    end

    if @championship.available_players.empty?
      show_error('No hay jugadores sin equipo')
      return
    end

    player = form.select_from_list('Que jugador desea agregar?',
      @championship.available_players)

    team = form.select_from_list('A que equipo?',
      @championship.teams)

    @championship.add_player_to_team(player, team)
  end

  def display_players
    if @championship.players.any?
      display_list(@championship.players)
    else
      show_error('No hay jugadores ingresados')
    end
  end

  def display_teams
    if @championship.teams.any?
      display_list(@championship.teams)
    else
      show_error('No hay equipos ingresados')
    end
  end

  def next_match
    match = @championship.next_match

    if match.instance_of?(Match)
      puts match.to_s
      score_team_a = get_input('Ingresa los goles del primer equipo:')
      score_team_b = get_input('Ingresa los goles del segundo equipo:')

      @championship.set_match_result(match, score_team_a, score_team_b)
    else
      show_error(match)
    end
  end

  def display_fixture
    @championship.print_fixture
  end


  def display_team_players
    if @championship.teams.any?
      form = Form.new
      team = form.select_from_list('De que equipo desea consultar los jugadores?',
        @championship.teams)

      if team.players.any?
        display_list(team.players)
      else
        show_error('El equipo no tiene jugadores')
      end
    else
      show_error('No hay equipos ingresados')
    end
  end

  def print_table
    if @championship.ended?
      puts "#{@championship.winner_team.name} ha ganado el campeonato"
      puts ''
    end

    @championship.print_table
  end
end
