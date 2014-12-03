class PointsController < ApplicationController

  before_action :authenticate_user!, 
                only: [:edit, :update, :destroy, :new, :create, :upvote, :downvote]
 
  before_action :get_question, 
                only: [:index, :new, :create]
                
  def get_question
    @question = Question.friendly.find(params[:question_id])              
  end   
                
  def index
    @evidence = @question.points
      .joins("LEFT JOIN associations ON points.id = associations.point_id")
      .joins("LEFT JOIN findings ON associations.finding_id = findings.id")
      .select('points.*, count(DISTINCT research_id) as "research_count"')
      .group("points.id").order('cached_votes_total desc, research_count desc')  
  end

  def new
    @point = @question.points.build
    @point_type = 'Unknown'
    @answers = @question.answers.split(",") if @question.answers != nil
  end

  def search

  end 

  def upvote
    @point = Point.find(params[:id])
    @point.upvote_from current_user
    @question = @point.question
    respond_to do |format|
      format.html { redirect_to @question }
      format.js { render 'questions/evidence/evidence_vote.js.erb' } 
    end    
  end

  def downvote
    @point = Point.find(params[:id])    
    @point.downvote_from current_user
    @question = @point.question
    respond_to do |format|
      format.html { redirect_to @question }
      format.js { render 'questions/evidence/evidence_vote.js.erb' } 
    end
  end

  def unvote
    @point = Point.find(params[:id])
    @point.unvote_by current_user
    @question = @point.question
    respond_to do |format|
      format.html { redirect_to @question }
      format.js { render 'questions/evidence/evidence_vote.js.erb' } 
    end    
  end   

  def create  
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
    @answers = @question.answers.split(",").push(@point_type, "Unknown").uniq if @question.answers != nil

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
