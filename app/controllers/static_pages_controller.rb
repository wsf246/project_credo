class StaticPagesController < ApplicationController
  def home
    @questions = Question.first(5)
  end

  def help
  end

  def contact
  end
end
