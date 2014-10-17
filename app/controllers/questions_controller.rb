class QuestionsController < ApplicationController
  before_action :authenticate_user!, 
                only: [:edit, :update, :destroy, :new, :create, :upvote, :downvote, :add_verdict, :edit_verdict]

  before_action :get_question, 
                only: [:show, :edit, :update, :destroy, :upvote, :downvote, :unvote, :undo_link, :edit_history]

  def get_question
    @question = Question.friendly.find(params[:id])              
  end              

  def index
    @query = Question.ransack(params[:q]) 
    @questions = @query.result.paginate(page: params[:page])
  end

  def search
    index
    render :index
  end    
  
  def show
    @verdicts = @question.verdicts.sort_by(&:vote_score).reverse
    @active = 
      if @verdicts.present?
        if params[:active] == nil 
          @verdicts.first.id 
        else 
          params[:active].to_i 
        end
      end    
    @evidence = @question.points.joins("LEFT JOIN associations ON points.id = associations.point_id")
      .joins("LEFT JOIN findings ON associations.finding_id = findings.id")
      .joins("LEFT JOIN researches ON findings.research_id = researches.id")
      .select('points.*, count(DISTINCT research_id) as "research_count", 
      max(researches.score) as "max_score", 
      (cached_votes_up-cached_votes_down)*cached_votes_total as "vote_score"')
      .group("points.id").order('vote_score desc, research_count desc, max_score desc') 
    @yes_evidence = @evidence.where(point_type: "Yes")
    @no_evidence = @evidence.where(point_type: "No")
    @unknown_evidence = @evidence.where(point_type: "Unknown")
    @evid_page_count = ((@evidence.to_a.count/3.0).floor)
    @evid_count = (@evidence.to_a.count -1)
    
    respond_to do |format|
      format.html {    
        if request.path != question_path(@question)
          redirect_to @question, status: :moved_permanently
        end
      }
      format.csv { render text: @evidence.to_csv }
    end
  end

  def new
    @question = Question.new
    @question_type = 'Yes/No'
  end

  def create
    @question = Question.new(question_params)
 
    if @question.save	
      redirect_to @question
    else
      render 'new'
    end    
  end

  def edit
    @question_type = @question.question_type
  end

  def update
    if @question.update_attributes(question_params)
      flash[:success] = "Question updated, #{undo_link}"
      redirect_to @question
    else
      render 'edit'
    end
  end

  def destroy
    @question.destroy
    flash[:success] = "Question deleted."
    redirect_to questions_url
  end

  def edit_history
    versions = []
    attributes = @question.points + @question.verdicts + [@question]
    
    attributes.each do |attribute|
      attribute.versions.each do |v|
        versions << v
      end
    end

    @versions = versions.sort_by{|v| v[:created_at]}.reverse
  

  end
    
  def upvote
    @question.upvote_from current_user
    redirect_to :back
  end

  def downvote
    @question.downvote_from current_user
    redirect_to :back
  end

  def unvote
    @question.unvote_by current_user
    redirect_to :back
  end  

  def all_research
    @point = Point.find(params[:point])

    respond_to do |format|
      format.html { redirect_to @question }
      format.js  
    end   
  end 

  def less_research
    @point = Point.find(params[:point])

    respond_to do |format|
      format.html { redirect_to @question }
      format.js  
    end   
  end               

  def add_verdict
      @question = Question.friendly.find(params[:question])
      @verdict = @question.verdicts.build
      respond_to do |format|
        format.html { redirect_to @question }
        format.js  
      end 
  end 

  def select_verdict
      @question = Question.friendly.find(params[:question])
      @verdicts = @question.verdicts
      @selected = params[:selected].to_i
      respond_to do |format|
        format.html { redirect_to @question }
        format.js  
      end 
  end  

  def edit_verdict
      @question = Question.friendly.find(params[:question])
      @verdict = Verdict.find(params[:verdict])
      respond_to do |format|
        format.html { redirect_to @question }
        format.js   
      end 
  end   

   private

    def question_params
      params.require(:question).permit(:question, :answers, :description, :notes, :question_type, :user_create_id,
                                   verdicts_attributes: verdicts_attributes)
    end

    def verdicts_attributes
      [:id, :question_id, :verdict, :user_create_id, :_destroy]
    end 
   
    def undo_link
      view_context.link_to("undo", revert_version_path(@question.versions.last), :method => :post)
    end
end
