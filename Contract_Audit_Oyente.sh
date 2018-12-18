docker rm -f oyente || true
cd $(pwd)/contracts
#ls
chmod +777 *
echo "" >../oyentelogs.txt

for file in *; do 
    if [ -f "$file" ]; then 
        echo "$file" 
        sed -i 's/\^//g' $file
        sed -i 's/0.5.1/0.4.24/g' $file
    fi 
done

docker run -d  -it --name oyente -v /home/ledgerappuser/jenkinshome/workspace/Contract_Audit_Oyente/contracts:/tmp qspprotocol/oyente-0.4.24


for file in *; do 
    if [ -f "$file" ]; then 
        echo "$file" 

        docker exec -t oyente bash -c 'cd /oyente/oyente && python oyente.py -s /tmp/'$file >> ../oyentelogs.txt 2>&1 || true

    fi 
done

docker rm -f oyente || true
docker rm oyente || true
        
#echo "" > $(docker inspect --format='{{.LogPath}}' oyente)

echo "oyente reports are generated"