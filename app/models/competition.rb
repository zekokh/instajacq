class Competition < ApplicationRecord
	validates :date_and_time_start, :date_and_time_finish, :hashtag, presence: {message: "должно быть заполненно!"}
end
