# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


case Rails.env
when 'development'
    #Lorem
    Lorem ="Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, "

    #random binary
    def bin_rand
        [0,1].sample    
    end  

    #random time
    def rand_time from = 0.0, to=Time.now
      Time.at(from + rand * (to.to_f - from.to_f))
    end

    #random text
    def lorem(length)
        Lorem.split.sample((rand(9)+1)*length).join(' ')
    end 

    #researches seed
    Research.where("id > 10").delete_all
    50.times do |i|
      Research.create(title: "Research ##{i} #{lorem(5)}",
        study_type: ['Cross-sectional','Case-control','Cohort Study','Randomized Control Trial','Case Study','Unknown'].sample,
        journal: lorem(1),
        dropouts: lorem(5),
        funding: lorem(5),
        date_of_publication: rand_time,
        authors: "#{lorem(0.5)}|#{lorem(0.5)}|#{lorem(0.5)}",
        link: "http://www.google.com",
        retracted: bin_rand,
        peer_reviewed: bin_rand,
        replicated: bin_rand,
        single_blinded: bin_rand, 
        double_blinded: bin_rand, 
        randomized: bin_rand,
        controlled_against_placebo: bin_rand, 
        controlled_against_best_alt: bin_rand)
    end

    #findings seed
    Finding.where("id > 10").delete_all
    100.times do |finding|
        Finding.create(finding: lorem(5),
            quote: lorem(5),
            sample_def: lorem(5),
            research_id: Research.where("id > 10").sample.id)
    end    

    #debates seed
    Debate.where("id > 5").delete_all
    10.times do |debate|
        Debate.create(title: lorem(5),
            notes: "#{lorem(5)}|#{lorem(5)}|#{lorem(5)}",
            description: lorem(8),
            verdict: lorem(8))
    end

    #points seed
    Point.where("id > 10").delete_all
    50.times do |point|
        Point.create(for_against: bin_rand,
            point: lorem(5),
            debate_id: Debate.where("id > 5").sample.id)
    end   

    #associations seed
    150.times do |associate|
        Association.create(point_id: Point.where("id > 10").sample.id,
            finding_id: Finding.where("id > 10").sample.id)
    end
end    
