class PublicationController < ApplicationController
	def index
		@publications = Publication.where(is_live?: true, is_blocked?: false)
		@competition = Competition.find_by(is_live?: true)
	end
end
