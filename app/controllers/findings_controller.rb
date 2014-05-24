class FindingsController < ApplicationController

  def index
   @point = Point.find(params[:point])
   @q = Research.ransack(params[:q]) 
   @findings = @q.result(distinct: true).includes(:findings).paginate(page: params[:page])     
  end

  def search
    index
    render :index
  end 
  
end   