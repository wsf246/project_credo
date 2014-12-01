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

    yes_total_cred = @yes_evidence.map{|b| b.findings.map{|a| a.research}}.flatten.uniq.map{|a| a.score}.sum
    no_total_cred = @no_evidence.map{|b| b.findings.map{|a| a.research}}.flatten.uniq.map{|a| a.score}.sum
    unknown_total_cred = @unknown_evidence.map{|b| b.findings.map{|a| a.research}}.flatten.uniq.map{|a| a.score}.sum


    yes_research = @question.points.where(point_type: "Yes").map{|b| b.findings.map{|a| a.research}}.flatten.uniq.map{|a| a}
    prob = 0.5
    yes_research.each do |evid|
      if evid.score != 0
        prob = (prob*evid.true_pos)/(prob*evid.true_pos+(1-prob)*evid.false_pos)
      end
    end
    no_research = @question.points.where(point_type: "No").map{|b| b.findings.map{|a| a.research}}.flatten.uniq.map{|a| a}
    no_research.each do |evid|
      if evid.score != 0
        prob = prob*(1-evid.true_pos)/(prob*(1-evid.true_pos)+(1-prob)*(1-evid.false_pos))
      end
    end
    posterior = ActionController::Base.helpers.number_to_percentage(prob*100,{precision:1})


    @donut =
      LazyHighCharts::HighChart.new('donut') do |f|
        f.chart({defaultSeriesType: 'pie', :margin=> [0, 0, 0, 0], height: 225, width: 225})
        f.colors(["#04a8d4", "#4b4b4b"])
        f.legend({enabled: false})
        f.title({
          text: if prob > 0.999  then "99.9%" else posterior end,
          style: {
              fontFamily: "@font-face",
              fontSize: "54px",
              color: "#04a8d4"
          },
          y: 105
        })
        f.subtitle({
         text: "Credo Score",
         style: {
           fontFamily: "Arial",
           fontSize: "20px",
           color: "#04a8d4"
         },
         y: 135
        })
        series = {
          name: 'Probability',
          data: [["Yes", if prob > 0.999 then 99.9 else prob*100 end],["No",(1-prob)*100]],
          innerSize: 190,
          minSize: "130px",
          showInLegend:true,
          tooltip: {valueDecimals: 2},
          dataLabels: {
            enabled: false,
          }
        }
        f.series(series)
      end

    @yes_researches =[]
    @yes_evidence.each do |point|
      point.findings.each do |finding|
        @yes_researches << {
            x: finding.research.date_of_publication.to_datetime.to_i*1000,
            y:finding.research.score,
            title:truncate(finding.research.title,length:25),
            authors:truncate(finding.research.authors,length:25)
        }
      end
    end

    @no_researches =[]
    @no_evidence.each do |point|
      point.findings.each do |finding|
        @no_researches << {
            x: finding.research.date_of_publication.to_datetime.to_i*1000,
            y:finding.research.score,
            title:truncate(finding.research.title,length:25),
            authors:truncate(finding.research.authors,length:25)
        }
      end
    end

    @scatter_timeline=
        LazyHighCharts::HighChart.new('scatter_timeline') do |f|
          f.chart({:defaultSeriesType=>"scatter", height: 200})
          f.legend({enabled: true, vertical_align: 'top', align: "center"})
          f.xAxis({
                      type: 'datetime',
                      minTickInterval: 24 * 3600* 1000,
                      title: {
                        text: 'Publication Date',
                        style: {
                          color:"#4b4b4b"
                        }
                      }
                  })
          f.yAxis({
                      min: 0,
                      tickInterval: 66.5,
                      title: {
                        text: '- Credibility +',
                        style: {
                          color:"#4b4b4b"
                        }
                      },
                      labels: {
                          enabled: false
                      },

                  })


          f.plot_options(column: {
                             colorByPoint: true
                         })

          yes_series =
              {
                  type: 'scatter',
                  name: 'Yes',
                  color: "#04a8d4",
                  tooltip: {pointFormat:"{point.title}<br />{point.authors}<br />Cred: {point.y}", valueDecimals: 1},
                  data: @yes_researches,
                  marker: {
                      symbol: "circle",
                      radius: 6
                  }
              }
          no_series =
              {
                  type: 'scatter',
                  name: 'No',
                  color: "#4b4b4b",
                  tooltip: {pointFormat:"{point.title}<br />{point.authors}<br />Cred: {point.y}", valueDecimals: 1},
                  data: @no_researches,
                  marker: {
                      symbol: "circle",
                      radius: 6
                  }
              }

          f.series(yes_series)
          f.series(no_series)
        end
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

    versions =
        PaperTrail::Version.where(item_id: @question).where(item_type: "Question") +
            PaperTrail::Version.where_object(question_id: @question.id).where(item_type: "Verdict").where(event: "destroy")

    @question.points.each do |point|
      point.versions.each do |v|
        versions << v
      end
    end

    @question.verdicts.each do |verdict|
      verdict.versions.each do |v|
        versions << v
      end
    end

    @question.points.each do |point|
      point.findings.each do |finding|
        finding.versions.each do |v|
          versions << v
        end
      end
    end

    @question.points.each do |point|
      point.associations.each do |association|
        association.versions.each do |v|
          versions << v
        end
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
