namespace 'db:seed' do
  desc "Creates a test user account"
  task user: :environment do
    email = Faker::Internet.safe_email
    credo_user = User.create(username: "testuser#{User.count+1}", email: email, password: 'password')

    puts "Credo User not saved:" unless credo_user.persisted?
    puts "\"#{credo_user.username}\" with email \"#{credo_user.email}\""
  end
end
