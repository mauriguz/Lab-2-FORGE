class Match
	attr_accessor :match_id, :team_a, :team_b, :description, :state, :result, :news

	def initialize
		@match_id= "#{:team_a}_#{:team_b}"
		@description= "#{:team_a} vs #{:team_b}"
		@state= :pending
		@score_a= 0
		@score_b= 0
		@result= "#{@score_a}-#{@score_b}"
		@news= []
	end

	def list_matches
		@info_matches=[]
		@match.match_id.each do |id_position|
      		info={id: @match_id, description: @description, result: @result, state: @state} 
      		@info_matches<< info
    	end
    	return @info_matches
	end
end