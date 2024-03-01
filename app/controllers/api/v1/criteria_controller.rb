class Api::V1::CriteriaController < ApplicationController
  def index
    @criteria = Cafe.pluck(:criteria).uniq
    render json: @criteria
  end
end
