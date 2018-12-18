echo "Process initiated"

mkdir -p genesis
cp ../led_genesis.json ./genesis/led_genesis.json
rm -rf docker-compose.yml
cp ../docker-compose.yml ./docker-compose.yml

curl -L -o solidity-ubuntu-trusty.zip https://github.com/ethereum/solidity/releases/download/v0.4.24/solidity-ubuntu-trusty.zip
unzip solidity-ubuntu-trusty.zip
CWD=$(pwd)

cd $(pwd)/contracts
#ls
chmod +777 *
echo "" >../solcovlogs.txt
for file in *; do 
    if [ -f "$file" ]; then 
        echo "$file" 
        sed -i 's/\^//g' $file
        sed -i 's/0.5.1/0.4.24/g' $file
    fi 
done
cd ..

# node setup
docker volume prune -f || true

docker network create -d bridge --subnet 172.16.239.0/24 --gateway 172.16.239.1 app_net || true
docker-compose down || true


docker stop $(docker ps -a | grep ledgeriumengineering| awk '{print $1}') || true
docker stop $(docker ps -a | grep quay.io| awk '{print $1}') || true
docker stop $(docker ps -a | grep quorumengineering| awk '{print $1}') || true
docker stop $(docker ps -a | grep syneblock| awk '{print $1}') || true


docker rm -f $(docker ps -a | grep ledgeriumengineering| awk '{print $1}') || true
docker rm -f $(docker ps -a | grep quay.io| awk '{print $1}') || true
docker rm -f $(docker ps -a | grep quorumengineering| awk '{print $1}') || true
docker rm -f $(docker ps -a | grep syneblock| awk '{print $1}') || true


docker-compose up -d || true

echo "">truffle.js


npm install || true
npm install --only=dev || true
npm install bignumber.js --save || true
npm install solidity-coverage --save || true


nodename=$(docker ps -a| grep validator-0_1 | awk '{print $1}')
ipaddr=$(docker inspect --format "{{ .NetworkSettings.Networks.app_net.IPAddress }}" $nodename)

echo "npm test"
sed -i 's/localhost/'"$ipaddr"'/g' setup.js

sed -i 's/mocha protocol http/mocha --reporter=xunit/g' package.json
sed -i 's/\.\/test/\.\/test>api-test-reports\.xml/g' package.json

npm test ||true

sed -i '/Mocha Tests/,$!d' api-test-reports.xml

echo "Process completed"