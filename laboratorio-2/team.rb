class Team
	attr_accessor :team_name, :players
	def initialize(team_name)
		@team_name=team_name
		@players= []
	end
	
	def available_to_play(teams_size)
    	@players.length >= teams_size
  	end
end