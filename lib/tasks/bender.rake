namespace :bender do
	desc "Робот который ищет участников конкурса"
	task :start => :environment do
		competition = Competition.find_by(is_live?: true)

	    unless competition.blank?
	      search_publications(competition, false, nil)

	      else
	      	puts "Нет запущенного конкурса..."
	    end
	end

	def search_publications(competition, flag_next_page, next_page_url)

      #Получаем все публикации которые есть
      publications = Publication.where(is_live?: true, is_blocked?: false)

      #Получаем последнюю публикацию
      last_publication = Publication.last

      #Устанавливаем дату последней публикации с которой стоит начинать искать
      date_and_time_start = competition[:date_and_time_start].to_time.to_i
      date_and_time_finish = competition[:date_and_time_finish].to_time.to_i

      #if last_publication
        #date_last_publication = last_publication[:date]
      #else
       # date_last_publication = competition[:date_and_time_start].to_time.to_i #1493596800
      #end


      #Берем всех пользователей которые существуют и не заблокирванны
      users = User.where(is_live?: true, is_blocked?: false)

      #Хэш тег по которому осуществляется поиск медиа
      tag = competition[:hashtag]



      if flag_next_page
        #Формируем адрес
        url_string = "https://www.instagram.com/explore/tags/#{tag}/?__a=1&max_id=#{next_page_url}"
      else
        url_string = "https://www.instagram.com/explore/tags/#{tag}/?__a=1"
      end

      #Кодируем в URL
      url = URI::encode(url_string)

      #Отправляем GET запрос
      doc = RestClient.get(url, {cookies: {'csrftoken' => 'HIw0PzUO51GHEocqS80YO6y6FtJomehV', 'ds_user_id' => '1703983654'}})

      #Парсим в JSON ответ
      json = JSON.parse(doc)

      #Сохраняем все полученные медиа
      edges = json['graphql']['hashtag']['edge_hashtag_to_media']['edges']
      has_next_page = json['graphql']['hashtag']['edge_hashtag_to_media']['page_info']['has_next_page']
      next_page = json['graphql']['hashtag']['edge_hashtag_to_media']['page_info']['end_cursor']


      #Получаем более подробную информацию и создаем объекты
      edges.each do |edge|
        puts "Спим"
        sleep(5)
        puts "Проснулись"
        #url_str = URI::encode("https://www.instagram.com/p/#{edge['node']['shortcode']}/?__a=1")
				url_str = URI::encode("https://www.instagram.com/p/#{edge['node']['shortcode']}/?__a=1")


        puts "Отправляем запрс..."
        #Отправляем GET запрос
        document = RestClient.get(url_str, {cookies: {'sessionid'=>'IGSC225facceac13b208e07d855bd22b2c84f2b7bce36f4cbc73c5c76b8d2ea1d60a%3AIVeCHfxClF5uwGORK5Wok5t6NKtLqUoG%3A%7B%22_auth_user_id%22%3A1703983654%2C%22_auth_user_backend%22%3A%22accounts.backends.CaseInsensitiveModelBackend%22%2C%22_auth_user_hash%22%3A%22%22%2C%22_platform%22%3A4%2C%22_token_ver%22%3A2%2C%22_token%22%3A%221703983654%3AxfaeezYn1wfQtI3yVZRwl4MlbcD96H1w%3Aa962ae76a8020dc36b54aa9065a805da9e9e9f3c664be7a0db8776f459b581dd%22%2C%22last_refreshed%22%3A1523610230.0870304108%7D','csrftoken' => 'HIw0PzUO51GHEocqS80YO6y6FtJomehV', 'ds_user_id' => '1703983654', 'mid' => 'WtByZAAEAAFWEe0UGOOLQccu_1-l'}})
        media = JSON.parse(document)
        media = media['graphql']['shortcode_media']

        #Владелец публикации
        user_owner = media['owner']
        puts "Владелец публикации #{user_owner}"

        #Пользователи которые отмечены на фото
        media_to_tagged_user = media['edge_media_to_tagged_user']['edges']
        puts "дата публикации: #{media['taken_at_timestamp']}"
        puts date_and_time_start
        #Если дата публикации позднее послденей добавленной
        #return if date_and_time_start > media['taken_at_timestamp']
        if date_and_time_start <= media['taken_at_timestamp'] && date_and_time_finish >= media['taken_at_timestamp']
        puts "Даты подходят..."
          #Если пользователя нет в базе участников то добавляем
          unless check_publication(media['shortcode'])
            Publication.create(date: media['taken_at_timestamp'],
                             url: media['display_url'],
                             code: media['shortcode'],
                             owner: media['owner']['id'])
            puts media['shortcode']


            unless check_user_by_nick(user_owner['username'])
              User.create(name: user_owner['full_name'],
                          nickname: user_owner['username'],
                          url: user_owner[''],
                          user_id: user_owner['id'],
                          number: generate_number+1)
              puts user_owner['username']
            end


            #Добавляем отмеченных пользователей
            media_to_tagged_user.each do |tagged_user|

              #Username пользователя
              user_name = tagged_user['node']['user']['username']

              #Если пользователя нет в списке участников
              unless check_user_by_nick(user_name)


                #Добавляем пользователя в список участников
                create_user_by_nick(user_name)
              end
            end
          end
        end
      end
        search_publications(competition, true, next_page) if has_next_page
  	end

  #Проверка пользователя по id
  def check_user(user_id)
    return true if nickname == 1703983654
    users = User.find_by(is_live?: true, is_blocked?: false, user_id: user_id)
    users.blank? ? false : true
  end

  def check_publication(code)
    puts "Наличие публикации"
    publication = Publication.find_by(is_live?: true, is_blocked?: false, code: code)
    puts publication.blank? ? false : true
    publication.blank? ? false : true
  end

  #Проверка пользователя по нику
  def check_user_by_nick(nickname)
    return true if nickname == "jacques_andre_"
    users = User.find_by(is_live?: true, is_blocked?: false, nickname: nickname)
    users.blank? ? false : true
  end

  #Создания пользователя по нику
  def create_user_by_nick(nick)

    User.create(name: '',
                      nickname: nick,
                      url: '',
                      user_id: '',
                      number: generate_number+1)
  end

  def generate_number
    user = User.last
    if !user.blank?
      return user[:number]
    else
      return 0
    end
  end
end
