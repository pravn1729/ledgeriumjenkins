docker rm mythril || true
cd $(pwd)/contracts
#ls
chmod +777 *
for file in *; do 
    if [ -f "$file" ]; then 
        echo "$file" 
        sed -i 's/\^//g' $file
        sed -i 's/0.5.1/0.5.0/g' $file
    fi 
done
        
for file in *; do 
    if [ -f "$file" ]; then 
        echo "$file" 
        docker run --name mythril -v /home/ledgerappuser/jenkinshome/workspace/Contract_Audit_Mythril/contracts:/tmp mythril/myth -x /tmp/"$file" || true
        
        docker logs mythril || true
        
        docker rm mythril || true
    fi 
done

echo "Process Done"
