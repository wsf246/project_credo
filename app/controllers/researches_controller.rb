class ResearchesController < ApplicationController

  def index
    @query = Research.ransack(params[:query]) 
    @researches = @query.result(distinct: true).includes(:findings).paginate(page: params[:page])    
  end

  def search
    index
    render :index
  end  
  
  def show
    @research = Research.find(params[:id])
    @findings = @research.findings
  end

  def new
    @research = Research.new
    @research.findings.build   
  end

  def create
    @research = Research.new(research_params)

    if @research.save	
      redirect_to @research
    else
      render 'new'
    end    
  end

  def edit
    @research = Research.find(params[:id])
  end

  def update
    @research = Research.find(params[:id])
    if @research.update_attributes(research_params)
      @research.score = 5

      flash[:success] = "Research attributes updated"
      redirect_to @research
    else
      render 'edit'
    end
  end

  def destroy
    Research.find(params[:id]).destroy
    flash[:success] = "Research attributes deleted."
    redirect_to debates_url
  end

   private

    def research_params
      params.require(:research).permit(researches_attributes: researches_attributes,
                                   findings_attributes: findings_attributes)
    end

    def researches_attributes
      %i{
        study_type authors title journal date_of_publication dropouts retracted
        peer_reviewed replicated version funding link single_blinded 
        double_blinded randomized score controlled_against_placebo 
        controlled_against_best_alt
      }
    end

    def findings_attributes
      [:id, :research_id, :finding, :quote, :sample_def, :_destroy]
    end
end

