class ResearchesController < ApplicationController

  def index
    @q = Research.ransack(params[:q]) 
    @researches = @q.result(distinct: true).includes(:findings).paginate(page: params[:page])    
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
    @research= Research.find(params[:id])
  end

  def update
    @research= Research.find(params[:id])
    if @research.update_attributes(research_params)
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
      params.require(:research).permit(:study_type, :authors,
                                   :title, :journal, :date_of_publication,
                                   :dropouts, :retracted, :peer_reviewed,
                                   :replicated, :version, :funding, :link,
                                   :single_blinded, :double_blinded,:randomized,
                                   :controlled_against_placebo,:controlled_against_best_alt,
                                   findings_attributes: [:id, :research_id, :finding, :quote, :sample_def, :_destroy])
    end
end

