class Player
	attr_accessor :name, :ci, :position, :birthdate 
	
	def initialize(name, ci, birthdate, position)
		@name= name
		@ci= ci
		@birthdate= birthdate
		@position= position
	end

end

class Goalkeeper < Player
	attr_accessor :goals_received, :goals_received_in_small_area

	def initialize
		@goals_received= 0
		@goals_received_in_small_area= 0
	end
end

class Defender < Player
	attr_accessor :interceptions

	def initialize
		@interceptions= 0
	end
end

class Midfielder < Player
	attr_accessor :goals, :right_passes, :total_passes

	def initialize
		@goals= 0
		@right_passes= 0
		@total_passes= 0
	end

	def calculate_right_passes_percentage
		percent_right_passes= (@right_passes / @total_passes) * 100
		return percent_right_passes
	end
end

class Forward < Player
	attr_accessor :goals, :shots_on_goal

	def initialize
		@goals= 0
		@shots_on_goal= 0
	end

	def calculate_efectivity
		efectivity= (@goals / @shots_on_goal) * 100
		return efectivity
	end
end