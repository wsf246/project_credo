class DebatesController < ApplicationController
  before_action :authenticate_user!, 
                only: [:edit, :update, :destroy, :new, :create, :important, :add_verdict]
  
  def index
    @debates = Debate.order(:cached_votes_total).paginate(page: params[:page])
  end
  
  def show
    @debate = Debate.find(params[:id])
    @verdicts = @debate.verdicts
    @evidence = @debate.points
      .joins("LEFT JOIN associations ON points.id = associations.point_id")
      .joins("LEFT JOIN findings ON associations.finding_id = findings.id")
      .select('points.*, count(DISTINCT research_id) as "research_count"')
      .group("points.id").order('cached_votes_total desc, research_count desc') 
    @evid_page_count = ((@evidence.to_a.count/3.0).floor)
    
    respond_to do |format|
      format.html
      format.csv { render text: @evidence.to_csv }
    end
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

  def all_research
    @point = Point.find(params[:point])

    respond_to do |format|
      format.html { redirect_to @debate }
      format.js  
    end   
  end 

  def less_research
    @point = Point.find(params[:point])

    respond_to do |format|
      format.html { redirect_to @debate }
      format.js  
    end   
  end               

  def add_verdict
    if user_signed_in?
      @debate = Debate.find(params[:debate])
      @verdict = @debate.verdicts.build
      respond_to do |format|
        format.html { redirect_to @debate }
        format.js  
      end 
    else 
    redirect_to @debates
    end  
  end  

   private

    def debate_params
      params.require(:debate).permit(:title, :description, :notes, :user_create_id,
                                   verdicts_attributes: [:id, :debate_id, :verdict, :user_create_id, :_destroy])
    end
end
