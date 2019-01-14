#!/usr/bin/ruby -w
require 'html-proofer'
	
if ARGV.length == 1
	dir = ARGV[0]
else
	dir = "."
end	

HTMLProofer.check_directory(
	dir,
	{
		:cache =>
		{
			:timeframe => '23h',
			:storage_dir => '/tmp/cache',
		},
		:typhoeus =>
  		{
    		:followlocation => true,
    		:connecttimeout => 30,
    		:timeout => 60,
  		},
  		:hydra =>
  		{
  			:max_concurrency => 50,
  		},
  		:url_swap =>
  		{
      		'https://cli.pignat.org/' => '/',
    	},
	}
).run
