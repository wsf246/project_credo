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
    if params[:search_terms].present?
      require 'nokogiri'
      require 'open-uri'
      @search_terms = params[:search_terms].split.join("+")
      uid_url = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term="+@search_terms    
      uid_doc = Nokogiri::HTML(open(uid_url)) 
      uid = uid_doc.xpath("//id").map {|uid| uid.text}.join(",")
      detail_url = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&id="+uid
      detail_doc = Nokogiri::HTML(open(detail_url))

      @articles = []

      detail_doc.xpath("//docsum").map do |article|
        parsed_article = {}

        article.children.map do |field|
          
          if field.name.downcase == 'id'
            parsed_article['id'] = field.text
          end

          if field.attr('name') == 'PubDate'
            parsed_article['pubdate'] = field.text
          end

          if field.attr('name') == 'Title'
            parsed_article['title'] = field.text
          end
          
          if field.attr('name') == 'PubTypeList'
            parsed_article['type'] = field.element_children.text
          end  

          if field.attr('name') == 'AuthorList'
            authors = field.element_children.map do |f|
              f.text
            end
            parsed_article['authors'] = authors  
          end


          if field.attr('name') == 'FullJournalName'
            parsed_article['journal'] = field.text.titleize
          end                                                     
        end

        @articles << parsed_article
      end

      respond_to do |format|
        format.html { redirect_to new }
        format.js 
      end
    else    
      respond_to do |format|
        format.html { redirect_to new }
        format.js 
      end
    end
  end

  def view_result
    require 'nokogiri'
    require 'open-uri'
    @pubmed_id = params[:id]
    article_url = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id="+@pubmed_id+"&retmode=xml"    
    article_doc = Nokogiri::HTML(open(article_url)) 
    @article = {}

    @article["title"] = article_doc.xpath("//articletitle").text
    @article["authors"] = params[:authors]  
    @article["journal"] = article_doc.xpath("//journal//title").text.titleize
    @article["pubdate"] = params[:pubdate]  
    @article["abstract"] = article_doc.xpath("//abstracttext").text  


    respond_to do |format|
      format.html { redirect_to new }
      format.js 
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

