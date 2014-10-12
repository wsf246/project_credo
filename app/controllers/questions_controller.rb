class QuestionsController < ApplicationController
  before_action :authenticate_user!, 
                only: [:edit, :update, :destroy, :new, :create, :upvote, :downvote, :add_verdict, :edit_verdict]
  
  def index
    @query = Question.ransack(params[:q]) 
    @questions = @query.result(distinct: true).paginate(page: params[:page])
  end

  def search
    index
    render :index
  end    
  
  def show
    @question = Question.find(params[:id])
    @verdicts = @question.verdicts.sort_by(&:vote_score).reverse
    @active = if params[:active] == nil then @verdicts.first.id else params[:active].to_i end    
    @evidence = @question.points.sort_by(&:vote_score).reverse
    @yes_evidence = @question.points.where(point_type: "Yes")
      .joins("LEFT JOIN associations ON points.id = associations.point_id")
      .joins("LEFT JOIN findings ON associations.finding_id = findings.id")
      .joins("LEFT JOIN researches ON findings.research_id = researches.id")
      .select('points.*, count(DISTINCT research_id) as "research_count", 
      max(researches.score) as "max_score"')
      .group("points.id").order('cached_votes_total desc, research_count desc, max_score desc') 
    @no_evidence = @question.points.where(point_type: "No")
      .joins("LEFT JOIN associations ON points.id = associations.point_id")
      .joins("LEFT JOIN findings ON associations.finding_id = findings.id")
      .joins("LEFT JOIN researches ON findings.research_id = researches.id")
      .select('points.*, count(DISTINCT research_id) as "research_count", 
      max(researches.score) as "max_score"')
      .group("points.id").order('cached_votes_total desc, research_count desc, max_score desc') 
   @unknown_evidence = @question.points.where(point_type: "Unknown")
      .joins("LEFT JOIN associations ON points.id = associations.point_id")
      .joins("LEFT JOIN findings ON associations.finding_id = findings.id")
      .joins("LEFT JOIN researches ON findings.research_id = researches.id")
      .select('points.*, count(DISTINCT research_id) as "research_count", 
      max(researches.score) as "max_score"')
      .group("points.id").order('cached_votes_total desc, research_count desc, max_score desc') 
@evid_page_count = ((@evidence.to_a.count/3.0).floor)
    @evid_count = (@evidence.to_a.count -1)
    
    respond_to do |format|
      format.html
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
    @question= Question.find(params[:id])
    @question_type = @question.question_type
  end

  def update
    @question= Question.find(params[:id])
    if @question.update_attributes(question_params)
      flash[:success] = "Question updated"
      redirect_to @question
    else
      render 'edit'
    end
  end

  def destroy
    Question.find(params[:id]).destroy
    flash[:success] = "Question deleted."
    redirect_to questions_url
  end

  def upvote
    @question = Question.find(params[:id])
    @question.upvote_from current_user
    redirect_to :back
  end

  def unvote
    @question = Question.find(params[:id])
    @question.unvote_by current_user
    redirect_to :back
  end

  def downvote
    @question = Question.find(params[:id])
    @question.downvote_from current_user
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
      @question = Question.find(params[:question])
      @verdict = @question.verdicts.build
      respond_to do |format|
        format.html { redirect_to @question }
        format.js  
      end 
  end 

  def select_verdict
      @question = Question.find(params[:question])
      @verdicts = @question.verdicts
      @selected = params[:selected].to_i
      respond_to do |format|
        format.html { redirect_to @question }
        format.js  
      end 
  end  

  def edit_verdict
      @question = Question.find(params[:question])
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
   
end
