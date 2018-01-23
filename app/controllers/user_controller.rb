class UserController < ApplicationController
	def index
		@users = User.where(is_live?: true, is_blocked?: false)
		@competition = Competition.find_by(is_live?: true)
	end
end
