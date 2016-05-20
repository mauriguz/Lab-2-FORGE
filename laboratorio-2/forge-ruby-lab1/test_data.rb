class TestData
  def self.load(championship)
    available_players = []

    # Jugadores
    50.times do |i|
      player = Player.new("J#{i}", rand(5000000))
      available_players << player

      championship.add_player(player)
    end

    # Equipos
    10.times do |i|
      team = Team.new("E#{i}")

      championship.teams_size.times do
        team.add_player(available_players.slice!(-1))
      end

      championship.add_team(team)
    end
  end
end
