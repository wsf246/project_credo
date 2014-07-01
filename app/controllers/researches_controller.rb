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

  def pubmed_search
    new
    if params[:search_terms].present?
      require 'nokogiri'
      require 'open-uri'
      @search_terms = params[:search_terms].split.join("+")
      uid_url = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term="+@search_terms    
      uid_doc = Nokogiri::HTML(open(uid_url)) 
      @uid = uid_doc.xpath("//id").map {|uid| uid.text}.join(",")
      detail_url = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&id="+@uid
      @detail_doc = Nokogiri::HTML(open(detail_url))
      blah = @detail_doc.xpath("//docsum").map do |nodeset|
        [Hash["id", nodeset.xpath("id").text], nodeset.xpath("item[@name='AuthorList']|item[@name='Title']|item[@name='FullJournalName']").map do |node| 
          Hash[node.attributes["name"].value.downcase, node.text]
      end]
      end
      @details = Hash[blah]

      @authors = "hello world"
      #.xpath("//docsum").map do |node|
        #node.xpath("Author").text
      #end

      render :new
    else    
      render :new
    end
  end

  def new
    @uid = "Search results"
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

