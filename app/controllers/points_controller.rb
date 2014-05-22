class PointsController < ApplicationController

  def index
    @q = Point.search(params[:q]) 
    @findings = @q.result 
  end

  def new
    case params[:point_type]
    when 'For'
      @for_against = true
    when 'Against'
      @for_against = false
    end    
    @debate = Debate.find(params[:debate_id])
    @point = @debate.points.build
    @path = [@debate,@point]     
  end

  def search

  end  

  def create
    @debate = Debate.find(params[:debate_id])    
    @point = @debate.points.build(point_params)
    if @point.save	
      redirect_to @debate
    else
      render 'new'
    end    
  end

  def edit
    @point = Point.find(params[:id])
    @path = @point
    @debate = @point.debate
  end

  def update
    @point= Point.find(params[:id]) 
    @path = @point 
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
      params.require(:research).permit(researches_attributes: [:study_type, :authors,
                                   :title, :journal, :date_of_publication,
                                   :dropouts, :retracted, :peer_reviewed,
                                   :replicated, :version, :funding, :link,
                                   :single_blinded, :double_blinded,:randomized,
                                   :controlled_against_placebo,:controlled_against_best_alt, :_destroy],
                                   findings_attributes: [:id, :research_id, :finding, :quote, :sample_def, :_destroy])
    end  

    def point_params
      params.require(:point).permit(:point, :for_against, findings_attributes: [:id])
    end  
end
