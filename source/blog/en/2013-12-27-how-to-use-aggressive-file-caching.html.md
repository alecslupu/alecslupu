---

title: How to use aggressive file caching
date: 2013-12-27 00:00 UTC
tags: 
image: /uploads/aggressive.png
category: "PHP" 

---

![How to use aggressive file caching](/uploads/aggressive.png)

Recently I have observed that one of my servers took long time to respond to users. After an investigation I have seen that i had a lot of TIME_WAIT connections, because each request needed to process some output. My application serves some user widgets that are connecting a 3rd Party server, which can cause a lot of delays regarding my output. Given the fact the application did not used secured content (did not required for user to be signed in), I have decided to use aggressive file caching strategy. Basically i have used PHP’s  [ob_start](http://php.net/ob_start) function and its callback in order to write the application’s response on disk.

I had an YII Framework application, so i have modified index.php file to look like this:

    <?php
    function callback($buffer)
    {
      if (empty($buffer)) {
        return $buffer;
      }
      try {
        $file_name = $_SERVER['REQUEST_URI'];
        if (preg_match("/\?/", $file_name)) {
          $file_name = substr($file_name, 0, strpos($file_name, '?'));
        }
        if (substr($file_name, -3, 3) == '.js') {
          file_put_contents(dirname(__FILE__) . $file_name, $buffer);
        } else if (substr($file_name, -9, 9) == 'some custom name') {
          mkdir(dirname(__FILE__) . substr($file_name, 0, -9), 0777, true);
          file_put_contents(dirname(__FILE__) . $file_name, $buffer);
        }
      }catch(Exception $e) { }
      return $buffer;
    }
    
    ob_start("callback");
    
    // change the following paths if necessary
    $yii=dirname(__FILE__).'/some/path/to/yii/framework/yii.php';
    $config=dirname(__FILE__).'/protected/config/main.php';
    
    // remove the following lines when in production mode
    //defined('YII_DEBUG') or define('YII_DEBUG',true);
    // specify how many levels of call stack should be shown in each log message
    //defined('YII_TRACE_LEVEL') or define('YII_TRACE_LEVEL',3);
    
    require_once($yii);
    
    Yii::createWebApplication($config)->run();
    
    ob_end_flush();

Given the fact that my application needed to return JSON objects, i had to added in my NGINX de following lines:

    location ~ ^/js/.*\.js$ {
      #access_log  off;
      access_log    /var/log/nginx/hostname-access-log main;
      add_header Content-Type application/javascript;
      add_header Access-Control-Allow-Origin *;
      if (-f $request_filename) { break; }
      try_files $uri  @apachesite;
    }
    
    location ~ ^/js/.*/some custom name$ {
      #access_log off;
      access_log    /var/log/nginx/hostname-access-log main;
      add_header Content-Type application/json;
      add_header Access-Control-Allow-Origin *;
      if (-f $request_filename) { break; }
      try_files $uri  @apachesite;
    }
    location / {
      # some more config here 
    }
    location @apachesite {
      # some more config here 
    }

The result was a immediate drop of TCP connections on that server, a CPU usage decrease and no difference regarding the functionality. Even more, all what I could see it was a performance improvement. However now I got two other issues: the size of the folder and the cache expiration. Given the fact I wrote the files on disk in one single folder, there was a response time issue (again) because of the big number of files. Those 2 issues, were easier to fix by adding some small script to my crontab:

    #Added cronjob to delete old files
    0 * * * * /some/path/for/cache/expire/script.sh

And the source of: /some/path/for/cache/expire/script.sh

    #!/bin/bash
    
    BASE='/just/another/htdocs/public/folder/matching/my/url'
    #age in minutes
    AGE=60
    
    find $BASE/* -mmin +$AGE -exec rm -r {} \;


**Warning!!** This aggressive file caching strategy cand cause serious response time issues if the number of the files is too big (I let you decide what “big” means to you). By implementing the cron job from above ensures the cache expiration but also the cleanup of the folder by deleting the files that have not been accessed in a while.
