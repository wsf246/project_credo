class VerdictsController < ApplicationController
  before_action :authenticate_user!, 
                only: [:edit, :update, :destroy, :upvote, :downvote, :new, :create, :destroy]
  before_action :get_verdict, 
                only: [:show, :edit, :update, :destroy, :upvote, :downvote, :unvote, :undo_link]

  def get_verdict
    @verdict = Verdict.find(params[:id])
  end
  def upvote
    @verdict.upvote_from current_user
    redirect_to :back
  end

  def downvote
    @verdict.downvote_from current_user
    redirect_to :back
  end

  def unvote
    @verdict.unvote_by current_user
    redirect_to :back
  end  

  def create
    @question = Question.friendly.find(params[:question_id])       
    @verdict= @question.verdicts.build(verdict_params)
    if @verdict.save      
      redirect_to @question
    else
      render 'questions/verdicts/_verdict_form'
    end    
  end     

  def edit
  end

  def update
    @question = @verdict.question 
    active = params[:id]  
    if @verdict.update_attributes(verdict_params)
      flash[:success] = "Verdict updated"
      redirect_to question_path(id: @question.id, active: active)
    else
      render 'questions/verdicts/_verdict_form'
    end    
  end 

  def destroy
    @question = @verdict.question  
    if current_user.id == @verdict.user_create_id
      @verdict.destroy
      flash[:success] = "Verdict deleted, #{undo_link}"
      redirect_to @question
    else
      flash[:error] = "You can only delete verdicts you've created"
      redirect_to @question
    end  
  end
         
  private

    def verdict_params
      params.require(:verdict).permit(:question_id,:user_create_id,:verdict,:short)
    end

    def undo_link
      view_context.link_to("undo", revert_version_path(@verdict.versions.last), :method => :post)
    end      
end    