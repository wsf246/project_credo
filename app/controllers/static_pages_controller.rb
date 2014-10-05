class StaticPagesController < ApplicationController
  def home
    @query = Question.ransack(params[:q]) 
    @researches = @query.result(distinct: true).includes(:findings).paginate(page: params[:page], per_page: 10).order('score DESC')    
    @questions = Question.first(5)
  end

  def help
  end

  def contact
  end
end
