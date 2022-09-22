export MY_AWS_ACCOUNT=$(aws sts get-caller-identity | jq -r ".Account")

export MY_AWS_REGION=ap-southeast-1

docker build --no-cache --build-arg IMAGE_VERSION="1.0" --build-arg IMAGE_CREATE_DATE="`date -u +"%Y-%m-%dT%H:%M:%SZ"`" -f Dockerfile -t "example:latest" app

docker tag example $MY_AWS_ACCOUNT.dkr.ecr.$MY_AWS_REGION.amazonaws.com/example

aws ecr get-login-password --region $MY_AWS_REGION | docker login --username AWS --password-stdin $MY_AWS_ACCOUNT.dkr.ecr.$MY_AWS_REGION.amazonaws.com

docker push $MY_AWS_ACCOUNT.dkr.ecr.$MY_AWS_REGION.amazonaws.com/example:latest