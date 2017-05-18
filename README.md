### Starting the application

To install the required gems and dependencies: 
```
bundle install
```

Then, you have to create a database. You can do so with the following command:
```
RAILS_ENV=production rails db:setup
```

Rails' `production` environment requires the existence of a secret token. It's often saved as an environment (as in *the OS environment*) variable. You have to use the following command:
```
RAILS_ENV=production rake secret
```
to get the code, copy it and set it as one of the OS environment variables with:
```
export SECRET_KEY_BASE=<generated_code>
```
Now, you should be able to run the application with:
```
rails s -e="production"
```

The application was written in Rails 5.1.1 on Ruby 2.3.3. It uses `rspec` as its testing suite. Should you want to run tests, you can do so with the following command: `bundle exec rspec`.