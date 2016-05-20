require_relative 'championship'
require_relative 'player'
require_relative 'team'
require_relative 'match'

class Program

  def initialize(teams_size=5)
    @championship.teams_size=teams_size
  end

  def set_championship(name, teams_size=5)
    @championship.name= name
    @championship.teams_size= teams_size
  end

  def championship_can_be_played
    if !@championship.started?
      if @championship.teams.empty?
        return 'No hay equipos para disputar el campeonato'
      elsif @championship.teams.length % 2 != 0
        return 'La cantidad de equipos disponibles debe ser par'
      elsif !@championship.teams.all? { |t| t.available_to_play(@championship.teams_size) }
        return 'Hay equipos que tienen menos de la cantidad de jugadores requeridos'
      else
        return nil
      end 
    end  
  end

  def championship_start
    @championship.start unless @championship.started?
  end

  def championship_name
    @championship.name
  end

  def championship_started?
    if @championship.started= true
      return true
    else
      return false
    end
  end

  def add_team(team_name)
    if team_name== @championship.teams.find{ |team| team }
      return 'Ya existe un equipo con el nombre deseado'
    else
      @team.team_name= team_name
      @championship.teams<< team_name
    end
  end

  def add_player(ci, name, birthdate, position)
    if ci== @player.ci.find{ |player_ci| player_ci }
      return 'Ya existe un jugador con la misma C.I.'
    else
      @player.name= name
      @player.ci= ci
      @player.birthdate= birthdate
      @player.position= position
      @championship.players<< name
    end
  end

  def add_player_to_team(team_name, player_id)
    @team.team_name.each do |team|
      if team_name== team
        team_name.players.each do |player|
          if !player_id== player
            if player.position= goalkeeper
              return 'Ya existe un arquero en el equipo'
            else
              return nil
            end  
          end
        end
      end
    end
  end

  def player_list
    if @championship.players.any?
      @championship.players.each do |player|
        return player
      end
    end
  end

  def team_list
    if @championship.teams.any?
      @championship.teams.each do |team|
        return team
      end
    end
  end

  def matches_list
    @match.list_matches
  end

  def start_match(match_id)
    if match_id== @match.match_id.find{ |m| m }
      @match.state= :in_progress
    end
  end

  def end_match(match_id)
    if match_id== @match.match_id.find{ |m| m}
      @match.state= :ended
    end
  end

  def get_match(match_id)
  end

  def players_list_for_team(team_name)
    team_players= []
    team_name.players.each do |player|
      info= {id: @player.id, name: @player.name}
      team_players<< info
    end
    team_players.each { |p| return p }
  end

  def players_without_team
    @player_without_team= []
    @player.id.each do |player|
      @team.players.find {|tp| tp }
      if !player == tp
        info= {id: @player.id, name: @player.name}
        @player_without_team<< info
      end
    end
  end

  def available_players_list_for_match(match_id, team_name)
  end

  def add_match_action(match_id, team_name, player_id, action)
  end

  def get_table_data
  end

  def get_news_data
    @championship.news.each do |n|
      return n
    end
  end
end