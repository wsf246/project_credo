class AssociationsController < ApplicationController

  def create
    @finding = Finding.find(params[:association][:finding_id])
    @point = Point.find(params[:association][:point_id])
    @point.associate!(@finding)
    respond_to do |format|
      format.html { redirect_to @findings }
      format.js {render "create", locals: {point: @point, finding: @finding}}
    end
  end

  def destroy
    @finding = Finding.find(params[:association][:finding_id])
    @point = Point.find(params[:association][:point_id])   
    @point.unassociate!(@finding)
    respond_to do |format|
      format.html { redirect_to @findings }
      format.js {render "destroy", locals: {point: @point, finding: @finding}}
    end
  end
end