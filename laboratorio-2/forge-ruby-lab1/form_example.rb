require_relative 'utils/form'

def get_student_data
  form = Form.new('Ingresa la información del usuario',
                  first_name: 'Nombre', last_name: 'Apellido')
  form.ask_for(:first_name, :last_name)

  colors = ['Rojo', 'Verde', 'Azul', 'Amarillo']
  color = form.select_from_list('Ingresa el color favorito: ', colors)

  puts ''
  puts 'Datos del usuario:'
  puts "Nombre: #{form.get_data[0]}"
  puts "Apellido: #{form.get_data[1]}"
  puts "Color favorito: #{color}"
end


get_student_data