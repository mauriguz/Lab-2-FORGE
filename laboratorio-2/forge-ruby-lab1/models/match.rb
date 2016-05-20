class Match
  def initialize(team_a, team_b)
    @team_a = team_a
    @team_b = team_b
    @score_a = 0
    @score_b = 0
    @ended = false
  end

  def summary
    score_a = @ended ? @score_a : '-'
    score_b = @ended ? @score_b : '-'

    "#{@team_a.name} (#{score_a}) vs #{@team_b.name} (#{score_b})"
  end

  def set_result(team_a_score, team_b_score)
    @score_a = team_a_score
    @score_b = team_b_score
    @ended = true

    calculate_points
  end

  def calculate_points
    if @score_a > @score_b
      @team_a.add_match_win
      @team_b.add_match_lost
    elsif @score_b > @score_a
      @team_b.add_match_win
      @team_a.add_match_lost
    else
      @team_a.add_match_draw
      @team_b.add_match_draw
    end
  end

  def to_s
    "#{@team_a.name} vs #{@team_b.name}"
  end
end
