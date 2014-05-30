class FindingsController < ApplicationController

  def index
   @point = Point.find(params[:point])
   @q = Finding.ransack(params[:q]) 
   @findings = @q.result(distinct: true).includes(:research).paginate(page: params[:page])     
   @researches = Research.find(@findings.map {|a| a.research_id}.uniq)
  end

  def search
    index
    render :index
  end 
  
end   
