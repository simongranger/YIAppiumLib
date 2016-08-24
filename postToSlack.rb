#!/usr/bin/ruby
require 'net/http'
require 'json'
require 'uri'

def PostIt(slackTeam, slackChannel, ReportTitle, platform)

    file = File.read('TestResults/TestRun.json')
    data = JSON.parse(file);



    output = "* " + ReportTitle + " for " + platform + " *\n-----------------------" + "\n*Duration:* " + data["summary"]["duration"].to_s + " seconds" + "\n*Tests Run:* " + data["summary"]["example_count"].to_s + "\n*Failures:* " + data["summary"]["failure_count"].to_s

    data["examples"].each do |example|
        if example["status"] == "failed"
            output += "\n:no_entry_sign:  " + example["full_description"]
        end
        if example["status"] == "passed"
            output += "\n:white_check_mark:  " + example["full_description"]
        end
    end

    params = {
        text: output,
        channel: slackChannel,
        username: "Automation Slack Integration",
        icon_emoji: ":zap:",
        mrkdown: true
    }

    uri = URI.parse("https://hooks.slack.com/services/" + slackTeam)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.request_uri)
    request.body = params.to_json
    res = http.request(request)
    puts res.body

end

module Slack
  module IOS
    v1 = ARGV[0]
    v2 = ARGV[1]
    v3 = ARGV[2]
    v4 = ARGV[3]
    PostIt(v1, v2, v3, v4)
  end
end
