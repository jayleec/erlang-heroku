# erlang-heroku
### About
A simple chatting server written in Erlang which is deploying to Heroku.  
- Erlang/OTP version :  OTP-18.0-rc1  
- rebar3  
- Cowboy 1.0.0  

### How to Use
Before you deploy to Heroku make sure Heroku buildpack is set.  
- For local test  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$&nbsp;rebar3 compile  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$&nbsp;erl -args_file config/vm.args  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;It will run localhost:8080    
- Deploy to heroku  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$&nbsp;git push heroku master  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;For further information about deploying Heroku is [here](https://devcenter.heroku.com/articles/git)
