require 'spec_helper'

describe Debate do

  before { @debate = Debate.new(title: "Lorem ipsum") }


  subject { @debate }

  it { should respond_to(:title) }
  it { should respond_to(:description) }
  it { should respond_to(:notes) }
  it { should respond_to(:verdict) }

  it { should be_valid }  

end
