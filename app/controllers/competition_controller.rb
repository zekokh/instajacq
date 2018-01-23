class CompetitionController < ApplicationController
	def index
		@current_competition = Competition.find_by(is_live?: true)
	end

	def new

		#Проверяем существует ли уже запущенный конкурс
		@current_competition = Competition.find_by(is_live?: true)

		#Если конкурс существует то перенаправляем на страницу с описанием конкурса
		if !@current_competition.blank?
			redirect_to competition_index_path, notice: 'У Вас уже запущен конкурс!' and return
		end

		@competition = Competition.new
	end

	def show
	end

	def create

		#Убираем все пробелы из хэштега и иницилизиурем переменную для хэштега
		hashtag = competition_params[:hashtag].delete(' ').delete('#')
		
		#Если все поля заполнены
		if !competition_params[:date_and_time_start].blank? && !competition_params[:date_and_time_finish].blank? && !hashtag.blank?
			
			#Дата начала конкурса
			date_start = DateTime::strptime(competition_params[:date_and_time_start], "%d.%m.%Y %H:%M")

			#Дата окончания конкурса
			date_finish = DateTime::strptime(competition_params[:date_and_time_finish], "%d.%m.%Y %H:%M")

			#Если дата окончания равна или раньше даты старта конкурса возвращаем ошибку
			redirect_to new_competition_path, notice: "Дата окончания не может быть раньше или такой же как дата начала конкурса!" if date_start >= date_finish
		end

		#Создвем и сохраняем информацию о конкурсе
		@competition = Competition.new(date_and_time_start: date_start, date_and_time_finish: date_finish, hashtag: hashtag)
	    if @competition.save

	    	#Если объект сохранился в БД перенаправляем на главную
	    	redirect_to competition_index_path, notice: 'Конкурс запущен!'
	    else

	    	#Если при сохранении возникли ошибки возвращаемся на страницу создания и отображаем ошибки
	    	render 'new', notice: "что то нетак"
	    end
	end

	#Завершаем конкурс
	def destroy
		@competition = Competition.find(params[:id])
    	@competition.update(is_live?: false)
    	User.delete_all
    	Publication.delete_all
    	redirect_to competition_index_path, notice: 'Кокурс завершен!'
	end

	def competition_params
    params.require(:competition).permit(:date_and_time_start,
                                     :date_and_time_finish,
                                     :hashtag)
  end
end
