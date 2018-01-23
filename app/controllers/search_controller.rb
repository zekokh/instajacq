class SearchController < ApplicationController
  def index
    @users = User.where(is_live?: true, is_blocked?: false)
    render json: @users
  end
end
