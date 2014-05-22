class FindingsController < ApplicationController

  def index
   @q = Research.ransack(params[:q]) 
   @findings = @q.result(distinct: true).includes(:findings).paginate(page: params[:page])     
  end

  def search
    index
    render :index
  end 
  
end   