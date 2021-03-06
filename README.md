# dtmcli

A Ruby SDK for distributed transaction manager [dtm](https://github.com/yedf/dtm)

## Usage

```ruby
gem install dtmcli
```

## Example
[Business case description](http://dtm.pub/summary/code.html#%E4%BE%8B%E5%AD%90%E8%AF%B4%E6%98%8E)

```ruby
dtm_url = '127.0.0.1:8080/api/dtm'
biz_url = '127.0.0.1:3000/api/biz'

# Model TCC
res = Dtmcli::Tcc.tcc_global_transaction(dtm_url) do |tcc|
  body = {amount: 30}
  print "calling trans out\n"
  tcc.call_branch(body, biz_url + '/TransOutTry', biz_url + '/TransOutConfirm', biz_url + '/TransOutCancel')
  print "calling trans in\n"
  tcc.call_branch(body, biz_url + '/TransInTry', biz_url + '/TransInConfirm', biz_url + '/TransInCancel')
end

# Model Saga
saga = Dtmcli::Saga.new(dtm_url)
saga.gen_gid

post_data = {
  amount:         30,
  transInResult:  "SUCCESS",
  transOutResult: "SUCCESS",
}
saga.add(biz_url + '/TransOut', biz_url + '/TransOutRevert', post_data)
saga.add(biz_url + '/TransIn', biz_url + '/TransInRevert', post_data)

saga.submit

# Model Transcation Msg
dtm_msg = Dtmcli::Msg.new(dtm_url)
dtm_msg.gen_gid

post_data = {amount: 30}
dtm_msg.add(biz_url + '/TransOut', post_data)
dtm_msg.add(biz_url + '/TransIn', post_data)

dtm_msg.prepare(biz_url + '/TransQuery')

dtm_msg.submit
```