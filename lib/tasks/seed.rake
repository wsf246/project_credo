namespace 'db:seed' do
  desc "Creates a test user account"
  task user: :environment do
    email = Faker::Internet.safe_email
    credo_user = User.create(username: Faker::Internet.user_name, email: email, password: 'password')

    puts "Credo User not saved:" unless credo_user.persisted?
    puts "User created with username \"#{credo_user.username}\" and email \"#{credo_user.email}\""
  end
end
