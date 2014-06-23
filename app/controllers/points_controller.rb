class PointsController < ApplicationController

  before_action :authenticate_user!, 
                only: [:edit, :update, :destroy, :new, :create, :important]

  def index
  end

  def new
    case params[:point_type]
      when 'For' then @for_against = true
      when 'Against' then @for_against = false
    end

    @debate = Debate.find(params[:debate_id])
    @point = @debate.points.build

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
    @debate = Debate.find(params[:debate_id])    
    @point = @debate.points.build(point_params)
    if @point.save
      @point.user_create_id = current_user	
      redirect_to @debate
    else
      render 'new'
    end    
  end

  def edit
    @point = Point.find(params[:id])
    @debate = @point.debate
    @for_against = @point.for_against
  end

  def update
    @point= Point.find(params[:id]) 
    @debate = @point.debate
    if @point.update_attributes(point_params)
      flash[:success] = "Point updated"
      redirect_to @debate
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
      params.require(:point).permit(:point, :for_against, :user_create_id, findings_attributes: [:id])
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
