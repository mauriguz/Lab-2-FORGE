require_relative 'program.rb'
class Main < Shoes
  WIDTH = 800
  HEIGHT = 600
  HEADER_HEIGHT = 60
  PLAYER_FORM_HEIGHT = 170
  TEAM_FORM_HEIGHT = 100

  HEADER_COLOR = '#32b846'
  TEXT_COLOR = '#474747'
  SUBTEXT_COLOR = '#CED3D7'
  PLAYER_SELECTED_COLOR = '#f9f9f9'
  GAME_ACTIONS = {
    'Tiro al arco' => :shoot,
    'Gol' => :goal,
    'Gol en area chica' => :small_box_goal,
    'Pase correcto' => :good_pass,
    'Pase incorrecto' => :wrong_pass,
    'Pase interceptado' => :intercepted_pass,
    'Tarjeta Amarilla' => :yellow_card,
    'Tarjeta Roja' => :red_card
  }

  url '/', :home
  url '/fixture', :fixture
  url '/current_match/(.+)', :current_match
  url '/table', :table
  url '/news', :news
  url '/players', :players
  url '/teams', :teams

  @@program = Program.new
  @@player_images = {}
  @@team_colors = {}

  def header(championship_name='')
    @header = stack({ height: HEADER_HEIGHT}) do
      background HEADER_COLOR
      border('#20772c', strokewidth: 2)
      flow do
        image('images/icons/rsz_menu.png', margin: 5)
        if championship_name.nil?
          caption('No Championship', stroke: white)
        else
           caption(championship_name, stroke: white)
        end
      end

      unless championship_name.nil?
        @style_navbar = {margin_left: 10}
        flow({ margin_left: 30 }) do
          @matchday = inscription(
            link('FIXTURE', stroke: white, underline: 'none').click do
              visit '/fixture'
            end
          )
          flow({ width:30 })
          @table = inscription(
            link('TABLA', stroke: white, underline: 'none', margin_left: 34).click do
              visit '/table'
            end
          )
          flow({ width:30 })
          @news = inscription(
            link('ANUNCIOS', stroke: white, underline: 'none').click do
              visit '/news'
            end
          )
          flow({ width:30 })
          @players = inscription(
            link('PLAYERS', stroke: white, underline: 'none').click do
              visit '/players'
            end
          )
          flow({ width:30 })
          @teams = inscription(
            link('TEAMS', stroke: white, underline: 'none').click do
              visit '/teams'
            end
          )
        end
      end
    end
  end

  def home
    header(@@program.championship_name)
    stack({ height: 540 }) do
      background '#9ceda7'
      border('#858789', strokewidth: 2)
      if @@program.championship_name.nil?
        stack({ margin_left: WIDTH/4, margin_right: WIDTH/4 }) do
          title('Championship', align: 'center')
          @championship_name = edit_line({ width: WIDTH/2 })
          title('Cant. Jugadores', align: 'center')
          @championship_size = list_box({ items: [5, 7, 11], choose: 5, width: WIDTH/2 })
          keypress do |k|
            if k == "\n"
              if @championship_name.text.empty?
                alert('Championship is blank')
              else
                @@program.set_championship(@championship_name.text, @championship_size.text)
                visit '/'
              end
            end
          end
        end
      else
        visit '/fixture'
      end
    end
  end

  def fixture
    header(@@program.championship_name)
    stack({ height: 540 }) do
      background '#E1E6EB'
      border('#858789', strokewidth: 2)
      can_be_played = @@program.championship_started?

      if can_be_played
        flow do
          matches_list = @@program.matches_list
          match_in_progress = matches_list.any?{ |match_data| match_data[:state] == :in_progress }

          matches_list.each do |match|
            @matchday_item = stack({width: 199, height: 75, margin_left: 4, margin_top: 4 }) do
              disabled = match_in_progress && match[:state] == :pending
              background(disabled ? whitesmoke : white)
              border('#E1E6EB', strokewidth: 1)
              caption(match[:description], stroke: '#474747', align: 'center', stroke: disabled ? lightgrey : black)
              case match[:state]
              when :pending
                if match_in_progress
                  inscription('En espera', align: 'center', emphasis: 'italic', stroke: lightgrey)
                else
                  inscription(link('Comenzar').click { visit "/current_match/#{match[:id]}" }, align: 'center')
                end
              when :in_progress
                inscription(link('Continuar').click { visit "/current_match/#{match[:id]}" }, align: 'center')
              else
                inscription(match[:result], align: 'center')
              end
            end
          end
        end
      else
        start_button = stack({ left: 235, top: 100 }) do
          image  "images/start.png"
        end

        start_button.release do
          can_be_played = @@program.championship_can_be_played
          if can_be_played.nil?
            @@program.championship_start
            visit '/fixture'
          else
            alert(can_be_played)
          end
        end
      end
    end
  end

  def current_match(match_id)
    header(@@program.championship_name)

    match_data = @@program.get_match(match_id)
    @@program.start_match(match_id) if match_data[:state] == :pending

    title_height = 90
    news_height = 300
    label_padding = 10
    field_padding = 140

    new_action_styles = {
      width: WIDTH/ 2,
      height: PLAYER_FORM_HEIGHT,
      top: title_height + news_height
    }

    stack do
      stack({height: title_height, width: WIDTH, top: 4}) do
        caption(match_data[:description], stroke: TEXT_COLOR, align: 'center', size: 18)
        flow do
          @result = caption(match_data[:result], stroke: TEXT_COLOR, align: 'center', size: 16)
          end_match_link = link('Finalizar').click do
            @@program.end_match(match_id)
            visit "/fixture"
          end
          inscription(end_match_link, margin_left: 660, size: 12)
        end
      end

      @news = stack({top: title_height, scroll: true, width: WIDTH, height: news_height }) do
        background white
        match_data[:news].reverse.each do |action|
          para action
        end
      end

      @new_action_a = stack(new_action_styles) do
        @team_a = match_data[:team_a]
        @players_team_a = @@program.available_players_list_for_match(match_id, @team_a)
        players_team_a_names = @players_team_a.map{ |p| p[:name] }

        border('#E1E6EB', strokewidth: 1)
        caption("Nueva Accion de Juego #{@team_a}", stroke: TEXT_COLOR, left: label_padding)

        flow do
          inscription('Accion', stroke: TEXT_COLOR, left: label_padding)
          @action_a =  list_box({ items: GAME_ACTIONS.keys, width: 200, left: field_padding })
        end

        flow do
          inscription('Jugador involucrado:', stroke: TEXT_COLOR, left: label_padding)
          @player_a = list_box({ items: players_team_a_names, width: 200, left: field_padding })
        end

        stack({margin_left: field_padding, margin_top: 10}) do
          @button_a = button('Agregar') do
            if @player_a.text.nil? || @action_a.text.nil?
              alert('Todos los campos son obligatorios')
              return
            end

            player_index = @player_a.items.index(@player_a.text)
            player_id = @players_team_a[player_index][:id]
            action = GAME_ACTIONS[@action_a.text]

            @@program.add_match_action(match_id, @team_a, player_id, action)
            update_match_info(match_id)
          end
        end
      end

      @new_action_b = stack(new_action_styles.merge(left: WIDTH / 2)) do
        @team_b = match_data[:team_b]
        @players_team_b = @@program.available_players_list_for_match(match_id, @team_b)
        players_team_b_names = @players_team_b.map{ |p| p[:name] }

        border('#E1E6EB', strokewidth: 1)
        caption("Nueva Accion de Juego #{@team_b}", stroke: TEXT_COLOR, left: label_padding)

        flow do
          inscription('Accion', stroke: TEXT_COLOR, left: label_padding)
          @action_b =  list_box({ items: GAME_ACTIONS.keys, width: 200, left: field_padding })
        end

        flow do
          inscription('Jugador involucrado:', stroke: TEXT_COLOR, left: label_padding)
          @player_b = list_box({ items: players_team_b_names, width: 200, left: field_padding })
        end

        stack({margin_left: field_padding, margin_top: 10}) do
          @button_b = button('Agregar') do
            if @player_b.text.nil? || @action_b.text.nil?
              alert('Todos los campos son obligatorios')
              return
            end

            player_index = @player_b.items.index(@player_b.text)
            player_id = @players_team_b[player_index][:id]
            action = GAME_ACTIONS[@action_b.text]

            @@program.add_match_action(match_id, @team_b, player_id, action)
            update_match_info(match_id)
          end
        end
      end
    end
  end

  def update_match_info(match_id)
    field_padding = 140
    match_data = @@program.get_match(match_id)

    @news.clear do
      background white
      match_data[:news].reverse.each do |action|
        para action
      end
    end

    @players_team_a = @@program.available_players_list_for_match(match_id, @team_a)
    @player_a.items = @players_team_a.map{ |p| p[:name] }

    @players_team_b = @@program.available_players_list_for_match(match_id, @team_b)
    @player_b.items = @players_team_b.map{ |p| p[:name] }


    @result.replace(match_data[:result])
  end

  def table
    header(@@program.championship_name)
    field_width = 40
    header_size = 14
    row_size = 12

    stack({ height: 540 }) do
      background '#E1E6EB'
      border('#858789', strokewidth: 2)
      table_data = @@program.get_table_data

      caption('Tabla de posiciones', size: 18, stroke: TEXT_COLOR, align: 'center', margin_top: 10)
      stack(margin_left: 160, width: 650) do
        background white
        stack({scroll: true, height: [460, 35 * table_data.length + 54].min }) do
          flow({margin_top: 10}) do
            stack({ width: 200, margin_left: 20}) { para 'Equipo', size: header_size }
            stack({ width: field_width }) { para 'PJ', size: header_size }
            stack({ width: field_width }) { para 'PG', size: header_size }
            stack({ width: field_width }) { para 'PE', size: header_size }
            stack({ width: field_width }) { para 'PP', size: header_size }
            stack({ width: field_width }) { para 'DG', size: header_size }
            stack({ width: field_width }) { para 'Puntos', size: header_size }
          end

          table_data.each do |row|
            flow do
              stack({ width: 200, margin_left: 20}) { para row[:team_name], size: row_size }
              stack({ width: field_width }) { para(row[:played_matches], size: row_size) }
              stack({ width: field_width }) { para(row[:won_matches], size: row_size) }
              stack({ width: field_width }) { para(row[:drawn_matches], size: row_size) }
              stack({ width: field_width }) { para(row[:lost_matches], size: row_size) }
              stack({ width: field_width }) { para(row[:goals_difference], size: row_size) }
              stack({ width: field_width }) { para(row[:points], size: row_size, weight: 'bold') }
            end
          end
        end
      end
    end
  end

  def news
    header(@@program.championship_name)

    stack({ height: 540 }) do
      background '#E1E6EB'
      border('#858789', strokewidth: 2)
      news = @@program.get_news_data

      caption('Tabla de anuncios', size: 18, stroke: TEXT_COLOR, align: 'center', margin_top: 10)
      stack(width: WIDTH) do
        background white
        stack({scroll: true, height: 460, width: WIDTH}) do
          news.each do |text|
            para text
          end
        end
      end
    end
  end

  def players
    header(@@program.championship_name)
    @players = stack({ height: HEIGHT - HEADER_HEIGHT, scroll: true }) do
      @@program.player_list.each do |player|
        new_player = flow({ width: 200, height: 60, margin_left: 2 }) do
          background white
          stack({ width: 60, height: 60 }) do
            background white
            border('#E1E6EB', strokewidth: 1)
            new_image = @@player_images[player[:ci].to_s]
            image("images/players/rsz_#{new_image}.png", margin: [11, 5, 11, 5])
          end
          stack({ width: -60, height: 60 }) do
            border('#E1E6EB', strokewidth: 1)
            inscription(player[:name], stroke: TEXT_COLOR, weight: 'bold', height: 200)
            inscription("(#{player[:position]})", stroke: SUBTEXT_COLOR)
          end
          click do
            show_player(player)
          end
          hover do
            new_player.background PLAYER_SELECTED_COLOR
          end
          leave do
            new_player.background white
          end
        end
      end
    end

    new_player_styles = {
      width: (3 * WIDTH)/ 4,
      height: PLAYER_FORM_HEIGHT,
      left: WIDTH/4,
      top: HEADER_HEIGHT
    }

    @new_player = stack(new_player_styles) do
      border('#E1E6EB', strokewidth: 1)
      caption('Nuevo Jugador', stroke: TEXT_COLOR)
      flow do
        inscription('C.I.:', stroke: TEXT_COLOR)
        @ci = edit_line({ width: 200, left: 75 })
      end
      flow do
        inscription('Nombre:', stroke: TEXT_COLOR)
        @name = edit_line({ width: 200, left: 75 })
      end
      flow do
        inscription('Fecha Nac.:', stroke: TEXT_COLOR)
        @birthdate = edit_line({ width: 200, left: 75 })
      end
      flow do
        inscription('Posicion:', stroke: TEXT_COLOR)
        @position = list_box({ items: ['Arquero', 'Defensa', 'Volante', 'Delantero'], width: 200, left: 75 })
        state = @@program.championship_started? ? 'disable' : nil
        @add_player_btn = button('Agregar', left: 305, state: state) do
          validate_and_add_player
        end
      end
    end
    @player_info = flow({ width: (3 * WIDTH)/4, height: HEIGHT - HEADER_HEIGHT - PLAYER_FORM_HEIGHT, left: WIDTH/4, top: HEADER_HEIGHT + PLAYER_FORM_HEIGHT }) do
      background white
      border('#E1E6EB', strokewidth: 1)
      @player_info_title = flow({ height: 50 }) do
      end
      @player_info_description = stack({ height: HEIGHT - HEADER_HEIGHT - PLAYER_FORM_HEIGHT - 50 }) do
      end
    end
  end

  def teams
    header(@@program.championship_name)
    @teams = stack({ height: HEIGHT - HEADER_HEIGHT, scroll: true }) do
      @@program.team_list.each do |team|
        color = @@team_colors[team[:name]]
        new_team = flow({ width: 200, height: 60, margin_left: 2 }) do
          background white
          stack({ width: 60, height: 60 }) do
            background white
            border('#E1E6EB', strokewidth: 1)
            fill color
            rect(left: 5, top: 5, width: 50, height: 50)
          end
          stack({ width: -60, height: 60 }) do
            border('#E1E6EB', strokewidth: 1)
            inscription(team[:name], stroke: TEXT_COLOR, weight: 'bold', height: 200)
          end
          click do
            show_team(team)
          end
          hover do
            new_team.background PLAYER_SELECTED_COLOR
          end
          leave do
            new_team.background white
          end
        end
      end
    end

    new_team_styles = {
      width: (3 * WIDTH)/ 4,
      height: TEAM_FORM_HEIGHT,
      left: WIDTH/4,
      top: HEADER_HEIGHT
    }

    @new_team = stack(new_team_styles) do
      border('#E1E6EB', strokewidth: 1)
      caption('Nuevo Equipo', stroke: TEXT_COLOR)
      flow do
        inscription('Nombre:', stroke: TEXT_COLOR)
        @team_name = edit_line({ width: 200, left: 75 })
        state = @@program.championship_started? ? 'disable' : nil
        @add_team_btn = button('Agregar Equipo', left: 305, state: state) do
          validate_and_add_team
        end
      end
    end
    @team_info = flow({ width: (3 * WIDTH)/4, height: HEIGHT - HEADER_HEIGHT - TEAM_FORM_HEIGHT, left: WIDTH/4, top: HEADER_HEIGHT + TEAM_FORM_HEIGHT }) do
      background white
      border('#E1E6EB', strokewidth: 1)
      @team_info_title = flow({ height: 50 }) do
      end
      @team_players_form = flow({ height: 50 }) do
      end
      @team_players_list = flow({ height: HEIGHT - HEADER_HEIGHT - TEAM_FORM_HEIGHT - 100 }) do
      end
    end
  end

  private

  def validate_and_add_team
    @data = {
      name: @team_name.text
    }

    if @data.any?{ |field, value| value.nil? || value.empty? }
      alert('Todos los campos son obligatorios')
      return
    end

    response = @@program.add_team(@data[:name])
    if response.nil?
      @@team_colors[@team_name.text] = "%06x" % (rand * 0xffffff)
      visit('/teams')
    else
      alert(response)
    end
  end

  def validate_and_add_player_to_team(team_name)
    @data = {
      player: @player_without_team.text
    }

    if @data.any?{ |field, value| value.nil? || value.empty? }
      alert('Todos los campos son obligatorios')
      return
    end

    player_index = @player_without_team.items.index(@player_without_team.text)
    player_id = @available_players[player_index][:id]

    response = @@program.add_player_to_team(team_name, player_id)
    if response.nil?
      visit('/teams')
    else
      alert(response)
    end
  end

  def validate_and_add_player
    @data = {
      name: @name.text,
      ci: @ci.text,
      birthdate: @birthdate.text,
      position: @position.text
    }

    if @data.any?{ |field, value| value.nil? || value.empty? }
      alert('Todos los campos son obligatorios')
      return
    end

    @data[:birthdate] = valid_date(@data[:birthdate])
    if @data[:birthdate].nil?
      alert('La fecha de nacimiento es incorrecta.')
      return
    end

    response = @@program.add_player(@data[:ci], @data[:name], @data[:birthdate], @data[:position])
    if response.nil?
      @@player_images[@ci.text] = rand(7)
      visit('/players')
    else
      alert(response)
    end
  end

  def valid_date(date_string)
    Date.parse(date_string)
  rescue
    nil
  end

  def show_player(player)
    @player_info_title.clear {
      image("images/icons/tshirt.png", margin: 10)
      subtitle(player[:name], top: 5)
    }

    @player_info_description.clear {
      caption("C.I.: #{player[:ci]}", stroke: TEXT_COLOR, left: 10, top: 10)
      caption("Fecha Nac.: #{player[:birthdate].strftime('%d-%m-%Y')}", stroke: TEXT_COLOR, left: 10, top: 35)
      caption("Posicion: #{player[:position]}", stroke: TEXT_COLOR, left: 10, top: 60)
      case player[:position]
      when 'Arquero'
        caption("Goles en contra: #{player[:goals]}", stroke: TEXT_COLOR, left: 10, top: 85)
        caption("Goles en area chica: #{player[:small_box_goals]}", stroke: TEXT_COLOR, left: 10, top: 110)
      when 'Defensa'
        caption("Pases interceptados: #{player[:interceptions]}", stroke: TEXT_COLOR, left: 10, top: 85)
      when 'Volante'
        caption("Goles: #{player[:goals]}", stroke: TEXT_COLOR, left: 10, top: 85)
        caption("%pases exitosos: #{player[:percentage_passes]}", stroke: TEXT_COLOR, left: 10, top: 110)
      when 'Delantero'
        caption("Goles: #{player[:goals]}", stroke: TEXT_COLOR, left: 10, top: 85)
        caption("%efectividad: #{player[:percent_effectiveness]}", stroke: TEXT_COLOR, left: 10, top: 110)
      end
    }
  end

  def show_team(team)
    @team_info_title.clear {
      fill @@team_colors[team[:name]]
      rect(left: 5, top: 5, width:40, height: 40)
      subtitle(team[:name], left: 50, top: 5)
    }
    @available_players = @@program.players_without_team
    players_without_team_names = @available_players.map{ |p| p[:name] }

    @team_players_form.clear {
      inscription('Jugador:', stroke: TEXT_COLOR)
      @player_without_team = list_box({ items: players_without_team_names, width: 200, left: 75 })
      state = @@program.championship_started? ? 'disable' : nil
      @add_player_team_btn = button('Agregar Jugador', left: 305, state: state) do
        validate_and_add_player_to_team(team[:name])
      end
    }

    @team_players_list.clear {
      @@program.players_list_for_team(team[:name]).each do |player|
        flow({ width: 150, height: 100 }) do
          background white
          border('#E1E6EB', strokewidth: 1)
          new_image = @@player_images[player[:id].to_s]
          image("images/players/rsz_#{new_image}.png", top: 25, left: 56)
          inscription(player[:name], stroke: TEXT_COLOR, weight: 'bold', height: 200, align: 'center', top: 77)
        end
      end
    }
  end

end

Shoes.app(title: 'Forge Manager 2015', width: Main::WIDTH, height: Main::HEIGHT, resizable: false)
