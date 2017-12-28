#!/usr/bin/env ruby

require 'net/http'


def AESdecrypt(ipcrypted)
    _urlcrypter = URI('http://extranet.cryptomathic.com/aescalc/index?key=deadbeefdeadbeefdeadbeefdeadbeef&iv=00000000000000000000000000000000&input=deadbeefdeadbeefdeadbeefdeadbeef'<<ipcrypted<<'&mode=cbc&action=Decrypt&output=')
    http = Net::HTTP.get(_urlcrypter)

    #get outputAES
    outputAES = http.split("name=\"output\" rows=\"10\">")[1].split("<")[0]
    return outputAES.downcase.reverse[0..31].reverse
end

def getBPC()
    _urlaltenen = URI('http://www.altenen.com')
    http = Net::HTTP.new(_urlaltenen.host,_urlaltenen.port)

    _ipcrypted = http.get('/register.php').body.split("c=toNumbers(\"")[1].split("\");document.cookie=")[0]
    return AESdecrypt(_ipcrypted)
end

def getLastTHREAD()
  _urlaltenen = URI('http://altenen.com')
  http = Net::HTTP.new(_urlaltenen.host,_urlaltenen.port)

  response = http.get('/forumdisplay.php?f=41',{'Cookie'=>'BPC='<<getBPC()<<'; bbpassword=9158824a73ec1f0cbd571ab0175ebbbf; bblastactivity=0; bblastvisit=1496414647; bbsessionhash=550275967d810ed0c20b08db8b163d0c; bbuserid=777101; _ddg_=70095;'})
  last_thread = response.body.split("<td class=\"thead\" colspan=\"10\" style=\"height: 15px;\">")[1].split("<a href=\"showthread.php?t=")[1].split("\"")[0]

  #return last thread
  return last_thread
end

def main(thread,bpc,_token,_chatid)
  if _token == "TOKEN!"
      puts "{#}Insert a token please..."
      exit()
  elsif _chatid == "CHATID!"
      puts "{#}Insert chatid please..."
      exit()
  else
      _urlaltenen = URI('http://www.altenen.com')
      http = Net::HTTP.new(_urlaltenen.host,_urlaltenen.port)

      response = http.get('/showthread.php?t='<<thread.to_s,{'Cookie'=>'BPC='<<bpc<<'; bbpassword=9158824a73ec1f0cbd571ab0175ebbbf; bblastactivity=0; bblastvisit=1496414647; bbsessionhash=550275967d810ed0c20b08db8b163d0c; bbuserid=777101; _ddg_=70095;'})
      _header = "New <b>post</b> from altenen.com"
      _credit_card = "\n💳 Post: "<<response.body.split('class="vb_postbit">')[1].split('</div>')[0]
      _author = "\n👤 Author: "<<response.body.split('<span style="font-size: 9pt">')[1].split('<')[0]
      _title = "\n🔆 Title: "<<response.body.split('<title>')[1].split('<')[0]
      _footer = "\n⏰ Powered by @playtonprojects! ♻️"

      Net::HTTP.get(URI('https://api.telegram.org/bot'<<_token<<'/sendMessage?chat_id='<<_chatid<<'&text='<<URI.escape(_header)<<URI.escape(_title)<<"\n"<<URI.escape(_author)<<"\n"<<URI.escape(_credit_card)<<URI.escape(_footer)<<'&parse_mode=HTML'))
  end
end

chatid = "CHATID!"
token = "TOKEN!"
bpc = getBPC()
thread = getLastTHREAD.to_i
puts "{#}Starting bot, wait please..."


while (true) do
    _urlaltenen = URI('http://www.altenen.com')
    http = Net::HTTP.new(_urlaltenen.host,_urlaltenen.port)
    response = http.get('/showthread.php?t='<<thread.to_s,{'Cookie'=>'BPC='<<bpc<<'; bbpassword=9158824a73ec1f0cbd571ab0175ebbbf; bblastactivity=0; bblastvisit=1496414647; bbsessionhash=550275967d810ed0c20b08db8b163d0c; bbuserid=777101; _ddg_=70095;'}).body

    if response.index("No Thread specified.")
      puts thread.to_s<<" thread inesistente."
      next
    elsif response.index(", you do not have permission to access this page.")
      puts thread.to_s<<" thread inesistente."
      thread += 1
      next
    elsif response.index("Invalid Thread specified.")
      puts thread.to_s<<" thread inesistente."
      thread += 1
      next
    elsif response.index("<font color=\"#FFFFFF\">ATN Police</font>")
      thread += 1
      next
    else
      puts "{!}I used this thread: "<<thread.to_s
      main(thread,bpc,token,chatid)

      thread += 1
    end

end
