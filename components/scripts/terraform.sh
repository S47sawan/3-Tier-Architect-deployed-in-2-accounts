#!/bin/bash
# Purpose: Terraform wrappper for the new code structure
#
# Author: Jeff Owens
# Version: 1.0
# Last update: 24 Dec 2019
# Last updated by: Philip Hope

# set -eu
set -o errexit
set -o pipefail
set -o nounset
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Script Functions
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------

function consoleout_error() {
  echo "tf.sh: ERROR: ${1}"
  #exit 1
}

function print_line {
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
}

function output_command() {
  echo; print_line
  echo $1
  print_line; echo ""
  echo $2 | awk '{ gsub(/ +/, " \\ \n" ); print; }' # Make command more readable for user
  echo; print_line; echo
}
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------
# tfenv
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------
# export AWS_DEFAULT_REGION="eu-west-2"
# tfenv use 1.1.5
tf_version="1.1.5"
region="eu-west-2" 
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------
# User passed parameters
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------

environment=${1}
action=${2}
if [[ "${action}" == "import" ]]; then
  tf_resource=${3} # Used for TF import
  tf_resource_id=${4} # Used for TF import
fi

if [[ "${action}" == "remove" ]]; then
  tf_resource_address=${3} # Used for TF state remove
fi

apply_var=""
if [[ "${action}" == "apply" ]] && [[ $# -eq 3  ]]; then
  apply_var=${3} # Used for passing parameters to the apply command
fi

# ------------------------------------------------------------------------------------------------------------------------------------------------------------------
# List of acceptable user passed parameters.  If not matched, exit script
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------

envList=(
  account_a
  account_b
)

actionList=(
  lint
  refresh
  init
  plan
  apply
  destroy
  import
  list
  remove
  0.12checklist
  0.12upgrade
)

# ------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Check if user passed params are expected
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------

if [[ " ${envList[@]} " =~ " ${environment} " ]] && [[ " ${actionList[@]} " =~ " ${action} " ]]; then

  # tfenv used to ensure that the correct version of terraform is ran
  echo -e "\nRequired Terraform version: $tf_version...\n"
  tfenv install $tf_version
  tfenv use $tf_version

  echo -e "\nRunning Terraform...\n"
else
  echo "ERROR: usage is ./tf-aws.sh <environment {${envList[@]}}> <action {${actionList[@]}}>"
  exit 1
fi

# # ------------------------------------------------------------------------------------------------------------------------------------------------------------------
# # Checks current sts caller-id
# # ------------------------------------------------------------------------------------------------------------------------------------------------------------------

# currentStsAccount=`aws sts get-caller-identity --output text --query 'Account'`
# currentStsRole=`aws sts get-caller-identity --output text --query 'Arn' | awk -F "\/" '{print $2}'`

# awsAcc=`cat ~/.aws/sts_assume_role/mobilise/sts-config.json | jq -r --arg environment ${environment} ".Accounts.\"mobilise-$environment\""` # Obtain related account number (stored in json)
# if [[ "$currentStsAccount" != "$awsAcc" ]] || [[ "$currentStsRole" != "Global-Admin" ]]; then
#     source ~/.aws/sts_assume_role/mobilise/awstoken mobilise-${environment} Global-Admin
# fi

# ------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Paths of terraform:
#   components: the terraform code itself (resource creations, data lookups)
#          etc: the variables used by the TF code.
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------
# scripts_dir=$( cd $( dirname "${BASH_SOURCE[0]}" ) && pwd )
# components_dir=$(dirname "${scripts_dir}")
# parent_dir=$(dirname "${components_dir}")
# parent_dir_name=$(basename "${parent_dir}")

# tf_vars="${parent_dir}/vars/${environment}/terraform"
# tf_dir="$components_dir/terraform"

scripts_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
components_dir=$(dirname "${scripts_dir}")
base_dir=$(dirname "${components_dir}")
base_dir_name=$(basename "${base_dir}")
parent_dir=$(dirname "${components_dir}")
tf_vars="${parent_dir}/vars/${environment}/terraform"
tf_dir=${components_dir}/terraform

# ------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Check if this is the root account. This is Arvato specific at the moment so needs to be improved
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------

# export AWS_ACCOUNT=898028383603
# export AWS_ACCOUNT=679749876012

# ------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Obtain Client Abbreviation from tfvars file
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------

client_abbr=$(cat "$tf_vars/environment.tfvars" | grep "client_abbr" | awk -F"=" '{print $2}' | awk -F'"' '{print $2}')
# if [ -z $TF_VAR_meta_repo_tag ] && [[ $action == "apply" ]] && [[ $environment != "dev" ]] && [[ $environment != "test" ]]; then
#   echo "To apply to $environment you need to create a pull request for your branch, merge to master and tag the merge commit with a version number."
#   exit 1
# fi

AWS_ACCOUNT=$(cat < "${tf_vars}/environment.tfvars" | grep "account_no" | awk -F"=" '{print $2}' | awk -F'"' '{print $2}')
region="eu-west-2"
s3_backend="${client_abbr}-terraform-infra-backend-state-${region}-${AWS_ACCOUNT}"
s3_backend_key="${base_dir_name}/${environment}.tfstate"

export TF_DATA_DIR="${tf_vars}/.terraform"
export TF_VAR_region_name=$region
export TF_VAR_environment=$environment
export TF_VAR_domain="NAME_OF_DOMAIN"
export TF_VAR_meta_deploy_time

# If code is deployed via drone
if [ -n "${DRONE_BRANCH:-}" ]; then
  export TF_VAR_meta_deployed_by="drone"
  export TF_VAR_meta_repo_name="$DRONE_REPO_NAME"
  export TF_VAR_meta_repo_branch="$DRONE_BRANCH"
  export TF_VAR_meta_repo_tag="${DRONE_TAG:-}"
  export TF_VAR_meta_last_commit_author="$DRONE_COMMIT_AUTHOR"
  export TF_VAR_meta_build_no="$DRONE_BUILD_NUMBER"
# If code is not managed within a git repository (local only)
elif [ -z $(git config --get remote.origin.url) 2>/dev/null ]; then
  export TF_VAR_meta_deployed_by="${USER:-unset}"
  export TF_VAR_meta_repo_name="N/A"
  export TF_VAR_meta_repo_branch="N/A"
  export TF_VAR_meta_repo_tag="N/A"
  export TF_VAR_meta_last_commit_author="N/A"
  export TF_VAR_meta_build_no="N/A"
# If code is managed within a git repository
else
  export TF_VAR_meta_deployed_by=$(git config --global user.name)
  export TF_VAR_meta_repo_name=$(echo "$(basename $(dirname -- $(git config --get remote.origin.url)))/$(basename -s .git `git config --get remote.origin.url`)")
  export TF_VAR_meta_repo_branch="$(git rev-parse --abbrev-ref HEAD)"
  export TF_VAR_meta_repo_tag="$(git tag -l | head)"
  export TF_VAR_meta_last_commit_author="$(git log -1 --pretty=format:'%an')"
  export TF_VAR_meta_build_no="N/A"
fi

echo; print_line
echo "WORKING ON:"
print_line
echo; echo "  tf vars:  ${tf_vars}"
echo "terraform:  ${tf_dir}"
echo; print_line; echo

# ------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Create S3 bucket backend via ansible if it does not exist (terraform has been configured to use AWS S3 backend)
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------

s3_backend="${client_abbr}-terraform-backend-state-$AWS_ACCOUNT"

 if ! aws s3api head-bucket --bucket "${s3_backend}" 2>/dev/null; then
  output_command "CREATING S3 BACKEND: ${s3_backend}" "${scripts_dir}/ansible_create_tf_s3_backend.sh"
  ${scripts_dir}/ansible_create_tf_s3_backend.sh ${region} ${s3_backend} ${TF_VAR_meta_deployed_by} ${TF_VAR_meta_repo_name}
fi

# if ! aws s3api head-bucket --bucket $s3_backend 2>/dev/null; then
#   output_command "CREATING S3 BACKEND: $s3_backend" "$scripts_dir/ansible_create_tf_s3_backend.sh $client_abbr"
#   "$scripts_dir/ansible_create_tf_s3_backend.sh" $client_abbr $TF_VAR_meta_deployed_by $TF_VAR_meta_repo_name
# fi

# ------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Obtain all tfvars files within the vars components directory
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------

tfvar_files=''
tflvar_files=''

for tfvar_file in "${tf_vars}"/*.tfvars; do
  tfvar_files="$tfvar_files -var-file=\"$tfvar_file\"";
  tflvar_files="$tflvar_files --var-file=\"$tfvar_file\"";
done

# join looped files with exitsing var file params string

var_file_params="${var_file_params:-} $tfvar_files"
var_lint_file_params="${var_lint_file_params:-} $tflvar_files"

# ------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Terraform commands
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------
# add in -upgrade if you wish to upgrade to the latest version of the provider plugins
tf_init="terraform -chdir=\"${tf_dir}/\" init
 -input=true \
  -backend=true \
  -backend-config=\"bucket=${s3_backend}\" \
  -backend-config=\"key=${s3_backend_key}\" \
  -backend-config=\"region=${region}\" \
   "

tf_validate="terraform  -chdir=\"${tf_dir}/\" validate"
tf_plan="terraform -chdir=\"${tf_dir}/\" plan $var_file_params -input=false | tee ./components/scripts/temp.parseplan"
# tf_plan="terraform plan $var_file_params -input=false -out ${environment}.plan "${tf_dir}""
tf_apply_var="terraform -chdir=\"${tf_dir}/\" apply $var_file_params -var '${apply_var}' -input=false"
tf_apply="terraform -chdir=\"${tf_dir}/\" apply $var_file_params -input=false"
tf_destroy="terraform -chdir=\"${tf_dir}/\" destroy $var_file_params -input=false"
tf_import="terraform -chdir=\"${tf_dir}/\" import '${tf_resource:-}' ${tf_resource_id:-}"
tf_state_list="terraform state list"
tf_state_rm="terraform state rm '${tf_resource_address:-}'"

# TF Linting enablement
tfl_init="tflint --init"
tfl_lint="tflint $var_lint_file_params "${tf_dir}""

# ------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Terraform Init
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------

# We init freshly if the action is "plan"
# We want to keep the .terraform/terraform.tfstate if an apply, destroy etc is required

if [[ "${action}" == "plan" ]]; then
  rm -rf "$TF_DATA_DIR/terraform.tfstate" # Remove .terraform temp state file if a new plan is required
fi

output_command "INITIATING BACKEND:" "$tf_init"

eval $tf_init # execute command

# ------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Terraform Plan
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------

if [[ "${action}" == "plan" ]]; then
  output_command "TF VALIDATE:" "$tf_validate"
  eval $tf_validate
  output_command "TF PLAN:" "$tf_plan"
  eval $tf_plan
fi

# ------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Terraform Apply
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------

if [[ "${action}" == "apply" ]] && [[ $# -eq 3  ]]; then
  output_command "TF APPLY:" "$tf_apply_var"
  eval $tf_apply_var
fi

if [[ "${action}" == "apply" ]] && [[ $# -eq 2  ]]; then
  output_command "TF APPLY:" "$tf_apply"
  eval $tf_apply
fi

# ------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Terraform Destroy
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------

if [[ "${action}" == "destroy" ]]; then
  output_command "TF DESTROY:" "$tf_destroy"
  eval $tf_destroy
fi

# ------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Terraform Import
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------

if [[ "${action}" == "import" ]]; then
  output_command "TF IMPORT:" "$tf_import"
  eval $tf_import
fi

# ------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Terraform State list
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------

if [[ "${action}" == "list" ]]; then
  # terraform state list command currently requires you to be in the terraform code directory
  cd "${tf_dir}"
  output_command "TF STATE:" "$tf_state_list"
  eval $tf_state_list
  cd "${parent_dir}"
fi

# ------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Terraform State rm
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------

if [[ "${action}" == "remove" ]]; then
  # terraform state rm command currently requires you to be in the terraform code directory
  cd "${tf_dir}"
  output_command "TF STATE:" "$tf_state_rm"
  eval $tf_state_rm
  cd "${parent_dir}"
fi

# ------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Terraform 0.12checklist
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------

if [[ "${action}" == "0.12checklist" ]]; then
  output_command "TF 0.12CHECKLST:" "$tf_012checklist"
  eval $tf_012checklist
fi

# ------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Terraform 0.12upgrade
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------

if [[ "${action}" == "0.12upgrade" ]]; then
  output_command "TF 0.12UPGRADE:" "$tf_012upgrade"
  eval $tf_012upgrade
fi

# ------------------------------------------------------------------------------------------------------------------------------------------------------------------
# TFLint
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------

if [[ "${action}" == "lint" ]]; then
  output_command "TFLINT INIT:" "$tfl_init"
  eval $tfl_init

  output_command "TFLINT LINT:" "$tfl_lint"
  eval $tfl_lint
fi

echo -e "========================================================================"
echo "AWS Account:         $AWS_ACCOUNT"
echo "Environment:         $environment"
echo "Action:              $action"
echo "Last commit Author:  $(git log -1 --pretty=format:'%an')"
echo -e "\n========================================================================"



