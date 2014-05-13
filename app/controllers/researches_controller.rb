class ResearchesController < ApplicationController

  def index
    @researches = Research.paginate(page: params[:page])
  end
  
  def show
    @research = Research.find(params[:id])
    @quotes = @research.quotes
    @sample_defs = @research.sample_defs
    @findings = @research.findings
  end

  def new
    @research = Research.new
    @research.quotes.build   
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
                                   quotes_attributes: [:id, :research_id, :quote, :_destroy],
                                   findings_attributes: [:id, :research_id, :finding, :_destroy],
                                   sample_defs_attributes: [:id, :research_id, :sample_def, :_destroy])
    end
end

