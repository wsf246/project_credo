class QuestionsController < ApplicationController
  include ActionView::Helpers::TextHelper
  before_action :authenticate_user!, 
                only: [:edit, :update, :destroy, :new, :create, :upvote, :downvote, :add_verdict, :edit_verdict, :remove_finding]

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
   


    @pie = 
      LazyHighCharts::HighChart.new('pie') do |f|
        f.chart({:defaultSeriesType=>"pie" , :margin=> [5, 0, 0, 0], height: 130} )
        f.colors( ['#428bca', 'black', '#998100', '#24CBE5', '#64E572', '#FF9655', '#FFF263', '#6AF9C4'])
        series = {
          :type=> 'pie',
          :name=> 'Cred',
          :data=> [
            [if yes_total_cred == 0 then '' else 'Yes' end, yes_total_cred],            
            [if no_total_cred == 0 then '' else 'No' end, no_total_cred],
            [if unknown_total_cred == 0 then '' else 'Unk.' end, unknown_total_cred],
          ]
        }
        f.series(series)
        f.legend(:layout=> 'vertical',:style=> {:left=> 'auto', :bottom=> 'auto',:right=> '50px',:top=> '100px'})
        f.plot_options(:pie=>{
          :allowPointSelect=>true,
          cursor:"pointer",
          size: "100%",
          :dataLabels=>{
            :enabled=>true,
            :distance=> -25,
            :color=>"white",
            :style=>{
              :font=>'bold 40px Verdana, sans-serif',
              fontSize: "14px"
            }
          }
        })
      end

    @yes_cred =[]
      @yes_evidence.each do |point|
        point.findings.each do |finding|
          @yes_cred << {
            x:0,y:finding.research.score,
            title:truncate(finding.research.title,length:25),
            authors:truncate(finding.research.authors,length:25)
          }
        end
      end

    @no_cred = []
    @no_evidence.each do |point|
      point.findings.each do |finding|
        @no_cred << {
            x:1,y:finding.research.score,
            title:truncate(finding.research.title,length:25),
            authors:truncate(finding.research.authors,length:25)
          }
      end
    end

    @unknown_cred = []
    @unknown_evidence.each do |point|
      point.findings.each do |finding|
        @unknown_cred << {
            x:2,y:finding.research.score,
            title:truncate(finding.research.title,length:25),
            authors:truncate(finding.research.authors,length:25)
          }
      end
    end         
    yes_count = @yes_evidence.map{|b| b.findings.map{|a| a.research}.count}.sum
    no_count = @no_evidence.map{|b| b.findings.map{|a| a.research}.count}.sum
    unknown_count = @unknown_evidence.map{|b| b.findings.map{|a| a.research}.count}.sum

    yes_avg_cred = yes_total_cred/yes_count if yes_count != 0
    no_avg_cred = no_total_cred/no_count if no_count != 0
    unknown_avg_cred = unknown_total_cred/unknown_count if unknown_count != 0

    averages = []
    averages << [0,yes_avg_cred] if yes_count !=0
    averages << [1,no_avg_cred] if no_count !=0
    averages << [2,unknown_avg_cred] if unknown_count !=0

    @cred_range =
      LazyHighCharts::HighChart.new('cred_range') do |f|
        f.chart({:defaultSeriesType=>"columnrange", inverted: true, height: 130})
        f.title(text:"Cred Scores", style:{margin: "5px", font: 'bold 12px Verdana, sans-serif', fontSize:"12px"})
        f.legend({enabled: false})          
        f.yAxis({min: 0, max: 48, tickInterval: 10, title: ''})
        f.xAxis({categories: ['Yes','No','Unknown']})

        f.plot_options(column: {
          colorByPoint: true
        })   
        series0 =
          {
            type: 'scatter',
            name: 'Yes',
            color: '#428bca',              
            tooltip: {pointFormat:"{point.title}<br />{point.authors}<br />Cred: {point.y}", valueDecimals: 1}, 
            data: @yes_cred, 
            marker: {
              symbol: "circle",
              radius: 6
            }
          }
        series1 =  
          {
            type: 'scatter',
            name: 'No',
            color:'black',
            tooltip: {pointFormat:"{point.title}<br />{point.authors}<br />Cred: {point.y}", valueDecimals: 1},               
            data: @no_cred,
            marker: {
              symbol: "circle",
              radius: 6
            }
          }
        series2 =  
          {
            type: 'scatter',
            name: 'Unknown',
            color:'#998100',
            tooltip: {pointFormat:"{point.title}<br />{point.authors}<br />Cred: {point.y}", valueDecimals: 1}, 
            data: @unknown_cred,
            marker: {
              symbol: "circle",
              radius: 6
            }
          }
        avg_series =  
          {
            type: 'scatter',
            name: 'Average',
            color:'#FF0000',
            tooltip: {pointFormat:"Cred: {point.y}", valueDecimals: 1}, 
            data: averages,
            marker: {
              symbol: "square",
              radius: 6
            }
          }            
        
        if yes_total_cred != 0 then f.series(series0) end
        if no_total_cred != 0 then f.series(series1) end
        if unknown_total_cred != 0 then f.series(series2) end
        f.series(avg_series) 
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
          title: {text: 'Publication Date'}
          })          
        f.yAxis({
          min: 0, 
          tickInterval: 50, 
          title: {text: '- Credibility +'},
          labels: {
            enabled: false
          }
        })  


        f.plot_options(column: {
          colorByPoint: true
        })

        yes_series =  
          {
            type: 'scatter',
            name: 'Yes',
            color: 'rgba(66, 139, 202, .65)', 
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
            color: 'rgba(0, 0, 0, .65)', 
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
