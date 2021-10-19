#!/bin/bash

# label each param to pass to dd 

1=$(DD_PRODUCT_NAME)

2=$(DD_ENGAGEMENT_NAME)

3=$(DD_API_KEY)

4=$(DD_USER)

5=$(DD_HOST)

6=$(DD_FILE)

# start dd script

python dojo_ci_cd.py --product_name $1 --engagement_name $2 --api_token $3 --user $4 --host $5 --dir $6 --scanner $6 

#  (add --prod_type) Research and Development
