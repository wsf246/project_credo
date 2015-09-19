class QuestionsController < ApplicationController
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::NumberHelper
  before_action :authenticate_user!,
                only: [:edit, :update, :destroy, :new, :create, :upvote, :downvote, :add_verdict, :edit_verdict, :remove_finding]

  before_action :get_question,
                only: [:show, :edit, :update, :destroy, :upvote, :downvote, :unvote, :undo_link, :edit_history]

  def get_question
    @question = Question.friendly.find(params[:id])
  end

  def index
    @questions = @query.result.to_a.uniq.paginate(page: params[:page])
  end

  def search
    index
    render :index
  end

  def show
    @verdicts = @question.verdicts.sort_by(&:vote_score).reverse
    @active_verdict =
        if @verdicts.present?
          if params[:active] == nil
            @verdicts.first.id
          else
            params[:active].to_i
          end
        end

    @active_point = params[:active_point].to_i
    @evidence = @question.researches
    @evid_page_count = ((@evidence.to_a.count/3.0).floor)
    @evid_count = (@evidence.to_a.count -1)


  end

  def new
    @question = Question.new
    @question_type = 'Yes/No'
  end

  def create
    @question = Question.new(question_params)
    if @question.save
      @question.update_attributes(user_create_id: current_user.id)
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

    versions =
        PaperTrail::Version.where(item_id: @question).where(item_type: "Question") +
            PaperTrail::Version.where_object(question_id: @question.id).where(item_type: "Verdict").where(event: "destroy")

    @question.verdicts.each do |verdict|
      verdict.versions.each do |v|
        versions << v
      end
    end

    @question.researches.each do |research|
      research.versions.each do |v|
        versions << v
      end
    end

    @question.associations.each do |association|
      association.versions.each do |v|
        versions << v
      end
    end

    @versions = versions.sort_by{|v| v[:created_at]}.reverse

  end

  def upvote
    @question.upvote_from current_user
    respond_to do |format|
      format.html { redirect_to "index" }
      format.js { render 'question_vote.js.erb' }
    end
  end

  def downvote
    @question.downvote_from current_user
    respond_to do |format|
      format.html { redirect_to "index"}
      format.js { render 'question_vote.js.erb' } 
    end
  end

  def unvote
    @question.unvote_by current_user
    respond_to do |format|
      format.html { redirect_to "index" }
      format.js { render 'question_vote.js.erb' } 
    end
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

  def select_findings
    @association = Association.new
    @point = Point.find(params[:point])
    @question = @point.question
    @research = Research.find(params[:research])
    @findings = @research.findings.reject(&:blank?)
    @logged = @point.findings.where(research: @research).map(&:id)
  end

  def remove_finding
    finding = Finding.find(params[:finding])
    point = Point.find(params[:point])
    association = point.associations.find_by(finding_id: finding.id)
    association.destroy if association.present?
    redirect_to question_path(point.question, active_point: point.id)
  end

  private

  def question_params
    params.require(:question).permit(:question, :answers, :description, :notes, :question_type, 
                                     verdicts_attributes: verdicts_attributes)
  end

  def verdicts_attributes
    [:id, :question_id, :verdict, :user_create_id, :_destroy]
  end

  def undo_link
    view_context.link_to("undo", revert_version_path(@question.versions.last), :method => :post)
  end
end
