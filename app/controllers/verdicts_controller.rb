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
end