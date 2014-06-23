class ResearchesController < ApplicationController

  before_action :authenticate_user!, 
                only: [:edit, :update, :destroy, :new, :create]  

  def index
    @query = Research.ransack(params[:q]) 
    @researches = @query.result(distinct: true).includes(:findings).paginate(page: params[:page]).order('score DESC')    
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
    @study_type = 'Unknown'   
  end

  def create
    @research = Research.new(research_params)

    if @research.save	
      @research.score_it
      @research.user_create_id = current_user
      redirect_to @research
    else
      render 'new'
    end    
  end

  def edit
    @research = Research.find(params[:id])
    @study_type = @research.study_type     
  end

  def update
    @research = Research.find(params[:id])
    if @research.update_attributes(research_params)
      @research.score_it
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
      params.require(:research).permit(researches_attributes,
                                   findings_attributes: findings_attributes)
    end

    def researches_attributes
      %i{
        study_type authors title journal date_of_publication dropouts retracted
        peer_reviewed replicated version funding link single_blinded 
        double_blinded randomized score controlled_against_placebo 
        controlled_against_best_alt user_create_id
      }
    end

    def findings_attributes
      [:id, :research_id, :finding, :quote, :sample_def, :_destroy]
    end
end

