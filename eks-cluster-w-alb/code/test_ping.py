import requests

lb_url = "http://k8s-example-echoserv-4416498b80-47888175.eu-west-2.elb.amazonaws.com"
host = "echo.devopsbyexample.io"
response = requests.get(lb_url, headers={'Host':host})

print(f'Response status code: {response.status_code}')
print(f'Response content: {response.text}')