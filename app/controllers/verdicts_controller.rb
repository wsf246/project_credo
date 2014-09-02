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
    @debate = Debate.find(params[:debate_id])       
    @verdict= @debate.verdicts.build(verdict_params)
    if @verdict.save
      
      redirect_to @debate
    else
      render 'debates/_verdict_form'
    end    
  end     

  def edit
    @verdict= Verdict.find(params[:id])
  end
         
  private

    def verdict_params
      params.require(:verdict).permit(:debate_id,:user_create_id,:verdict)
    end  
end    