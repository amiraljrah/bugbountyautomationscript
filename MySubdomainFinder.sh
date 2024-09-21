#!/bin/bash

red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
reset=`tput sgr0`

#this code is useing subfinder and sublist3r 

# Initialize variable
domain=""
skip_subdomains=false


todate=$(date +"%Y-%m-%d")

# Parse command-line options
while getopts "d:i" opt; do
    case $opt in
        d)
            domain="$OPTARG"  # Capture the argument for -d
            ;;
        i)
             skip_subdomains=true  # Capture the argument for -i
            ;;
        *)
            exit 1
            ;;
    esac
done

# Check if the domain variable is set
if [ -z "$domain" ]; then
    echo "${red}No domain provided. Please use -d to specify a domain. add -i to skip subdomains enum"
    exit 1
fi



subdomain() { 

    if [ "$skip_subdomains" = false ]; then
    echo "${yellow}start subdomains enum"
    subfinder -d $domain -o subfinder.out  & #> /dev/null 
    sublist3r -d $domain -o sublist3r.out #> /dev/null
    marge_and_clean
    wait  # Wait for background processes to complete

fi

   
}

marge_and_clean(){
    cat subfinder.out sublist3r.out | sort -u > alldomains.txt
    rm *.out
}


mCorscanner(){
    echo "${yellow}start corscanner enum in the background"
    if [ "$skip_subdomains" = false ]; then
     corscanner -i alldomains.txt  -o corscanner.out &
    else
     corscanner -u $domain -o corscanner.out &
    fi
    
}

mWaybackurls(){
     echo "${yellow}start Waybackurls in the background"
     if [ "$skip_subdomains" = false ]; then
        cat alldomains.txt | waybackurls >  waybackurls.out &
     else 
        echo $domain | waybackurls >  waybackurls.out &
     fi

     mkdir -p ./urls

# Define an array of file extensions
extensions=("php" "js" "jsp" "asp" "aspx")

# Loop through each extension
for ext in "${extensions[@]}"; do
    # Use grep to filter and create the output file
    grep "\.$ext" waybackurls.out |  sort -u > "./urls/$ext.out"
    
    # Remove the file if it's empty
    if [ ! -s "./urls/$ext.out" ]; then
        rm "./urls/$ext.out"
    fi
done
     
}


mNmap(){
     if [ "$skip_subdomains" = false ]; then
    
     nmap -sV -T3 -Pn -p3868,3366,8443,8080,9443,9091,3000,8000,5900,8081,6000,10000,8181,3306,5000,4000,8888,5432,15672,9999,161,4044,7077,4040,9000,8089,443,7447,7080,8880,8983,5673,7443,19000,19080 -iL alldomains.txt |  grep -E 'open|filtered|closed' > nmap.out
     
     else

     nmap -sV -T3 -Pn -p3868,3366,8443,8080,9443,9091,3000,8000,5900,8081,6000,10000,8181,3306,5000,4000,8888,5432,15672,9999,161,4044,7077,4040,9000,8089,443,7447,7080,8880,8983,5673,7443,19000,19080  $domain  |  grep -E 'open|filtered|closed' > nmap.out

     fi
}

mParamspider(){
 if [ "$skip_subdomains" = false ]; then
    paramspider -l alldomains.txt
  else 
    paramspider -d $domain
fi
}


main(){

    subdomain
    mWaybackurls
    mNmap
    mCorscanner
    mParamspider
    echo "${yellow}waitig --------------------------------"
    wait
}


main