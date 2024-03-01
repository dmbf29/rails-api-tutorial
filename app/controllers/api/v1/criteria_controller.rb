class Api::V1::CriteriaController < ApplicationController
  def index
    @criteria = Cafe.pluck(:criteria).uniq.flatten
    render json: @criteria
  end
end
