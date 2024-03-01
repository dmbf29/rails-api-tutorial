class Api::V1::CriteriaController < ApplicationController
  def index
    @criteria = Cafe.pluck(:criteria).flatten.uniq
    render json: @criteria
  end
end
