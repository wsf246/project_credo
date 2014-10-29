class AssociationsController < ApplicationController

  before_action :authenticate_user!, 
                only: [:destroy, :create]  

  def create
    point = Point.find(params[:association][:point_id])

    passed_findings = params[:association][:finding_id].reject(&:blank?).map{|e| Finding.find(e)}
    existing_findings = point.findings.where(research: Research.find(params[:association][:research_id]))
    unassociate_findings = existing_findings - passed_findings
    new_passed_findings = passed_findings - existing_findings


    new_passed_findings.each do |finding|   
      point.associate!(finding)
    end

    unassociate_findings.each do |finding|
      point.associations.where(finding_id: finding.id).each do |association|
        association.destroy
      end  
    end  
    redirect_to question_path(point.question) 
  end

  def destroy
    @finding = Finding.find(params[:association][:finding_id])
    @point = Point.find(params[:association][:point_id])   
    @point.unassociate!(@finding)
    respond_to do |format|
      format.html { redirect_to @findings }
      format.js
    end 
  end
end