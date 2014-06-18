class DebatesController < ApplicationController
  before_action :authenticate_user!, 
                only: [:edit, :update, :destroy, :new, :create, :important]
  
  def index
    @debates = Debate.order(:cached_votes_total).paginate(page: params[:page])
  end
  
  def show
    @debate = Debate.find(params[:id])
    @for_points = @debate.points.where(for_against: true).joins(:associations).joins(:findings).select('points.*, count(DISTINCT research_id) as "research_count"').group("points.id").order(' research_count desc').sort! {|a,b| b.votes_for.size <=> a.votes_for.size}+@debate.points.where(for_against: true).joins("LEFT JOIN associations ON points.id = point_id").where("point_id is null")    
    @against_points = @debate.points.where(for_against: false).joins(:associations).joins(:findings).select('points.*, count(DISTINCT research_id) as "research_count"').group("points.id").order(' research_count desc').sort! {|a,b| b.votes_for.size <=> a.votes_for.size} +@debate.points.where(for_against: false).joins("LEFT JOIN associations ON points.id = point_id").where("point_id is null")    
  end

  def new
    @debate = Debate.new
  end

  def create
    @debate = Debate.new(debate_params)
    if @debate.save	
      redirect_to @debate
    else
      render 'new'
    end    
  end

  def edit
    @debate= Debate.find(params[:id])
  end

  def update
    @debate= Debate.find(params[:id])
    if @debate.update_attributes(debate_params)
      flash[:success] = "Debate updated"
      redirect_to @debate
    else
      render 'edit'
    end
  end

  def destroy
    Debate.find(params[:id]).destroy
    flash[:success] = "Debate deleted."
    redirect_to debates_url
  end

  def important
    @debate = Debate.find(params[:id])
    @debate.upvote_from current_user
    redirect_to :back
  end

  def unimportant
    @debate = Debate.find(params[:id])
    @debate.unvote_by current_user
    redirect_to :back
  end     

   private

    def debate_params
      params.require(:debate).permit(:title, :description, :notes,
                                   :verdict)
    end
end
