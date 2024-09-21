#!/bin/bash

red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
reset=`tput sgr0`

#this code is useing subfinder and sublist3r 

# Initialize variable
domain=""

# Parse command-line options
while getopts "d:" opt; do
    case $opt in
        d)
            domain="$OPTARG"  # Capture the argument for -d
            ;;
        *)
            echo "Usage: $0 -d domain"
            exit 1
            ;;
    esac
done

# Check if the domain variable is set
if [ -z "$domain" ]; then
    echo "${red}No domain provided. Please use -d to specify a domain."
    exit 1
fi



subdomain() { 
    subfinder -d $domain -o subfinder.out  & #> /dev/null 
    sublist3r -d $domain -o sublist3r.out #> /dev/null
}

marge_and_clean(){
    cat subfinder.out sublist3r.out | sort -u > alldomains.txt
    rm *.out
}



main(){
    subdomain
    marge_and_clean
}


main