class PointsController < ApplicationController

  before_action :authenticate_user!, 
                only: [:edit, :update, :destroy, :new, :create, :important]

  def index
    @question = Question.find(params[:question_id])
    @evidence = @question.points
      .joins("LEFT JOIN associations ON points.id = associations.point_id")
      .joins("LEFT JOIN findings ON associations.finding_id = findings.id")
      .select('points.*, count(DISTINCT research_id) as "research_count"')
      .group("points.id").order('cached_votes_total desc, research_count desc')  
  end

  def new
    @question = Question.find(params[:question_id])
    @point = @question.points.build
    @point_type = 'Unknown'
  end

  def search

  end 

  def important
    @point = Point.find(params[:id])
    @point.upvote_from current_user
    redirect_to :back
  end

  def unimportant
    @point = Point.find(params[:id])
    @point.unvote_by current_user
    redirect_to :back
  end   

  def create
    @question = Question.find(params[:question_id])    
    @point = @question.points.build(point_params)
    if @point.save
      @point.user_create_id = current_user	
      redirect_to @question
    else
      render 'new'
    end    
  end

  def edit
    @point = Point.find(params[:id])
    @question = @point.question
    @point_type = @point.point_type
  end

  def update
    @point= Point.find(params[:id]) 
    @question = @point.question
    if @point.update_attributes(point_params)
      flash[:success] = "Point updated"
      redirect_to @question
    else
      render 'edit'
    end
  end

   private

    def research_params
      params.require(:research).permit(researches_attributes: researches_attributes,
                                      findings_attributes: findings_attributes)
    end  

    def point_params
      params.require(:point).permit(:point, :point_type, :user_create_id, findings_attributes: [:id])
    end

    def researches_attributes
      %i{
        study_type authors title journal date_of_publication dropouts 
        retracted peer_reviewed replicated version funding link 
        single_blinded double_blinded randomized controlled_against_placebo 
        controlled_against_best_alt _destroy
      }
    end

    def findings_attributes
      %i{id research_id finding quote sample_def _destroy}      
    end
end
