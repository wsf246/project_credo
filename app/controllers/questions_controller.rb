class QuestionsController < ApplicationController
  include ActionView::Helpers::TextHelper
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


    yes_total_cred = @yes_evidence.map{|b| b.findings.map{|a| a.research.score}.sum}.sum
    no_total_cred = @no_evidence.map{|b| b.findings.map{|a| a.research.score}.sum}.sum
    unknown_total_cred = @unknown_evidence.map{|b| b.findings.map{|a| a.research.score}.sum}.sum  
   
    yes_count = @yes_evidence.map{|b| b.findings.map{|a| a.research}.count}.sum
    no_count = @no_evidence.map{|b| b.findings.map{|a| a.research}.count}.sum
    unknown_count = @unknown_evidence.map{|b| b.findings.map{|a| a.research}.count}.sum

    yes_avg_score = yes_total_cred/yes_count if yes_count != 0
    no_avg_score = no_total_cred/no_count if no_count != 0
    unknown_avg_score = unknown_total_cred/unknown_count if unknown_count != 0
   
    yes_max_cred = @yes_evidence.map{|b| b.findings.map{|a| a.research.score}.max.to_i}.max
    no_max_cred = @no_evidence.map{|b| b.findings.map{|a| a.research.score}.max.to_i}.max
    unknown_max_cred = @unknown_evidence.map{|b| b.findings.map{|a| a.research.score}.max.to_i}.max

    yes_min_cred = @yes_evidence.map{|b| b.findings.map{|a| a.research.score}.min || 100}.min
    no_min_cred = @no_evidence.map{|b| b.findings.map{|a| a.research.score}.min || 100}.min
    unknown_min_cred = @unknown_evidence.map{|b| b.findings.map{|a| a.research.score}.min || 100}.min

    yes_max_paper = "Research #39 arcu. varius ligula dis montes, In eget quis nisi. justo, quam sodales, viverra commodo Etiam rhoncus massa neque tempus. Quisque libero consectetuer magna. tincidunt. parturient vitae, nisi. dapibus. quam et" 

    min_max = []
    if yes_total_cred != 0 then min_max << [yes_min_cred,yes_max_cred] end 
    if no_total_cred != 0 then min_max << [no_min_cred,no_max_cred] end   
    if unknown_total_cred != 0 then min_max << [unknown_min_cred,unknown_max_cred] end 

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
      
      @yes_score_range =
        LazyHighCharts::HighChart.new('range') do |f|
          f.chart({:defaultSeriesType=>"columnrange", inverted: true, height: 130})
          f.colors( ['#428bca', 'black', '#998100', '#24CBE5', '#64E572', '#FF9655', '#FFF263', '#6AF9C4'])
          f.title(text:"Cred Min, Avg, Max", style:{margin: "5px", font: 'bold 12px Verdana, sans-serif', fontSize:"12px"})
          f.legend({enabled: false})          
          f.yAxis({min: 0, max: 48, tickInterval: 10, title: ''})

          f.xAxis({categories: ['Yes','No','Unknown']})
          series0 =
            {
              type: 'scatter',
              name: 'Lowest Cred',
              color:'#428bca',  
              data: [[0,yes_min_cred],[1,no_min_cred],[2,unknown_avg_score]],
              marker: {
                symbol: "circle",
                radius: 6
              }
            }
          series1 =  
            {
              type: 'scatter',
              name: 'Highest Cred',
              color:'black',  
              data: [[0,yes_max_cred],[1,no_max_cred],[2,unknown_max_cred]],
              marker: {
                symbol: "circle",
                radius: 6
              }
            }
          series2 =  
            {
              type: 'scatter',
              name: 'Average Cred',
              color:'#998100',
              tooltip: {pointFormat: truncate(yes_max_paper, length:15)+'Cred: {point.y}', valueDecimals: 1},  
              data: [[0,yes_avg_score],[1,no_avg_score],[2,unknown_avg_score]],
              marker: {
                symbol: "circle",
                radius: 6
              }
            }
          
          if yes_total_cred != 0 then f.series(series0) end
          if no_total_cred != 0 then f.series(series1) end
          if unknown_total_cred != 0 then f.series(series2) end


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
