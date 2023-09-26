#!/bin/bash -e

cwd=`pwd`
report_file='rbac-audit-report.txt'
log_file='rbac-audit-report.log'

function print_help() {
  echo "Usage: "
  echo "1. Make sure you have a permission to describe the IAM resources on id (gateway) account"
  echo "2. Make sure python virtualenv is installed on your workspace"
  echo "3. bash $0"
  echo "4. See a generated report: $report_file"
}

function install_awscli() {
  virtualenv -q -p python3 $cwd/.awscli
  source $cwd/.awscli/bin/activate > /dev/null 2>&1
  pip3 install -q 'awscli>=1.16.0,<1.17.0'
}

function print_title() {
  timestamp=$(date +'%Y-%m-%d')
  echo '########################################################' >&3
  echo '# << RBAC User Report >>' >&3
  echo "# Date: $timestamp" >&3
  echo '########################################################' >&3
  echo '' >&3
}

function print_group() {
	groups=$(aws iam list-groups --query 'Groups[*].[GroupName]' --region us-east-1 --output text)

	for g in $groups;
	do
	  echo '========================================================' >&3
		echo '<< Group Name >>' >&3
		echo $(aws iam get-group  --group-name $g --query 'Group.GroupName' --region us-east-1 --output text) >&3

		print_group_policies $g

		echo '<< User List >>' >&3
		aws iam get-group  --group-name $g --query 'Users[*]' --region us-east-1 --output table >&3
		echo $'\n' >&3
	done
}

function print_group_policies() {
  policies=$(aws iam list-attached-group-policies --group-name $1 --query 'AttachedPolicies[*].PolicyArn' --region us-east-1 --output text)

  for p in $policies;
  do
    echo '<< Policy >>' >&3
    echo $p >&3
    echo '--------------------------------------------------------' >&3
    ver=$(aws iam get-policy --policy-arn $p --query 'Policy.DefaultVersionId' --region us-east-1 --output text)
    aws iam get-policy-version --policy-arn $p --version-id $ver --output json >&3
  done
}

function clean() {
  # exit virtual environment
  deactivate
  rm -r $cwd/.awscli
}

function open_file() {
  if [ -f $report_file ]; then
    rm $report_file
  fi

  # open file descriptor (fd) 3 for read/write on a text file.
  exec 3<> $report_file
}

function close_file() {
  # close fd 3
  exec 3>&-
}

function report() {
  # print help
  print_help

  # install aws cli
  install_awscli

  # open file
  open_file

  # report
  print_title
  print_group

  # clean up
  close_file
  clean
}

### make an audit report
if [ -f $log_file ]; then
  rm $log_file
fi

report
