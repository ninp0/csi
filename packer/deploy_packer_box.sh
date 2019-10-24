#!/bin/bash --login
provider_type=$1
box_version=$2
debug=false
export PACKER_LOG=1
set -e

function usage() {
  echo "USAGE: ${0} <aws_ami||docker_csi||docker_transparent_browser||kvm||virtualbox||vmware> <box version to build e.g. 2019.3.1> <debug>"
  exit 1
}

function pack() {
  provider_type=$1
  packer_provider_template=$2
  debug=$3
  packer_secrets='packer_secrets.json'

  if $debug; then
    packer build \
      -debug \
      -only $provider_type \
      -var "box_version=${box_version}" \
      -var-file=$packer_secrets \
      $packer_provider_template
  else
    packer build \
      -only $provider_type \
      -var "box_version=${box_version}" \
      -var-file=$packer_secrets \
      $packer_provider_template
  fi 
}

function deploy_base_csi_kali_rolling_container() {
    rm kali_rolling_docker.box || true
    pack docker kali_rolling_docker_csi.json $debug
    #vagrant box remove csi/kali_rolling --provider=docker || true
    #vagrant box add --box-version $box_version csi/kali_rolling kali_rolling_docker_csi.box
}

if [[ $# < 2 ]]; then
  usage
fi

if [[ $3 != '' ]]; then
  debug=true
fi

case $provider_type in
  "aws_ami")
    # Create Service Role for vmimport per instructions here:
    # https://docs.aws.amazon.com/vm-import/latest/userguide/vmimport-image-import.html
    echo $debug
    pack amazon-ebs kali_rolling_aws_ami.json $debug
    ;;
  "docker_csi")
    deploy_base_csi_kali_rolling_container
    ;;
  "docker_transparent_browser")
    docker images -a | grep 'csi/kali_rolling' > /dev/null 2>&1
    if [[ $? != 0 ]]; then
      deploy_base_csi_kali_rolling_container
    fi
    rm kali_rolling_docker_transparent_browser.box || true
    pack docker kali_rolling_docker_transparent_browser.json $debug
    ;;
  "kvm")
    rm kali_rolling_qemu_kvm_xen.box || true
    pack qemu kali_rolling_qemu_kvm_xen.json $debug
    vagrant box remove csi/kali_rolling --provider=qemu || true
    vagrant box add --box-version $box_version csi/kali_rolling kali_rolling_qemu_kvm_xen.box
    ;;
  "virtualbox")
    rm kali_rolling_virtualbox.box || true
    pack virtualbox-iso kali_rolling_virtualbox.json $debug
    vagrant box remove csi/kali_rolling --provider=virtualbox || true
    vagrant box add --box-version $box_version csi/kali_rolling kali_rolling_virtualbox.box
    ;;
  "vmware")
    echo $debug
    rm kali_rolling_vmware.box || true
    pack vmware-iso kali_rolling_vmware.json $debug
    vagrant box remove csi/kali_rolling --provider=vmware_desktop || true
    vagrant box add --box-version $box_version csi/kali_rolling kali_rolling_vmware.box
    ;;
  *)
    usage
    exit 1
esac
