
set -e

# ask for confirmation so don't destroy by accident
echo -e "\n--> Destroying Minitwit Infrastructure\n"
echo -e "\n--> This will destroy all resources created by terraform\n"
echo -e "\n--> This will also destroy the database and all data in it\n"
echo -e "\n--> A dump file of the database will be created in the temp folder and saved to the bucket\n"
echo -e "\n--> Are you sure you want to continue? (y/n)\n"
read -r -p "Enter your choice: " choice
if [[ "$choice" != "y" && "$choice" != "Y" ]]; then
    echo -e "\n--> Aborting...\n"
    exit 1
fi


echo -e "\n--> Loading environment variables from secrets file\n"
source secrets

echo -e "\n--> Checking that environment variables are set\n"
# check that all variables are set
[ -z "$TF_VAR_do_token" ] && echo "TF_VAR_do_token is not set" && exit
[ -z "$SPACE_NAME" ] && echo "SPACE_NAME is not set" && exit
[ -z "$STATE_FILE" ] && echo "STATE_FILE is not set" && exit
[ -z "$AWS_ACCESS_KEY_ID" ] && echo "AWS_ACCESS_KEY_ID is not set" && exit
[ -z "$AWS_SECRET_ACCESS_KEY" ] && echo "AWS_SECRET_ACCESS_KEY is not set" && exit


# save database dump, so we can restore it later
# echo -e "\n--> Saving database dump\n"
# ssh \
#     -o 'StrictHostKeyChecking no' \
#     root@$(terraform output -raw minitwit-swarm-leader-ip-address) \
#     -i ssh_key/terraform \
#     'docker exec -i $(docker ps -q --filter "name=minitwit_db") pg_dumpall -c -U minitwit > /tmp/minitwit.sql'
# scp \
#     -o 'StrictHostKeyChecking no' \
#     root@$(terraform output -raw minitwit-swarm-leader-ip-address):/tmp/minitwit.sql \
#     temp/minitwit.sql

# # save the dump to bucket
# echo -e "\n--> Saving database dump to bucket\n"
# aws s3 cp temp/minitwit.sql s3://$SPACE_NAME/minitwit.sql \
#     --region fra-1 \
#     --access-key $AWS_ACCESS_KEY_ID \
#     --secret-key $AWS_SECRET_ACCESS_KEY


# # Prompt user to check if the dump file is saved - we do this because if the dump file is not saved, we will lose all data in the database
# echo -e "\n--> Please check if the dump file is saved to the bucket before proceeding\n"
# echo -e "\n--> This is important, if the dump file is not saved, you will lose all data in the database\n"
# echo -e "\n--> This is the last chance to abort the process\n"
# echo -e "\n--> Is the dump files saved to the bucket? (y/n)\n"
# read -r -p "Enter your choice: " choice
# if [[ "$choice" != "y" && "$choice" != "Y" ]]; then
#     echo -e "\n--> Aborting...\n"
#     exit 1
# fi


echo -e "\n--> Destroying Infrastructure\n"
terraform destroy -auto-approve
