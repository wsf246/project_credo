class DebatesController < ApplicationController
  
  def index
    @debates = Debate.paginate(page: params[:page])
  end
  
  def show
    @debate = Debate.find(params[:id])
  end

  def new
    @debate = Debate.new
  end

  def create
    @debate = Debate.new(debate_params)
    if @debate.save	
      redirect_to @debate
    else
      render 'new'
    end    
  end

  def edit
    @debate= Debate.find(params[:id])
  end

  def update
    @debate= Debate.find(params[:id])
    if @debate.update_attributes(debate_params)
      flash[:success] = "Debate updated"
      redirect_to @debate
    else
      render 'edit'
    end
  end

  def destroy
    Debate.find(params[:id]).destroy
    flash[:success] = "Debate deleted."
    redirect_to debates_url
  end

   private

    def debate_params
      params.require(:debate).permit(:title, :description, :notes,
                                   :verdict)
    end
end