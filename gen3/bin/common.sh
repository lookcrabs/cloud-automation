#
# Helper script for 'gen3 workon' - see ../README.md and ../gen3setup.sh
# that other bin/ scripts can 'source'
#

if [[ -z "$GEN3_PROFILE" || -z "$GEN3_VPC" || -z "$GEN3_WORKDIR" || -z "$GEN3_HOME" ]]; then
  echo "Must define runtime environment: GEN3_PROFILE, GEN3_VPC, GEN3_WORKDIR, GEN3_HOME"
  exit 1
fi
# Terraform state bucket
S3_TERRAFORM="cdis-terraform-state"

#
# This folder holds secrets, so lock it down permissions wise ...
#
umask 0077

if [[ $1 =~ ^-+help$ ]]; then
  help
fi