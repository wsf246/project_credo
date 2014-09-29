class VerdictsController < ApplicationController
  before_action :authenticate_user!, 
                only: [:edit, :update, :destroy, :new, :create, :important]

  def bump
    @verdict = Verdict.find(params[:id])
    @verdict.upvote_from current_user
    redirect_to :back
  end

  def unbump
    @verdict = Verdict.find(params[:id])
    @verdict.unvote_by current_user
    redirect_to :back
  end  

  def create
    @question = Question.find(params[:question_id])       
    @verdict= @question.verdicts.build(verdict_params)
    if @verdict.save      
      redirect_to @question
    else
      render 'questions/verdicts/_verdict_form'
    end    
  end     

  def edit
    @verdict= Verdict.find(params[:id])
  end

 def update
    @verdict= Verdict.find(params[:id])  
    @question = @verdict.question    
    if @verdict.update_attributes(verdict_params)
      flash[:success] = "Verdict updated"
      redirect_to @question
    else
      render 'questions/verdicts/_verdict_form'
    end    
  end 

         
  private

    def verdict_params
      params.require(:verdict).permit(:question_id,:user_create_id,:verdict,:short)
    end  
end    