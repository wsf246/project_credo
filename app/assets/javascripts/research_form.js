var ready;
var defCrossSectional = "<p>A cross-sectional study is a type of observational study that involves the analysis of data collected from a population, or a representative subset, at one specific point in time</p>"
var defCaseControl = "<p>A case-control study is a type of observational study in which two existing groups differing in outcome are identified and compared on the basis of some supposed causal attribute</p>"
var defCohortStudy = "<p>A cohort study is a type of observational study done prospectively or retrospectively where groups of people who share common characteristics or experiences within a defined period but differ in an attribute or attributes are examined for risk factors</p>"
var defRCT = "<p>A randomized control trial is a type of intervention study that randomly assigns participants into an experimental group or a control group and measures outcomes of the intervention.</p>"
var defCaseStudy = "<p>A case study is a study in which detailed consideration is given to the development of a particular person, group, or situation over a period of time</p>"
var defMeta = "<p>A meta-analysis is a type of statistical analysis of a large collection of analysis results from individual studies for the purpose of integrating the findings</p>"
var defReview = "<p>A review of literature is an evaluative report of information found in the literature related to a selected area of study with no statistical evaluation of the findings</p>"
var defClinicalTrial = "<p>A clinical trial is a type of intervention study that prospectively assigns participants or groups to one or more interventions to evaluate the effects on outcomes with no randomization performed on the participants.</p>"


ready = function() {
  $('#research_study_type').on('click', "option[value='Cross Sectional']", function(){
    $(this).closest("div").children("p").remove();
    $(this).closest("div").append(defCrossSectional);
    $('#research_single_blinded').prop('disabled', true).prop('checked', false);
    $('#research_double_blinded').prop('disabled', true).prop('checked', false);
    $('#research_randomized').prop('disabled', true).prop('checked', false);
    $('#research_controlled_against_placebo').prop('disabled', true).prop('checked', false);
    $('#research_controlled_against_best_alt').prop('disabled', true).prop('checked', false);
  });
  $('#research_study_type').on('click', "option[value='Case Control']", function(){
    $(this).closest("div").children("p").remove();
    $(this).closest("div").append(defCaseControl);
    $('#research_single_blinded').prop('disabled', true).prop('checked', false);
    $('#research_double_blinded').prop('disabled', true).prop('checked', false);
    $('#research_randomized').prop('disabled', true).prop('checked', false);
    $('#research_controlled_against_placebo').prop('disabled', false);
    $('#research_controlled_against_best_alt').prop('disabled', false);
  });
  $('#research_study_type').on('click', "option[value='Cohort Study']", function(){
    $(this).closest("div").children("p").remove();
    $(this).closest("div").append(defCohortStudy);
    $('#research_single_blinded').prop('disabled', true).prop('checked', false);
    $('#research_double_blinded').prop('disabled', true).prop('checked', false);
    $('#research_randomized').prop('disabled', true).prop('checked', false);
    $('#research_controlled_against_placebo').prop('disabled', false);
    $('#research_controlled_against_best_alt').prop('disabled', false);
  });
    $('#research_study_type').on('click', "option[value='Randomized Control Trial']", function(){
    $(this).closest("div").children("p").remove();
    $(this).closest("div").append(defRCT);
    $('#research_single_blinded').prop('disabled', false);
    $('#research_double_blinded').prop('disabled', false);
    $('#research_randomized').prop('disabled', true).prop('checked', true);
    $('#research_controlled_against_placebo').prop('disabled', false);
    $('#research_controlled_against_best_alt').prop('disabled', false);
  });
    $('#research_study_type').on('click', "option[value='Case Study']", function(){
    $(this).closest("div").children("p").remove();
    $(this).closest("div").append(defCaseStudy);
    $('#research_single_blinded').prop('disabled', true).prop('checked', false);
    $('#research_double_blinded').prop('disabled', true).prop('checked', false);
    $('#research_randomized').prop('disabled', true).prop('checked', false);
    $('#research_controlled_against_placebo').prop('disabled', true).prop('checked', false);
    $('#research_controlled_against_best_alt').prop('disabled', true).prop('checked', false);
  });
    $('#research_study_type').on('click', "option[value='Meta-Analysis']", function(){
    $(this).closest("div").children("p").remove();
    $(this).closest("div").append(defMeta);
    $('#research_single_blinded').prop('disabled', false);
    $('#research_double_blinded').prop('disabled', false);
    $('#research_randomized').prop('disabled', false);
    $('#research_controlled_against_placebo').prop('disabled', false);
    $('#research_controlled_against_best_alt').prop('disabled', false);
  });
    $('#research_study_type').on('click', "option[value='Review of Literature']", function(){
    $(this).closest("div").children("p").remove();
    $(this).closest("div").append(defReview);
    $('#research_single_blinded').prop('disabled', false);
    $('#research_double_blinded').prop('disabled', false);
    $('#research_randomized').prop('disabled', false);
    $('#research_controlled_against_placebo').prop('disabled', false);
    $('#research_controlled_against_best_alt').prop('disabled', false);
  });
    $('#research_study_type').on('click', "option[value='Clinical Trial']", function(){
    $(this).closest("div").children("p").remove();
    $(this).closest("div").append(defReview);
    $('#research_single_blinded').prop('disabled', false);
    $('#research_double_blinded').prop('disabled', false);
    $('#research_randomized').prop('disabled', false);
    $('#research_controlled_against_placebo').prop('disabled', false);
    $('#research_controlled_against_best_alt').prop('disabled', false);
  });                     
};

$(document).ready(ready);
$(document).on('page:load', ready);

