# horangi-cf
Create a simple website that just shows a list of ip addresses that has accessed that website.
For example: If I'm the first visitor to the website, I should just see a blank page on my first visit. The second time I visit the website, I should see my ip address listed on the webpage.

Some notes:
- This should be done using aws cloudformation, with aws lambda, api gateway and a datastore of your choice (s3/rds/dynamodb)
- There is no need to use cloudfront for this, you can just use the api gateway endpoint as the link to the website: https://******.execute-api.ap-southeast-1.amazonaws.com/dev
- place the cloudformation template in a github repository
- We are not looking for a scalable or a fault tolerant solution. But we will ask questions on how you will scale and monitor it in a live system.
