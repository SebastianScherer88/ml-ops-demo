import requests
import boto3

alb_client = boto3.client("elbv2", region_name="eu-west-2")
alb_dns = alb_client.describe_load_balancers()['LoadBalancers'][0]['DNSName']
alb_url = f'http://{alb_dns}'
print(f'ALB URL: {alb_url}')

host = "echo.devopsbyexample.io"

response = requests.get(alb_url, headers={'Host':host})

print(f'Response status code: {response.status_code}')
print(f'Response content: {response.text}')