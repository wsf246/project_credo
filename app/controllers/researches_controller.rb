class ResearchesController < ApplicationController

  before_action :authenticate_user!, 
                only: [:edit, :update, :destroy, :new, :create]  

  before_action :get_research, 
                only: [:show, :edit, :update, :destroy, :undo_link, :edit_history]

  before_action :set_bias_controls, 
                only: [:update]
              
  def get_research
    @research = Research.find(params[:id])            
  end

  def index
    @query = Research.ransack(params[:q]) 
    @researches = @query.result(distinct: true).includes(:findings).paginate(page: params[:page], per_page: 10).order('score DESC')    
  end

  def search
    index
    render :index
  end  
  
  def show    
    @findings = @research.findings
    bias_controls = []

    @research.single_blinded ? bias_controls << "Single Blinded" : ""
    @research.double_blinded ? bias_controls << "Double Blinded" : ""
    @research.randomized ? bias_controls <<"Randomized" : ""
    @research.controlled_against_placebo ? bias_controls <<"Controlled Against Placebo" : ""
    @research.controlled_against_best_alt ? bias_controls << "Controlled Against Best Alternative(s)" : ""
    @bias_controls = bias_controls.join(", ")

    @study_type_score =
      Research.score_weights[@research.study_type]
    @verification_score =   
      Research.score_weights['Peer Reviewed'] * (@research.peer_reviewed ? 1 : 0) +
      Research.score_weights['Replicated'] * (@research.replicated ? 1 : 0)
    @bias_controls_score =
      Research.score_weights['Bias Control'] * (@research.single_blinded ? 1 : 0) + 
      Research.score_weights['Bias Control'] * (@research.double_blinded ? 1 : 0) + 
      Research.score_weights['Bias Control'] * (@research.randomized ? 1 : 0) +
      Research.score_weights['Bias Control'] * (@research.controlled_against_placebo ? 1 : 0) + 
      Research.score_weights['Bias Control'] * (@research.controlled_against_best_alt ? 1 : 0)
  end

  def pubmed_search
    @point_id = params[:point_id]
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
    @point_id = params[:point_id]
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

  def fill_in_form

    @research = Research.new
    @finding = @research.findings.build
    @finding_id = @finding.id    
    @study_type = 'Unknown'
    @point_id = params[:point_id]
    @pubdate = 
      if params[:pubdate].length == 4
        "1-1-"+params[:pubdate]
      else
        params[:pubdate]  
      end

  
    respond_to do |format|
      format.html { redirect_to new }
      format.js 
    end
  end

  def edit_in_form
    require 'nokogiri'
    require 'open-uri'
    @point_id = params[:point_id]
    @pubmed_id = params[:id]
    article_url = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id="+@pubmed_id+"&retmode=xml"    
    article_doc = Nokogiri::HTML(open(article_url)) 
    @article = {}

    @article["title"] = article_doc.xpath("//articletitle").text
    @article["authors"] = params[:authors]  
    @article["journal"] = article_doc.xpath("//journal//title").text.titleize
    @article["pubdate"] = params[:pubdate]  
    @article["abstract"] = article_doc.xpath("//abstracttext").text  
    @research = Research.where(title: params[:title]).first
    @study_type = @research.study_type 
  
    respond_to do |format|
      format.html { redirect_to new }
      format.js 
    end
  end  

  def new
    @research = Research.new
    @research.findings.build
    @study_type = 'Unknown'   
  end

  def create
    @research = Research.new(research_params)
    @point = Point.find(params[:point_id])  
    if @research.save	
      @research.score_it
      @research.user_create_id = current_user
      @finding = @research.findings.order("created_at").last 
      @point.associate!(@finding)
      redirect_to question_path(@point.question)  
    else
      @study_type = @research.study_type  
      render 'new', point_id: @point_id
    end    
  end

  def edit
    @study_type = @research.study_type     
  end

  def update
    if @research.update_attributes(research_params) && params[:edit] =="y"
      @point = Point.find(params[:point_id])
      @research.score_it
      if @research.findings.count > 1
        redirect_to select_findings_question_path(point: @point, research: @research)
      elsif @point.findings.where(research: @research).count == 0
        @research.findings.each do |finding|
          @point.associate!(finding)
        end
        flash[:success] = "Evidence added"
        redirect_to question_path(@point.question)  
      else  
        flash[:success] = "Research attributes updated"
        redirect_to question_path(@point.question)
      end
    elsif @research.update_attributes(research_params) 
      @research.score_it   
      flash[:success] = "Research attributes updated"
      redirect_to @research  
    else 
      render 'edit', edit: params[:edit]
    end
  end

  def destroy
    @research.destroy
    flash[:success] = "Research attributes deleted."
    redirect_to questions_url
  end

  def edit_history
    versions = 
      PaperTrail::Version.where(item_id: @research).where(item_type: "Research") +
      PaperTrail::Version.where_object(research_id: @research.id).where(event: "destroy")
     
    @research.findings.each do |finding|
      finding.versions.each do |v|
        versions << v
      end
    end    

    @versions = versions.sort_by{|v| v[:created_at]}.reverse
  end  

   private
    def undo_link
      view_context.link_to("undo", revert_version_path(@research.versions.last), :method => :post)
    end

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

    def set_bias_controls
      if params[:research][:study_type] == 'Cross Sectional' || params[:research][:study_type] == 'Case Study'
        params[:research][:single_blinded] = false
        params[:research][:double_blinded] = false
        params[:research][:randomized] = false
        params[:research][:controlled_against_placebo] = false
        params[:research][:controlled_against_best_alt] = false
      elsif params[:research][:study_type] == 'Case Control' || params[:research][:study_type] == 'Cohort Study'
        params[:research][:single_blinded] = false
        params[:research][:double_blinded] = false
        params[:research][:randomized] = false
      elsif params[:research][:study_type] == "Randomized Control Trial"
        params[:research][:randomized] = true
      end
    end  
end

